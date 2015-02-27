express = require 'express'
path = require 'path'
request = require 'request'

app = express()
clientRoot = path.resolve './'
app.set 'port', 8200

app.use (req, res, next) ->
  res.header "Access-Control-Allow-Origin", "*"
  res.header "Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept"
  next()

app.get '/', (req, res) ->
	res.sendFile path.join clientRoot, 'src/index.html'

app.get '/weather', (req, res) ->
	console.log new Date()
	url = 'https://api.forecast.io/forecast/ad546117ced93ed99869b4bf93a990fe/32.0806,34.8142?units=si'
	request.get url, (err, response, body) ->
		res.send body

app.use express.static clientRoot
app.listen app.get('port'), () ->
	console.log "App is now listening to port " + app.get 'port'