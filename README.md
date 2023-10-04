# deploy-pgbd-with-replica

## What we solve here.

1. Provisioning two PostgreSQL instances, one Master and other a Read Replica.
2. We create a simple table called orders, this table has simple data but we have 3 python apps doing selects and inserts on the table every second.
3. The instances pg_master replies everything to the pg_replica Read Only instance.
4. We partition the table orders online using pg_partman to help us with the future maintenances.

## Using the automations.

1. Execute the startup.sh script, this script will start all the infra and apps, doing the replication and executing the initial migration.

``` sh
cd deploy
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

## Troubleshooting possible errors.

1. If we've got and error on the startup, we can clean the execution and execute again with no dependencies. To execute this script we need the sudo credentials, because we need to remove a shared resource by pg_master and pg_replica.

``` sh
sh clean-exec.sh
```

2. If we got a lock ERROR when executing the part 2 script to partition, we just need to re-execute the script.

``` log
psql:/etc/postgresql/query/migrate-data.sql:2: ERROR:  could not obtain lock on relation "public.orders"
```


