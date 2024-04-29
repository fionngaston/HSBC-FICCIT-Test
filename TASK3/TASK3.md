# TASK3: Database design


A kdb+ based solution for a new UI feature which provides charting of different stock prices over time, based on some high frequency historical data.


## Architecture diagram
<diagram>


## Data capture
Keep the data capture design simple. Use a traditional date partitioned, sym-parted data. Store every tick on the database. Data will be persisted from an in-memory RDB to HDB at end of day. All historical data up to yesterday's end of day will be stored in the HDB.


## Data query
- The charting front end will pass in a symbol (the stock sym), a start and end timestamp and a granularity, i.e. how many price points to return to the chart. Assuming q-TCP requests to the back-end.
- The gateway (GW) is a q process. This has an API function defined that can be called via TCP.
- The RDB and HDBs are q processes. They have query API functions that can be called by the GW.

### Query logic
- Database registration: The GW will have a list of all running databases. Each database will register with the GW upon startup by connecting to the GW and calling a register API. This will append that database's availability to an in-memory availability table containing handles to the database and list of time ranges available. The databases will re-call this registration API upon EOD writedown to refresh the time ranges available. The GW will remove a database from this availability table upon database disconnection in the `.z.pc` handle.
- Database selection: The GW will process the `start` and `end` timestamps, use these to determine which database(s) to route the request to by looking up the availability table e.g. if the times requested are only for today, route the request to an RDB only. If there are multiple different databases that could fulfil the request, the database with the fewest number of outstanding requests will be selected (`first key asc count each .z.W`).
- Request routing: Upon receiving a request from the charting client and determining the database to send the requests to, the GW will send async requests to the relevant databases.
- Parallelisation: The API function called by the charting client will call `-30!(::)`, inducing a [deferred response](https://code.kx.com/q/kb/deferred-response/). This will cause the charting client to wait for the response like a normal synchronous call, but allow the GW to process other requests while the client waits.
- The GW will call a database API function to select the relevant data at the specified granularity. Example API for RDB:
   ```q
   q) getQuotes:{[symParam;start;end;granularity] select last price by sym:symParam, `timestamp$((end-start)%granularity) xbar time from quote where sym=symParam, time within (start;end)}
   q) getQuotes[`eurusd;2024.04.27D14:45;2024.04.27D15:45;500]
   sym    time                         | price 
   ------------------------------------| -------
   eurusd 2024.04.27D14:45:00.000000000| 642.535
   eurusd 2024.04.27D14:45:07.200000000| 752.073
   eurusd 2024.04.27D14:45:14.400000000| 773.553
   eurusd 2024.04.27D14:45:21.600000000| 836.555
   eurusd 2024.04.27D14:45:28.800000000| 274.519
   ...
   ``` 
 This API will be called asynchronously by the GW. Upon completion of the request, the database will return the results to the same GW handle, calling a GW API to process the results. 
- Upon receipt of the responses from the databases, the GW will store the responses in-memory. When all expected responses have been returned for a client request, the GW will join the results together, and return the results to the charting client in a message of format `-30!(clientHandle;0b;data)`.


## What are the strongest points of your design and what are some of its limitations and challenges?

### Data granularity
The database captures and persists all ticks of data. Advantages of this are allowing us to query to any granularity, and allowing us to build further analytics in future. all data is there so we have the flexibility to do what we want with it in future. A disadvantage is that this has large memory and storage requirements.


### Intraday writedowns
I proposed a simple RDB/HDB tick-capture architecture; an intraday writedown was not included. This simplifies data capture and query routing. Note, however, that the GW routing design is easily expandable to include other intraday databases; the routing logic is designed to be generic by having databases declare their data availability upon registration.


Disadvantages of not having an intraday write solution include higher memory requirements; data for a whole day must be kept in-memory. This has the knock-on effect of making it difficult to scale RDBs; each RDB must contain a copy of the whole day's data in-memory. Query parallelisation will be limited by the number of RDBs you have i.e. how much memory you have available.

### Boundary problems
I proposed a database API where most of the computation is done on the database. This utalises kdb's fast database query power, and reduces the amount of data being transmitted between processes. This may, however, introduce boundary problems as some of the data a single granularity tick in the expected results may be in both RDB & HDB, resulting in duplicate results. This could be solved by an aggregation function on the GW favouring RDB data in joined results.

### Deferred response limitations
I assumed that the charting front end is making q-TCP requests to the gateway. In practice, http requests are more common. Deferred sync requests do not support http requests. If this was a requirement, a non-kdb GW e.g. [nginx](https://www.nginx.com/) could be considered either as a replacement or as a router in front of the existing GW.


## What is the best design you could think of if charting precision was the outmost priority?
I believe my solution gives an excellent level of precision. If the chart request required tick-by-tick precision, size of tables and TCP transmission time will be a limiting factor. A solution could be considered whereby the charting front end makes calls to the database directly. This skips out the GW TCP hops.


## What is the best design you could think of if performance was the outmost priority?
Query performance could be improved by implementing pre-aggregation on the databases. The EOD process could calculate the last price to a defined precision e.g. 1 second and store this in the database daily. The HDB database API could then read from this table faster than the raw, unaggregated data. This could be further expanded to the RDB to calculate last price by second on a timer, then append to an in-memory table for querying.

