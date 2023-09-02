/ read data
t: ("DSTFF";enlist ",") 0:`$"./trade.csv";
q: ("DSTFFFF";enlist ",") 0:`$"./quote.csv";
q: select from q where ask>bid, (time within (09:30;11:29:59.999)) or time within (13:00;14:59:59.999)
\c 20 200

/ minutely data of trade
mt: select open:first price, high:max price, low:min price, close:last price, vol:sum size, turnover:sum price * size by sym, date, time.minute from t;
mt: update rtn:-1+close%prev close by sym,date from mt;

/ compute spread and qsize
q: update spread:10000*(ask-bid)%0.5*ask+bid, qsize:0.5*asize+bsize from q;
/ minutely data of quote
mq: select avg spread, avg qsize by date, sym, time.minute from q

/ combine minutely date of trade and quot
m: mt lj mq;
m

/ daily data 
d: select sum vol, sum turnover, avg spread, avg qsize, last close, vol5:(dev rtn)*sqrt 240 by sym,date from m;
d: update rtn:-1+close%prev close by sym from d;
d

/ a1: ans of Q1
a1:select ADV:avg vol, ADTV:avg turnover, Volatility:dev rtn, Volatility5:avg vol5, Spread:avg spread, Quote_Size:avg qsize by Stock:sym from d;
a1

save `a1.csv 

/ Q2
/ minutely date: add volpct
m: update volpct:vol%sum vol by sym,date from m;
m

/ m5
m5: select avg spread, avg qsize, sum volpct by sym, date, 5 xbar minute from m;
m5

a2: select vol5:(dev rtn)*sqrt 240 by sym, 5 xbar minute from m where sym = `600030.SHSE;
a2

a2: a2 lj (select avg spread, avg qsize, avg volpct by sym,minute from m5 where sym = `600030.SHSE);
a2

save `a2.csv 
