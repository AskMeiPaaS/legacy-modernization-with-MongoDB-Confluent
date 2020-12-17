# Legacy Modernization with MongoDB & Confluent
It demonstrates how MongoDB and Confluent together can help organizations build Robust Operational Data Layer. How to do change data capture migration and real time data synchronization from relational database, MySQL to MongoDB Atlas using Confluent Platform and MongoDB Connector for Apache Kafka.

## Architectural overview

A demo to move change data from a relational database to MongoDB using Confluent and Kafka.
![Architecture](/docs/architecture.png)


The data pipeline
![Data Flow](/docs/dataflow.png)

## Prerequisites & setup
- clone this repo!
- install docker/docker-compose
- sign a trial MongoDB atlas account https://www.mongodb.com/cloud/atlas/register
- set your Docker maximum memory to something big, such as 8GB. (preferences -> advanced -> memory)

# Get started

## Docker Startup
Open your terminal --> Go to docker folder and then:
```
docker-compose up  -d
```
## Create schema and load sample data
```
docker exec -i mysql mysql -uroot -p'A(^(%@123KLHadasda00' mysql < ../create_table.sql
```
## Create MySQL CDC Connector
```
curl -i -X POST -H "Accept:application/json" \
    -H  "Content-Type:application/json" http://localhost:8083/connectors/ \
    -d '{
  "name": "mysql_cdc",
  "config": {
    "connector.class": "io.debezium.connector.mysql.MySqlConnector",
    "tasks.max": "1",
    "database.hostname": "mysql",
    "database.port": "3306",
    "database.user": "root",
    "database.password": "A(^(%@123KLHadasda00",
    "database.server.name": "mongodb",
    "database.server.id": "1",
    "database.history.kafka.bootstrap.servers": "broker:29092",
    "database.history.kafka.topic": "mysql_history",
    "include.schema.changes": true,
    "include.query": true,
    "table.ignore.builtin": true,
    "database.whitelist": "kafka",
    "message.key.columns": "kafka.fin_account:account_id;kafka.fin_disp:disp_id;kafka.fin_loan:loan_id;kafka.fin_order:order_id;kafka.fin_trans:trans_id"
  }
}'
```
Check connector status: 

```
curl -s "http://localhost:8083/connectors?expand=info&expand=status" | \
         jq '. | to_entries[] | [ .value.info.type, .key, .value.status.connector.state,.value.status.tasks[].state,.value.info.config."connector.class"]|join(":|:")' | \
         column -s : -t| sed 's/\"//g'| sort
```
Once the connector is running, do observe the corresponding topics created for tables in the broker through Confluent Control Center by logging to it http://localhost:9021/clusters --> Cluster --> Topics.
Example:
![Topics](/docs/topics.png)

## Connect to ksqlDB to define the data pipeline
Get a KSQL CLI session:
```
docker exec -it ksqldb-cli bash -c 'echo -e "\n\n⏳ Waiting for KSQL to be available before launching CLI\n"; while : ; do curl_status=$(curl -s -o /dev/null -w %{http_code} http://ksqldb-server:8088/info) ; echo -e $(date) " KSQL server listener HTTP state: " $curl_status " (waiting for 200)" ; if [ $curl_status -eq 200 ] ; then  break ; fi ; sleep 5 ; done ; ksql http://ksqldb-server:8088'
```

Execute [script](/3_create_table_select.ksql) in ksqlDB prompt.

Validate the stream generation through the flow GUI. http://localhost:9021/clusters --> Cluster --> ksqlDB --> ksqldb1 --> flow
![Data Flow](/docs/dataflow.png)

## Create cluster on MongoDB Atlas
* Follow the steps [here](https://docs.atlas.mongodb.com/tutorial/create-new-cluster)  to create a new database cluster
* Configure database user, IP Whitelist and copy the connection string. Follow the steps [here](https://docs.atlas.mongodb.com/driver-connection)

## Create MongoDB Connector
Set the connection.uri to one copied in the previous step.
```
curl -i -X POST -H "Accept:application/json" \
    -H  "Content-Type:application/json" http://localhost:8083/connectors/ \
    -d '{
  "name": "mongodb_conn",
  "config": {
    "topics": "FIN_ACCOUNT_TRANS_MONGODB",
    "connector.class": "com.mongodb.kafka.connect.MongoSinkConnector",
    "tasks.max": "1",
    "connection.uri": "mongodb+srv://confluent:Password@cluster0.d7axt.mongodb.net/blog",
    "database": "FinancialData",
    "collection": "Transactions",
    "confluent.license.inject.into.connectors":"false"
  }
}'

```
Check connector status: 

```
curl -s "http://localhost:8083/connectors?expand=info&expand=status" | \
         jq '. | to_entries[] | [ .value.info.type, .key, .value.status.connector.state,.value.status.tasks[].state,.value.info.config."connector.class"]|join(":|:")' | \
         column -s : -t| sed 's/\"//g'| sort
```
## Validate data in MongoDB
Login to MongoDB Atlas account and validate whether you can see the data in the cluster. Example:
![MongoDB Collection](/docs/mongodb.png)

## Add transactions to MySQL.
To mimic the real-time scenario, connect to mysql node and push a few transactions.
```
docker exec -it mysql mysql -uroot -p'A(^(%@123KLHadasda00'
```

Execute [script](/4_load_trans.sql) in mysql prompt

Watch the new data getting ingested into the target in real-time by refreshing the page.

## Setup Atlas online archive
* Follow the steps [here](https://docs.mongodb.com/datalake/tutorial/getting-started) to setup Atlas datalake.
* Set up online archival for FinancialData.Transactions collection. Follow the steps [here](https://docs.atlas.mongodb.com/online-archive/configure-online-archive)
![Archival](/docs/archival.png)

## Setup Charts
* Launch MongoDB Charts. Follow the steps [here](https://docs.mongodb.com/charts/master/launch-charts)
* You can try building different types of charts. Below is an example Circular chart on Transactions collection. 
![Charts](/docs/charts.png)
