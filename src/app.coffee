express = require 'express'
path = require 'path'

app = express()
clientRoot = path.resolve './'
app.set 'port', 8200

app.get '/', (req, res) ->
	res.sendFile path.join clientRoot, 'src/index.html'

app.use express.static clientRoot
app.listen app.get('port'), () ->
	console.log "App is now listening to port " + app.get 'port'