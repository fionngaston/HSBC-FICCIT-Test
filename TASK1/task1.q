/2. A function which, given a time range and a list of symbols as inputs, returns the VWAP (TWAP) for each of these symbols as a table

/load data
ex1Data: ("PSFJ";enlist csv) 0: `:data.csv

/example usage
/calcVwap[2024.04.27D14:30:05;2024.04.27D14:30:10;`eurusd`eurgbp]
calcVwap:{[startTime;endTime;symList] select vwap:size wavg price by sym from ex1Data where sym in symList, time within (startTime;endTime)}

/example usage
/calcTwap[2024.04.27D14:30:05;2024.04.27D14:30:10;`eurusd`eurgbp]
calcTwap:{[startTime;endTime;symList] select twap:time wavg price by sym from ex1Data where sym in symList, time within (startTime;endTime)}
