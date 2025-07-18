import psycopg2

try:
    conn = psycopg2.connect(
        dbname="testdb",
        user="postgres",
        password="7668",
        host="localhost",
        port="5432"
    )

    cur = conn.cursor()
    cur.execute("SELECT version();")
    version = cur.fetchone()
    print("✅ Connected! PostgreSQL version:", version)

    cur.close()
    conn.close()

except Exception as e:
    print("❌ Connection failed:", e)

