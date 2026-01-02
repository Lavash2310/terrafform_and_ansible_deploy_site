import os
import socket
from flask import Flask, render_template, request, redirect, url_for
from datetime import date
from flask_mysqldb import MySQL

app = Flask(__name__)

app.config['MYSQL_USER'] = 'db_user'
app.config['MYSQL_PASSWORD'] = os.getenv('DB_PASSWORD', 'zaza2310')
app.config['MYSQL_DB'] = 'employee_db'
app.config['MYSQL_HOST'] = 'localhost'

mysql = MySQL(app)

@app.route('/')
def main():
    return redirect(url_for('employees'))

@app.route('/employees')
def employees():
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT * FROM employees")
    rows = cursor.fetchall()
    cursor.close()
    server_ip = socket.gethostbyname(socket.gethostname())
    return render_template('index.html', rows=rows, server_ip=server_ip)

@app.route('/employees/add', methods=['POST', 'GET'])
def add_employee():
    if request.method == 'POST' and 'full_name' in request.form:
        full_name = request.form['full_name']
        position = request.form['position']
        salary = request.form['salary']
        today = date.today().strftime("%Y-%m-%d")
        cursor = mysql.connection.cursor()
        cursor.execute("INSERT INTO employees (full_name, position, salary, hire_date) VALUES (%s, %s, %s, %s)", (full_name, position, salary, today))
        mysql.connection.commit()
        cursor.close()
    return redirect(url_for('employees'))

@app.route('/employees/update/<int:id>', methods=['POST', 'GET'])
def update_employee(id):
    cursor = mysql.connection.cursor()
    if request.method == 'POST' and 'full_name' in request.form:
        full_name = request.form['full_name']
        position = request.form['position']
        salary = request.form['salary']
        cursor.execute("UPDATE employees SET full_name = %s, position = %s, salary = %s WHERE id = %s", (full_name, position, salary, id))
        mysql.connection.commit()
        cursor.close()
        return redirect(url_for('employees'))
    else:
        cursor.execute("SELECT * FROM employees WHERE id = %s", (id,))
        row = cursor.fetchone()
        cursor.close()
        if row:
            return render_template('edit.html', row=row)
        return redirect(url_for('employees'))

@app.route('/employees/delete/<int:id>')
def delete_employee(id):
    cursor = mysql.connection.cursor()
    cursor.execute("DELETE FROM employees WHERE id = %s", (id,))
    mysql.connection.commit()
    cursor.close()
    return redirect(url_for('employees'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)