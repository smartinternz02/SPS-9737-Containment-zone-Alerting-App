

from flask import Flask,render_template,request,session
from flask_mysqldb import MySQL
import MySQLdb.cursors
import re
from sendmail import sendgridmail


app= Flask(__name__)

app.secret_key = 'a'

app.config['MYSQL_HOST'] = 'remotemysql.com'
app.config['MYSQL_USER'] = '1buSSWjecV'
app.config['MYSQL_PASSWORD'] = 'tptAYEEXve'
app.config['MYSQL_DB'] = '1buSSWjecV'
mysql = MySQL(app)

@app.route('/')
def start():
    return render_template("login.html")
	
@app.route('/signup', methods =['GET', 'POST'])
def signup():
    msg = ''
    if request.method == 'POST' :
        name = request.form['name']
        email = request.form['email']
        password = request.form['password']
        

        cursor = mysql.connection.cursor()
        cursor.execute('SELECT * FROM admin WHERE name = % s', (name, ))
        account = cursor.fetchone()
        print(account)
        if account:
            msg = 'Account already exists !'
        elif not re.match(r'[^@]+@[^@]+\.[^@]+', email):
            msg = 'Invalid email address !'
        elif not re.match(r'[A-Za-z0-9]+', name):
            msg = 'name must contain only characters and numbers !'
        else:
            cursor.execute('INSERT INTO admin VALUES (NULL, % s, % s, % s)', (name, email,password))
            mysql.connection.commit()
            msg = 'You have successfully registered !'
            TEXT = "Hello "+name + ",\n\n"+ """Thanks  """ 
            message  = 'Subject: {}\n\n{}'.format("", TEXT)
            #sendgridmail(email,TEXT)
    elif request.method == 'POST':
        msg = 'Please fill out the form !'
    return render_template('signup.html', msg = msg)

@app.route('/login',methods =['GET', 'POST'])
def login():
    global userid
    msg = ''
   
  
    if request.method == 'POST' :
        name = request.form['name']
        password = request.form['password']
        cursor = mysql.connection.cursor()
        cursor.execute('SELECT * FROM admin WHERE name = % s AND password = % s', (name, password, ))
        account = cursor.fetchone()
        print (account)
        if account:
            session['loggedin'] = True
            session['id'] = account[0]
            userid=  account[0]
            session['name'] = account[1]
            msg = 'Logged in successfully !'
            
            msg = 'Logged in successfully !'
            return render_template('dashboard.html', msg = msg)
        else:
            msg = 'Incorrect username / password !'
    return render_template('login.html', msg = msg)
	
	
@app.route('/dashboard',methods =['GET', 'POST'])
def Savedetails():

	msg1 = ''
	if request.method == 'POST' :
		radius = request.form['rads']
		placename = request.form['place']
		latitude = request.form['latitude']
		longitude = request.form['longitude']
		cursor = mysql.connection.cursor()
		cursor.execute('SELECT * FROM containmentzone WHERE placename = % s', (placename, ))
		account = cursor.fetchone()
		print(account)
		print(longitude)
		if account:
			msg1 = 'Already Added!'
		else:
			cursor.execute('INSERT INTO containmentzone VALUES (NULL, % s, % s, % s, % s)', (latitude,longitude,placename, radius))
			mysql.connection.commit()
			msg1 = 'Added to DB'
	elif request.method == 'POST':
		msg1 = 'Please fill out the form !'
	return render_template('dashboard.html', msg1 = msg1)

@app.route('/czone', methods =['GET', 'POST'])
def czone():
	data=''
	cursor = mysql.connection.cursor()
	cursor.execute('SELECT * FROM containmentzone')
	data = cursor.fetchall()
	return render_template('czone.html', value=data) 
	

@app.route('/Tusers', methods =['GET', 'POST'])
def Tusers():
	data=''
	cursor = mysql.connection.cursor()
	cursor.execute('SELECT * FROM user_registration')
	data = cursor.fetchall()
	if request.method == 'POST' :
		email = request.form['email']
		msg = "You are in Containmentzone"
		sendgridmail(email,msg)
	return render_template('Tusers.html', value=data)
	

if __name__ == '__main__':
    app.run(host='0.0.0.0',debug = True,port = 8080)