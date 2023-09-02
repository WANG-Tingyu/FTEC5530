t: ("DSTFF";enlist ",") 0:`$"trade.csv";
q: ("DSTFFFF";enlist ",") 0:`$"quote.csv";
p: ("DSSSITTFF";enlist ",") 0:`$"parent_order.csv";
c: ("SSDSTFF";enlist ",") 0:`$"child_order.csv";
t: update time:09:25|time&15:00 from t;

\c 20 200

bench:{[benchpx;px;side] 10000*side*(benchpx-px)%benchpx};
tca_calc:{[item]
    t1: select from t where date=item`date, sym=item`sym;
    q1: update midpx:0.5*bid+ask from select from q where date = item`date, sym = item`sym;
    c1: select from c where date=item`date, sym=item`sym, parentid=item`orderid;
    
    d: select DV:sum size, open:first price, close:last price from t1;
    d: d,'select avgpx:size wavg price, sum size from c1;
    
    d: d,'select moo: 0^sum size where time<09:30, moc: sum size where time>14:57 from c1;

    c1:update pass: (item`side) * signum ( midpx-price) from aj[`time;c1;select time,midpx from q1];
    d: d,'select passive:(sum size where pass=1)%sum size, aggressive:(sum size where pass=-1)%sum size from c1;

    d: d,'select spread: avg 10000*(ask-bid)%0.5*ask+bid from q1 where time within (item`starttime;item`endtime);
    d: d,'select arrival:last midpx from q1 where time<=item`starttime;
    d: d,'select ivwap:size wavg price, ivol: sum size from t1 where time within (item`starttime;item`endtime);

    d: d,'select pwp5:size wavg price from (update vol5:sums size*0.05 from select from t1 where time>=item`starttime) where vol5 <=item`qty;
    d: d,'select notional:sum price*size from c1;
    
    d: (enlist item), 'd;
    
    d: update arrival:open from d where starttime<09:30; 
    res: select orderid, notional, adv:size%DV, speed:size%ivol, spread, open:bench[open;avgpx;side], arrival:bench[arrival;avgpx;side], ivwap:bench[ivwap;avgpx;side], close:bench[close;avgpx;side], pwp5:bench[pwp5;avgpx;side],moo: moo%size, moc: moc%size, passive, aggressive from d;
    /res: select moo, size, moc, passive, aggressive from d;
    res
 };

result: raze tca_calc each p;
result

ass2_final_res: select OrderID: orderid, Notional:notional, ADV:adv, Speed:speed, Spread:spread,Open:open, Arrival:arrival, iVWAP:ivwap, Close:close, PWP5:pwp5, MOO:moo, MOC:moc, Passive:passive, Aggressive:aggressive from result


ass2_final_res

al: update OrderID: `All from select Notional:sum Notional,ADV:Notional wavg ADV, Speed:Notional wavg Speed, Spread:Notional wavg Spread, Open:Notional wavg Open,Arrival:Notional wavg Arrival,iVWAP: Notional wavg iVWAP,Close:Notional wavg Close,PWP5:Notional wavg PWP5,MOO:Notional wavg MOO, MOC:Notional wavg MOC,Passive:Notional wavg Passive,Aggressive:Notional wavg Aggressive from ass2_final_res
/ass2_final_res insert (al)
al: `OrderID xcols al

`ass2_final_res insert (al)
ass2_final_res

save `ass2_final_res.csv


