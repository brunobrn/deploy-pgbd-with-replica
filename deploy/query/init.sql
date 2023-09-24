
create sequence orders_seq
    start 1
    increment 1
    NO MAXVALUE
    CACHE 1;
	
CREATE TABLE IF NOT EXISTS orders (
    id int NOT NULL DEFAULT nextval('orders_seq'::regclass),
    product_name TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    order_date DATE NOT NULL,
	primary key (id)
);

CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  shop_id INT,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email VARCHAR(100),
  address VARCHAR(200),
  phone_number VARCHAR(20)
);

CREATE TABLE products (
  product_id INT PRIMARY KEY,
  shop_id INT,
  product_name VARCHAR(100),
  price INT,
  description VARCHAR(500)
);

ALTER SEQUENCE IF EXISTS public.orders_seq OWNED BY orders.id;

CREATE ROLE boring_app WITH LOGIN PASSWORD 'boring_app';
CREATE ROLE boring_insert WITH LOGIN PASSWORD 'boring_insert';
CREATE ROLE boring_report_read_replica WITH LOGIN PASSWORD 'boring_report_read_replica';

GRANT CONNECT ON DATABASE "testDB" TO boring_app;
GRANT CONNECT ON DATABASE "testDB" TO boring_insert;
GRANT CONNECT ON DATABASE "testDB" TO boring_report_read_replica;

grant usage on schema public to boring_app;
grant usage on schema public to boring_insert;
grant usage on schema public to boring_report_read_replica;

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.orders TO boring_app;
GRANT SELECT, INSERT ON TABLE public.orders TO boring_insert;
GRANT SELECT ON TABLE public.orders TO boring_report_read_replica;

GRANT USAGE, SELECT ON SEQUENCE public.orders_seq TO boring_app;
GRANT USAGE, SELECT ON SEQUENCE public.orders_seq TO boring_insert;


DO $$
DECLARE order_count INT := 200000;
  begin
    INSERT INTO orders (product_name, quantity, order_date)
  		select
      		'PRODUCT ' || row_number() OVER () as product_name,
	        (random() * 1000 + 1)::numeric(10, 2) as quantity,
      		CURRENT_DATE - (row_number() OVER () % 45 + 1) * INTERVAL '1 day' as order_date
  FROM generate_series(1, order_count) AS t
  ORDER BY t;
END $$;

DO $$DECLARE
  shop_count INT := 1000;
  customer_count INT := 30000;
  product_count INT := 30000;
BEGIN
  INSERT INTO customers (customer_id, shop_id, first_name, last_name, email, address, phone_number)
  SELECT
      row_number() OVER () as customer_id,
      (random() * shop_count + 1)::numeric(10, 2) as shop_id,
      'First' || row_number() OVER () as first_name,
      'Last' || row_number() OVER () as last_name,
      'customer' || row_number() OVER () || '@example.com' as email,
      'Address' || row_number() OVER () as address,
      '555-' || lpad((row_number() OVER ())::text, 4, '0')
  FROM generate_series(1, customer_count) AS t;

  INSERT INTO products (product_id, shop_id, product_name, price, description)
  SELECT
      row_number() OVER () as product_id,
      (random() * shop_count + 1)::numeric(10, 2) as shop_id,
      'Product' || row_number() OVER () as product_name,
      (row_number() OVER ()) % 100 + 1 as price,
      'Description for Product' || row_number() OVER () as description
  FROM generate_series(1, product_count) AS t;
 
END$$;

