begin;

create sequence orders_new_seq
    start 1
    increment 1
    NO MAXVALUE
    CACHE 1;

CREATE TABLE IF NOT EXISTS orders_new (
    id int NOT NULL DEFAULT nextval('orders_new_seq'::regclass),
    product_name TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    order_date DATE NOT NULL,
	primary key (id,order_date)
) partition BY RANGE (order_date);

ALTER SEQUENCE IF EXISTS public.orders_new_seq OWNED BY orders_new.id;

create index if not exists idx_orders_new_order_date on orders_new using btree (order_date);
create index if not exists idx_orders_new_order_date_order_date on orders_new using btree (order_date,order_date);

GRANT USAGE, SELECT ON SEQUENCE public.orders_new_seq TO boring_app;
GRANT USAGE, SELECT ON SEQUENCE public.orders_new_seq TO boring_insert;

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.orders_new TO boring_app;
GRANT SELECT, INSERT ON TABLE public.orders_new TO boring_insert;

SELECT create_parent( p_parent_table => 'public.orders_new', p_control => 'order_date', p_type => 'native', p_interval=> 'weekly', p_premake => 5,p_start_partition=>  (CURRENT_TIMESTAMP-'50 days'::interval)::text);

UPDATE part_config SET infinite_time_partitions = true,    retention_keep_table=true WHERE parent_table = 'public.orders_new';
SELECT cron.schedule('@daily', $$CALL partman.run_maintenance_proc()$$);

CREATE OR REPLACE FUNCTION copy_orders_to_orders_new()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO orders_new(id, product_name, quantity, order_date)
    VALUES (NEW.id, NEW.product_name, NEW.quantity, NEW.order_date);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_copy_orders_to_orders_new
AFTER INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION copy_orders_to_orders_new();

commit;
