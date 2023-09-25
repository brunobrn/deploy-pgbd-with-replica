# deploy-pgbd-with-replica

## What we solve here.

1. Provisioning two PostgreSQL instances, one Master and other a Read Replica.
2. We create a simple table called orders, this table has simple data but we have 3 python apps doing selects and inserts on the table every second.
3. The instances pg_master replies everything to the pg_replica Read Only instance.
4. We partition the table orders online using pg_partman to help us with the future maintenances.

## Using the automations.

1. Execute the startup.sh script, this script will start all the infra and apps, doing the replication and executing the initial migration.

``` sh
sh startup.sh
```

2. After all infra was online, we needed to startup our first part of configurations to partition orders table online. Basically here we create a partitioned table using the original orders table as a template, creating sequences, indexes, grants, trigger functions to insert new rows already on the new partitioned orders table, partman configurations and also the maintenance scheduled with pg_cron.

``` sh
sh partition-pt1.sh
```

3. Now we want to migrate the old data from original orders, fix the number of sequences and rename the tables.
   
``` sh
sh partition-pt2.sh
```

That's it.

## Bonus: 

I'am working on a project a little project to identify, give recommendations and fix some bloated tables or indexes, the project is at the very beginning, but in the next few weeks I will release other versions with more features.

Just run the command below and the put database password, ok we have only one table with just inserts, we don't have any bloat on immutable tables, but if you wanna see more, this is the repo: https://github.com/brunobrn/pg_unbloat (I created two other tables to show better).

```sh
docker exec -it pg_unbloat python exec_unbloat.py --host pg_master -U postgres -d testDB
```

## Troubleshooting possible errors.

1. If we've got and error on the startup, we can clean the execution and execute again with no dependencies. To execute this script we need the sudo credentials, because we need to remove a shared resource by pg_master and pg_replica.

``` sh
sh clean-exec.sh
```

2. If we got a lock ERROR when executing the part 2 script to partition, we just need to re-execute the script.

``` log
psql:/etc/postgresql/query/migrate-data.sql:2: ERROR:  could not obtain lock on relation "public.orders"
```

## Explaining my strategy.

1. I decided to use only bash script to startup the infra and configure the replication, i was thinking in use ansible to do the same, but this is a very simple workflow, if we want to execute this better, we need to create a CI/CD pipeline to create and test the images, test the application and deploy.

2. I used the full replication of instances just because it's a little bit more complex to configure and maintain, and everything we create on master are replicated to replica, this help us with the replication and partition of orders table by example, we just do nothing and the table are accessible and updated on replica side. 
   But, if we want to reply the table orders to another database, to migrate this data or the full database by example, ok, pub and sub are a better strategy for bigger tables.

3. I like very much to use pg_partman to partition tables, because it's a lot easier to maintain, the cons are the composite PK, but for this we always need to work together with the developer team to create the right idempotence for these tables. (The DBA sometimes shouldn't do all the work)

4. We can create all this infra with terraform and manage the state files from the cloud, creation of users, grants and powerful passwords. And to access these passwords and users we can use a tool like the Hashicorp Vault to do that.

5. I developed little python apps to connect on the database to exec inserts and selects on pg_master and also running little "reports" on the read replica side, i thinked interesting to simulate a full deployment.

That's it!

