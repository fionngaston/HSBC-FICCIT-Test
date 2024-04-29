/create csv 
n:1000
syms:`eurusd`eurgbp`eurjpy`euraud`usdjpy`gbpchf`gbpjpy`gbpusd
data:([]time:2024.04.27D14:30+100000000*til n; sym:n?syms; price:(n?1000000)%1000; size:n?1000)
save `data.csv