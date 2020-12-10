# confluent-mongodb-financial-data-sync
Contains demo asset for Confluent Mongodb financial data sync
## Architectural overview

A demo to move change data from a relational database to MongoDB using Confluent and Kafka.
![Architecture](/docs/architecture.png)


The datapipeline
![Data Flow](/docs/dataflow.png)

## Prerequisites & setup
- clone this repo!
- install docker/docker-compose
- sign a trial MongoDB atlas account https://www.mongodb.com/cloud/atlas/register
- set your Docker maximum memory to something big, such as 8GB. (preferences -> advanced -> memory)

# Get started

## Docker Startup
Go to docker folder
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

Execute ![Script](/3_create_table_select.ksql) in ksqlDB prompt.

Validate the stream on flow. http://localhost:9021/clusters --> Cluster --> ksqlDB --> ksqldb1 --> flow
![Data Flow](/docs/dataflow.png)

## Create MongoDB Connector
"Replace the userid, password and url in the connection.uri with your cluster details."
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
    "database": "blog",
    "collection": "confluent",
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
Login to MongoDB Atlas account and validate. Example:
![MongoDB Collection](/docs/mongodb.png)
