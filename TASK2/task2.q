\c 25 500
/TASK #2 calculate the conditional market VWAP (volume-weighted average price) corresponding to a set of client orders.

/load in data
clientorders:("JJSPSFPP";enlist csv) 0: `:clientorders.csv
markettrades:update `p# sym from ("SPFJ";enlist csv) 0: `:markettrades.csv

/conditional vwap
/exampleUsage 
/calcConditionalVwap[]
calcConditionalVwap:{[]
    / start & end time of each order version
    orderTs:value exec time, versionEnds from update versionEnds: end^next time by id from clientorders;

    / get all prices & volumes during (wj1) lifetime of each order version
    r1:wj1[orderTs;`sym`time;clientorders;(markettrades;(::;`price);(::;`volume))];

    / set volumes to 0 where they are not within the limit price
    r2:update limitedVolumes:(volume * ?[side=`B;price<=limit;price>limit])from r1;

    / conditional vwap 
    select id,sym,start,end,conditionalVwap:wavg'[limitedVolumes;price] from select last sym,last start,last end, raze price, raze limitedVolumes by id from r2
 };
