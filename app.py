from flask import Flask, render_template, request, redirect, url_for, session, flash
import pymysql
import os

app = Flask(__name__)
app.secret_key = 'telecom_secret_key_2026'

# Database Connection Details
DB_HOST = os.environ.get('DB_HOST', 'localhost')
DB_USER = os.environ.get('DB_USER', 'root')
DB_PASSWORD = os.environ.get('DB_PASSWORD', '') # Update with your MySQL password
DB_NAME = os.environ.get('DB_NAME', 'telecom_db')

def get_db_connection():
    try:
        connection = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor
        )
        return connection
    except Exception as e:
        print(f"Database connection failed: {e}")
        return None

# Middleware to check login
@app.before_request
def require_login():
    allowed_routes = ['login', 'static']
    if request.endpoint not in allowed_routes and 'admin_id' not in session:
        return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        conn = get_db_connection()
        if not conn:
            flash("Database not connected. Please check configuration.", "danger")
            return render_template('login.html')
            
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM admins WHERE username=%s AND password=%s", (username, password))
            admin = cursor.fetchone()
            
        conn.close()
        
        if admin:
            session['admin_id'] = admin['admin_id']
            session['username'] = admin['username']
            return redirect(url_for('dashboard'))
        else:
            flash("Invalid credentials!", "danger")
            
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

@app.route('/')
@app.route('/dashboard')
def dashboard():
    conn = get_db_connection()
    stats = {'total_customers': 0, 'active_sims': 0, 'total_revenue': 0, 'active_towers': 0}
    
    if conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) as c FROM customers")
            stats['total_customers'] = cursor.fetchone()['c']
            
            cursor.execute("SELECT COUNT(*) as c FROM sim_cards WHERE status='Active'")
            stats['active_sims'] = cursor.fetchone()['c']
            
            cursor.execute("SELECT SUM(amount_paid) as r FROM payments")
            res = cursor.fetchone()['r']
            stats['total_revenue'] = res if res else 0
            
            cursor.execute("SELECT COUNT(*) as c FROM towers WHERE status='Active'")
            stats['active_towers'] = cursor.fetchone()['c']
            
        conn.close()
        
    return render_template('dashboard.html', stats=stats)

@app.route('/customers')
def customers():
    conn = get_db_connection()
    customers_list = []
    if conn:
        with conn.cursor() as cursor:
            # Using our view
            cursor.execute("SELECT * FROM view_customer_details")
            customers_list = cursor.fetchall()
        conn.close()
    return render_template('customers.html', customers=customers_list)

@app.route('/towers')
def towers():
    conn = get_db_connection()
    towers_list = []
    if conn:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT t.tower_id, t.tower_location, t.signal_strength, t.status, r.region_name
                FROM towers t
                LEFT JOIN regions r ON t.region_id = r.region_id
            """)
            towers_list = cursor.fetchall()
        conn.close()
    return render_template('towers.html', towers=towers_list)

@app.route('/billing')
def billing():
    conn = get_db_connection()
    bills_list = []
    if conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM bills ORDER BY due_date DESC")
            bills_list = cursor.fetchall()
        conn.close()
    return render_template('billing.html', bills=bills_list)

if __name__ == '__main__':
    # To run on any port, you can change the port here
    app.run(debug=True, port=5000)
