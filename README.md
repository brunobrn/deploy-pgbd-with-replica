# deploy-pgbd-with-replica


docker run --name=pg_unbloat -it fariasbrunobrn/pg_unbloat:latest bash
python exec_unbloat.py --host pg_master -U postgres -d testDB --table_min_size 0