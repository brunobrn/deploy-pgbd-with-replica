import psycopg

from config import host,dbname,user,password,port,app_name

def boring_report(days):
    try:
        conn = psycopg.connect(dbname=dbname, user=user, password=password, host=host, port=port, application_name=app_name)
        cur = conn.execute("select product_name,quantity from orders where order_date >= NOW() - interval '%s day'" % (days))
        quantity = cur.fetchall()
        print(quantity)
        # End transacations
        cur.close()
        return quantity

    except (Exception, psycopg.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()

