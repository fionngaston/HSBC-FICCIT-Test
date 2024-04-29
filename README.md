# HSBC FICC IT kdbInterview task
This is the solutions to offline task I was set for interview at HSBC FICC IT kdb.

# TASK #1
A function which, given a time range and a list of symbols as inputs, returns the VWAP (TWAP) for each of these symbols as a table. 
An See [data.csv](TASK1/data.csv) as an example input file.
Run the below to start a q process to load the script, load data and execute the functions

```q
% cd TASK1/
% q task1.q

q)calcVwap[2024.04.27D14:30:05;2024.04.27D14:30:10;`eurusd`eurgbp]
sym   | vwap    
------| --------
eurgbp| 519.3313
eurusd| 355.7039
q)calcTwap[2024.04.27D14:30:05;2024.04.27D14:30:10;`eurusd`eurgbp]
sym   | twap    
------| --------
eurgbp| 521.727 
eurusd| 399.7768
```

# TASK #2
Calculate the conditional market VWAP (volume-weighted average price) corresponding to a set of client orders.

Please see example input data for [clientorders](TASK2/clientorders.csv) and [markettrades](TASK2/markettrades.csv). 

Run the below to start a q process to load the script, load data and execute the function.


```q
% cd TASK2/
% q task2.q
q)calcConditionalVwap[]
id sym start                         end                           conditionalVwap
----------------------------------------------------------------------------------
1  AAA 2021.01.01D12:00:01.000000000 2021.01.01D12:15:00.000000000 9.75           
2  AAA 2021.01.01D12:05:00.000000000 2021.01.01D12:10:00.000000000 10.086         
3  AAA 2021.01.01D12:06:01.000000000 2021.01.01D12:19:01.000000000 10.2163        
4  BBB 2021.01.01D12:03:00.000000000 2021.01.01D12:18:01.000000000                
5  BBB 2021.01.01D12:04:00.000000000 2021.01.01D12:07:30.000000000                
6  CCC 2021.01.01D12:11:00.000000000 2021.01.01D12:15:00.000000000 10.05          
7  CCC 2021.01.01D12:10:00.000000000 2021.01.01D12:10:00.000000000 10.2     
```

# TASK #3
kdb+ design task.  
See [TASK3](TASK3/TASK3.md)