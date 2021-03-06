###

  server.coffee
  起動スクリプト

###

# dependency
http = require "http"
path = require 'path'

# user library
app = require path.resolve('config','app')
io  = require path.resolve('config','io')

# start socket.io and http server
server = http.createServer app
io app,server

server.listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
