echo "--------------------------------------------------------------------------------------"
echo "Starting main instance"
echo "--------------------------------------------------------------------------------------"
docker-compose up -d pg_master
sleep 5
echo "--------------------------------------------------------------------------------------"
echo "Configuring main instance to create a Read Replica"
echo "--------------------------------------------------------------------------------------"
docker exec -it pg_master sh /etc/postgresql/init-script/init.sh
docker cp pg_master:/var/lib/postgresql/data-slave ./
echo "--------------------------------------------------------------------------------------"
echo "Restarting main instance"
echo "--------------------------------------------------------------------------------------"
docker-compose restart pg_master
sleep 5
echo "--------------------------------------------------------------------------------------"
echo "Starting up Read Replica"
echo "--------------------------------------------------------------------------------------"
docker-compose up -d pg_replica
sleep 10
echo "--------------------------------------------------------------------------------------"
echo "Validate Read Replica, if active = T, the RR is online"
echo "--------------------------------------------------------------------------------------"
docker exec -it pg_master sh /etc/postgresql/init-script/validate.sh
echo "--------------------------------------------------------------------------------------"
echo "Executing first migration on main instance"
echo "--------------------------------------------------------------------------------------"
docker cp ./query/ pg_master:/etc/postgresql/
docker exec -it pg_master sh /etc/postgresql/query/exec_migration.sh
sleep 5
echo "--------------------------------------------------------------------------------------"
echo "Starting boring app - Execute one random select on orders table every one second"
echo "--------------------------------------------------------------------------------------"
docker-compose up -d boring_app
echo "--------------------------------------------------------------------------------------"
echo "Starting boring insert app - Insert one random row on orders table every one second"
echo "--------------------------------------------------------------------------------------"
docker-compose up -d boring_insert
echo "--------------------------------------------------------------------------------------"
echo "Starting boring report app - Select some random data with date between 0 and 45 days on Read Replica every five seconds."
echo "--------------------------------------------------------------------------------------"
docker-compose up -d boring_report_rr
echo "--------------------------------------------------------------------------------------"
echo "Starting pg unbloat automation - This is one of my projects, i still working in it."
echo "--------------------------------------------------------------------------------------"
docker-compose up -d pg_unbloat
echo "--------------------------------------------------------------------------------------"
echo "####################"
echo "Now we can run the automation to partition orders table"
echo "####################"