!function(){$(function(){var e,t,n,i,o,d,r,c;return $(".alert").hide(),$("button.close").click(function(e){return e.currentTarget.parentElement.style.display="none"}),c=io.connect(),r=window.location.pathname.substr(1),t=[],o=!0,e=$("#Articles"),c.on("connect",function(){var e;return d()?(c.emit("connect stream",r),o&&(c.emit("sync stream",r),0===t.length&&$("#NoFeedIsAdded").show(),o=!1),setInterval(function(){return console.log("sync"),c.emit("sync stream",r)},6e4),$("#FindFeedButton").click(function(){var e;return $("#NoFeedIsFound").hide(),e=$("#FindFeedInput").val(),c.emit("find feed",e)}),c.on("found feed",function(e,t){var n,i,o,d;if(null!=e&&$("#NoFeedIsFound").show(),null!=t.candidates){for($("#CandidatesModalWindow").find("#CandidatesList").html(""),d=t.candidates,i=0,o=d.length;o>i;i++)n=d[i],n.sitetitle=""+n.sitename+" - "+(n.title||"feed"),n.url=t.siteurl,$("#CandidatesList").append(ViewHelper.candCheckbox(n));return $("#CandidatesModalWindow").modal()}}),c.on("sync completed",function(o){return i(t,o,function(i){var o,d,r;for(i.length>0?console.log("new article added"):console.log("no article added"),t=t.concat(i),t=_.uniq(t,function(e){return e.page.link||e.page._id}),i=_.sortBy(i,function(e){return Date.parse(e.page.pubDate)}),0!==t.length&&$("#NoFeedIsAdded").hide(),d=0,r=i.length;r>d;d++)o=i[d],n(o);return e(),i.length>0?$("#NewArticleIsAdded").show().fadeIn(500):void 0})}),$("#EditFeedButton").click(function(){return c.emit("get feed_list",r)}),c.on("got feed_list",function(e){var t,n,i;if(null!=e){for($("#EditFeedModalWindow").find("#FeedList").html(""),n=0,i=e.length;i>n;n++)t=e[n],$("#FeedList").append(ViewHelper.feedList(t));return $("#EditFeedModalWindow").modal()}}),$("#ApplyEditFeedButton").click(function(){var e;return e=[],$("#EditFeedModalWindow").find("#FeedList").find(":checkbox:checked").each(function(){return e.push($(this).attr("url"))}),c.emit("edit feed_list",{urls:e,stream:r})}),c.on("edit completed",function(){return $("#FeedListIsEditted").show(),console.log("sync by feed_list editted"),c.emit("sync stream",r)}),$("#AddFeedButton").click(function(){var e;return e=[],$("#CandidatesList").find(":checkbox:checked").each(function(){return e.push({url:$(this).val(),title:$(this).attr("title"),siteurl:$(this).attr("siteurl")})}),0!==e.length?c.emit("add feed",{urls:e,stream:r}):void 0}),c.on("add-feed succeed",function(){return $("#NewFeedIsAdded").show(),console.log("sync"),c.emit("sync stream",r)}),e=function(){return $(".btn-toggle").click(function(){var e;return e=$(this).parent(),"Close"===$(this).text()?(e.find("p.desc").show(),e.find("p.contents").hide(),$(this).text("Read More")):""!==e.find("p.contents").text()?(e.find("p.desc").hide(),e.find("p.contents").show(),e.find(".btn-toggle").text("Close")):c.emit("get page",{domid:e.attr("id"),url:e.find("a").attr("href")})}),c.on("got page",function(e){var t,n;return n=decodeURIComponent(e.res.content),t=$(document).find("#"+e.domid),t.find("p.desc").hide(),t.find("p.contents").show(),t.find("p.contents").html(n),t.find(".btn-toggle").text("Close")}),$(".submitComment").click(function(){var e,t;return e=$(this).parent(),t=e.find(".inputComment").val(),null!=t?c.emit("add comment",{domid:e.attr("id"),comment:t}):void 0}),c.on("comment added",function(e){var t,n,i,o,d;for(t=$(document).find("#"+e.domid),t.find(".comments").html(""),d=e.comments,i=0,o=d.length;o>i;i++)n=d[i],t.find(".comments").append("<blockquote>"+n+"</blockquote>");return t.find(".commentsLength").text(e.comments.length)}),c.on("error",function(){return $("#SomethingWrong").show()})}):$("#GoButton").click(function(){return window.location.href=$("#GoInput").val()})}),d=function(){return""===r?!1:!0},i=function(e,t,n){var i,o;return o=_.map(e,function(e){return e.page._id}),i=_.filter(t,function(e){return _.contains(o,e.page._id)?!1:!0}),n(i)},n=function(t){var n,i,o,d,r,c,s,a,l,u;for(s={title:t.page.title,id:t.page._id,comments:t.page.comments,description:t.page.description,pubDate:t.page.pubDate,url:t.page.url,sitename:t.feed.title,siteurl:t.feed.site},i="",u=t.page.comments,a=0,l=u.length;l>a;a++)n=u[a],i+=ViewHelper.comment(n);return r=e.find("li:first").attr("pubDate"),o=Date.parse(s.pubDate),c=e.find("li:first").find("h4").text(),d=s.title,o>=r||void 0===r&&c!==d?e.prepend(ViewHelper.mediaHead(s)+i+ViewHelper.mediaFoot()).hide().fadeIn(500):void 0}})}.call(this);