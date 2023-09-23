import psycopg

from config import host,dbname,user,password,port,app_name

def insert(quantity):
    try:
        conn = psycopg.connect(dbname=dbname, user=user, password=password, host=host, port=port, application_name=app_name)
        cur = conn.execute("INSERT INTO public.orders(product_name, quantity, order_date)	VALUES ('inserted_before_startup', %s, now());" % (quantity))
        conn.commit()
        # End transacations
        cur.close()

    except (Exception, psycopg.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()

