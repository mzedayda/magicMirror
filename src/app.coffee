google = require 'googleapis'
googleCalendar = google.calendar 'v3'
express = require 'express'
path = require 'path'
request = require 'request'
Async = require 'async'

app = express()
clientRoot = path.resolve './'
app.set 'port', 8200
app.locals.config = 
	CLIENT_ID: '532617458069-u3ejhlpj99smmdshbb7maera4traa68d.apps.googleusercontent.com'
	CLIENT_SECRET: 'U4cxYp7-JSYKs9X4b6i4yV2J'
	REDIRECT_URL: 'http://n100.example.com:8200/oauth2callback'
	scopes: ['https://www.googleapis.com/auth/calendar.readonly']

OAuth2 = google.auth.OAuth2
oauth2Client = new OAuth2(app.locals.config.CLIENT_ID, app.locals.config.CLIENT_SECRET, app.locals.config.REDIRECT_URL)

app.get '/', (req, res) ->
	res.sendFile path.join clientRoot, 'src/index.html'

app.get '/weather', (req, res) ->
	url = 'https://api.forecast.io/forecast/ad546117ced93ed99869b4bf93a990fe/32.0806,34.8142?units=si'
	request.get url, (err, response, body) ->
		res.send body

app.get '/authUrl', (req, res) ->
	url = oauth2Client.generateAuthUrl
		access_type: 'offline'
		scope: app.locals.config.scopes
	res.send url

app.get '/oauth2callback', (req, res) ->
	res.send "Auth went great"

app.get '/events', (req, res) ->
	code = req.query.authCode
	oauth2Client.getToken code, (err, tokens) ->
		return res.send err if err?
		oauth2Client.setCredentials tokens
		googleCalendar.calendarList.list { auth: oauth2Client }, (err, calendars) ->
			Async.concat calendars.items, (calendar, next) ->
				googleCalendar.events.list
					calendarId: calendar.id
					singleEvents: true 
					timeMin: yesterday()
					timeMax: nextWeek()
					auth: oauth2Client
				, (err, calendarEvents) ->
					return next err, calendarEvents?.items
			, (err, events) ->
				return res.send err if err?
				return res.send events

app.use express.static clientRoot
app.listen app.get('port'), () ->
	console.log "App is now listening to port " + app.get 'port'

yesterday = () ->
	now = new Date();
	return new Date(now.getFullYear(), now.getMonth(), now.getDate()-1).toISOString()	
nextWeek = () ->
	now = new Date();
	return new Date(now.getFullYear(), now.getMonth(), now.getDate()+7).toISOString()