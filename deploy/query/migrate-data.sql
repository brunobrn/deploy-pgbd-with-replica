BEGIN;
LOCK TABLE public.orders IN ACCESS EXCLUSIVE MODE NOWAIT;

with cte as (select min(id) as min_id from orders_new)
insert into orders_new(id,product_name,quantity,order_date) select id,product_name,quantity,order_date from orders ,cte where id < cte.min_id order by id desc;

with cte as (select max(id) as id from orders) SELECT setval('public.orders_new_seq', cte.id, true) from cte;

alter table orders rename to orders_old;
alter table orders_new rename to orders;

commit;

GRANT SELECT ON TABLE public.orders TO boring_report_read_replica;