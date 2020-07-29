import requests
import sys
import json
from flask import render_template, flash, redirect, request, session
from flask import Flask
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField
from wtforms.validators import DataRequired
from python_terraform import *

app = Flask(__name__)
app.config['SECRET_KEY'] = 'cisco'


def terraformAction(tenantName, epgCount, vmmDomain):
    tf = Terraform(working_dir='./', variables={
                   'tenantName': tenantName, 'epgCount': epgCount, 'vmmDomain': vmmDomain})
    plan = tf.plan(no_color=IsFlagged, refresh=False,
                   capture_output=True, out="plan.out")
    approve = {"auto-approve": True}
    output = tf.apply(skip_plan=True, **approve)
    return output


class LoginForm(FlaskForm):
    fabric = StringField('FabricIP', validators=[DataRequired()])
    username = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    rememberMe = BooleanField('Remember Me')
    submit = SubmitField('Sign in')


def getAPICCookie():
    url = 'https://'+session['fabric']+'/api/aaaLogin.xml'
    xml_string = "<aaaUser name='%s' pwd='%s'/>" % (
        session['username'], session['password'])
    req = requests.post(url, data=xml_string, verify=False)
    session['cookie'] = req.cookies['APIC-cookie']


def sendAPICRequest(apicurl):
    url = 'https://'+session['fabric']+apicurl
    cookies = {}
    cookies['APIC-cookie'] = session['cookie']
    req = requests.get(url, cookies=cookies, verify=False)
    return json.loads(req.text)


@app.route('/terraform', methods=['GET', 'POST'])
def terraform():
    if request.method == "POST":
        req = request.form
        planOutput = terraformAction(
            req.get("tenantName"), req.get("epgCount"), req.get("vmmDomain"))
        return render_template('terraform.html', plan=planOutput)
    return render_template('terraform.html')


@app.route('/menu')
def menu():
    return render_template('menu.html')


@app.route('/epgs')
def epgs():
    epgList = sendAPICRequest(
        "/api/node/class/fvAEPg.json?&order-by=fvAEPg.name")
    return render_template('epg.tpl', title='List of all EPGs', epgs=epgList['imdata'])


@app.route('/tenants')
def tenants():
    tenantList = sendAPICRequest(
        "/api/node/class/fvTenant.json?&order-by=fvTenant.name")
    return render_template('tenants.tpl', title='List of all tenants', tenants=tenantList['imdata'])


@app.route('/endpoints')
def endpoints():
    endpointList = sendAPICRequest(
        "/api/node/class/fvCEp.json")
    return render_template('endpoints.tpl', title='List of all endpoints', endpoints=endpointList['imdata'])


@app.route('/')
@app.route('/index.html')
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == "POST":
        session['fabric'] = request.form['fabric']
        session['username'] = request.form['username']
        session['password'] = request.form['password']
        try:
            getAPICCookie()
            if 'cookie' in session:
                return redirect('/menu')
        except KeyError:
            flash('Invalid credentials')
            return redirect('login')
    return render_template('login.tpl', title='Sign In')


if __name__ == '__main__':
    app.run()
