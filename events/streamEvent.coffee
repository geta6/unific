###

  StreamEvent.coffee

###

module.exports.StreamEvent = (app) ->

  async  = require 'async'
  parser = require 'parse-rss'
  RSS    = require 'rss'
  _      = require 'underscore'
  url    = require 'url'

  Stream = app.get("models").Stream
  Feed   = app.get("models").Feed
  Page   = app.get("models").Page

  domain = app.get 'domain'

  ###
  # http request
  ###

  index: (req,res,next) ->
    title = req.params.stream
    Stream.findByTitle title,(err,stream)->
      if stream?
        return render(res,stream)
      else
        Stream.create 
          title:title
          description:'description (click to edit)'
        ,(err,stream)->
          return render(res,stream)

  rss  : (req,res,next) ->
    streamname = req.params.stream
    @findArticlesByStream streamname,'', (err,articles)->
      return socket.emit 'error' if err
      # lets create an rss feed 
      feed = new RSS
        title: "#{streamname} - Unific"
        description: "Generated By Unific"
        feed_url: "http://unific.net/#{streamname}rss"
        site_url: "http://unific.net/#{streamname}"
        author: "Unific"
        webMaster: "nikezono"
        copyright: "2013 nikezono.net"
        pubDate: articles[0].page.pubDate
      
      async.forEach articles,(article,cb)->
        # loop over data and add to feed 
        feed.item
          title: article.page.title
          description: article.page.description
          url: article.page.url
          author: article.feed.title # optional - defaults to feed author property
          date: article.page.pubDate
        cb()
      ,->
        xml = feed.xml()
        res.set
          "Content-Type": "text/xml"
        res.send xml

  ###
  # socket.io events
  ###
  getFeedList: (socket,stream) ->
    streamname = decodeURIComponent stream
    Stream.findOne title:streamname,(err,stream)->
      return socket.emit 'error' if err
      Feed.find stream:stream._id,{},{},(err,feeds)->
        return socket.emit 'error' if err or (feeds.length is 0)
        socket.emit 'got feed_list', feeds

  sync : (socket,stream) ->
    streamname = decodeURIComponent stream
    @findArticlesByStream streamname,'', (err,articles)->
      return socket.emit 'error' if err
      # Sync Completed
      socket.emit 'sync completed',  articles
      console.log "#{socket.id} is sync"

      

  changeDesc: (socket,io,data) ->
    streamname = decodeURIComponent data.stream
    Stream.findOne title:streamname, (err,stream)->
      return socket.emit 'error' if err
      stream.description = data.text
      stream.save()
      socket.broadcast.to(data.stream).emit 'desc changed',
        text:data.text


  ###
  # Helper Methods
  ###

  # ストリームからArticlesを再帰的に探してきてマージする
  # 重い
  # @streamname  [String] ストリームの名前
  # @parent      [String](Optional) 親ストリームの名前（再帰）
  # @callback    [Function](err,feeds)  マージされたフィード
  findArticlesByStream: (streamname,parent,callback)->
    that = @
    Stream.findOne title:streamname,(err,stream)->
      return callback err,null if err
      # Feedの検索
      Feed.find 
        stream:stream._id
        alive :true
      ,{},{},(err,feeds)->
        feed_pages = []
        # 各ArticleのMerge
        async.forEach feeds,(feed,cb)->
          urlObj = url.parse(feed.url)

          # 親子関係のときobjectを返す
          if urlObj.hostname in domain
            substreamname = urlObj.pathname.split('/')[1]
            # ループ離脱（フォロー相手に自分が含まれていれば除く)
            if substreamname is parent
              cb()
            else
              that.findArticlesByStream substreamname,streamname,(err,pages)->
                feed_pages = feed_pages.concat pages
                cb()
          else
            # 外部サイト
            parser feed.url, (articles)->
              Page.findAndUpdateByArticles articles,feed,(pages)->
                return callback err,null if err
                feed_pages = feed_pages.concat pages
                cb()
        ,->
          #ヌル記事の削除
          delnulled = _.filter feed_pages,(obj)->
            return false unless obj.page?
            return true

          # uniqued
          uniqued = _.uniq delnulled,false,(obj)->
            return obj.page.link or obj.page.title or obj.page.description or obj.page.url

          async.parallel [(cb)->
            ## スター付きの記事を抽出
            starred = _.filter uniqued, (obj)->
              return obj.page.starred is true
            cb(null,starred)
          ,(cb)->
            ## スター無しから更新昇順50件

            unstarred = _.filter uniqued, (obj)->
              return obj.page.starred is false

            # sorted(更新昇順)
            sorted = _.sortBy unstarred, (obj)->
              return obj.page.pubDate.getTime()

            # limited(昇順50件)
            limited = sorted.slice sorted.length-50 if sorted.length > 50
            cb(null,limited or sorted)
          ],(err,results)->
            merged = results[0].concat(results[1])
            res  = _.sortBy merged, (obj)->
              return obj.page.pubDate.getTime()

            return callback null, res


###
# Private Methods
###
render = (res,stream)->
  console.log stream.background
  res.render 'stream',
    title: stream.title
    description: stream.description
    background:stream.background
    feeds: stream.feeds
    rss  : "/#{stream.title}/rss"