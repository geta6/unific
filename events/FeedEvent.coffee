###

  FeedEvent.coffee

###

module.exports.FeedEvent = (app) ->

  combiner = require('combine-rss').combiner()  
  async    = require 'async'

  Stream = app.get("models").Stream
  Feed   = app.get("models").Feed

  ###
  # socket.io events
  ###

  addFeed:(socket,data) -> 
    streamname = decodeURIComponent data.stream
    Stream.findByTitle streamname, (err,stream)->
      return socket.emit 'error' if err
      async.forEach data.urls, (param,cb)->
        Feed.findOneAndUpdate
          title : param.title
          url   : param.url
          stream: stream._id
        ,
          title : param.title
          url   : param.url
          stream: stream._id
          alive : true
          site  : param.siteurl
        , upsert: true,(err,feed)->
          console.error err if err
          cb()
      ,->
        console.info "Stream:#{stream.title} add feed"
        socket.emit 'add-feed succeed'


  editFeedList:(socket,data) ->
    streamname = decodeURIComponent data.stream
    Stream.findByTitle streamname, (err,stream)->
      return socket.emit 'error' if err
      Feed.find stream:stream._id,{},{},(err,feeds)->
        return socket.emit 'error' if err
        async.forEach feeds, (feed,cb)->
          if feed.url in data.urls
            feed.alive = true
            feed.save()
          else
            feed.alive = false
            feed.save()
          cb()
        , ->
          socket.emit 'edit completed'



