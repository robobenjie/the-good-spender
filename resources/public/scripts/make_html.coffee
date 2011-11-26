window.HTML = {}
HTML.item = (item) ->
  s = "
   <div class=\"queue-item ui-state-default\">
     <div class=\"item-topbar\">
       <h3 style=\"float: left\" class=\"item-name\">  #{item.name} </h3>
       <h3 style=\"float: right\"> $<span class=\"item-price\">#{item.price}</span></h3>
     </div>
     <div class=\"item-image\">
        picture
     </div>
     <div class=\"item-main\">
       <p class=\"item-main-text\"> </p>
        <h4>&nbsp;&nbsp; <span class=\"wait-time\"> </span> </h4>
        <p> &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;<span class=\"buy-date\"> </span><p>
      </div>
     <div class=\"item-buttons\">
        <h4 style=\"float: right\">
        <a class=\"btn delete-item\"> del </a>
        <a class=\"btn buy-item-btn\"> Buy! </a></h4>
     </div>
   </div>
"


HTML.time_string = (seconds) ->
  day = 86400
  month = 31*day
  hour = 3600
  min = 60
  months = Math.floor seconds / month
  seconds = seconds - months * month
  days = Math.floor seconds / day
  seconds = seconds - days * day
  hours = Math.floor seconds / hour
  seconds = seconds - hours * hour
  minutes = Math.floor seconds / min
  seconds = (seconds - minutes * min).toFixed()
  if months > 0
    "in #{months} month#{pluralize months}, #{days} day#{pluralize days} #{zeropad hours}:#{zeropad minutes}:#{zeropad seconds}"
  else if days > 0
    "in #{days} day#{pluralize day} #{zeropad hours}:#{zeropad minutes}:#{zeropad seconds}"
  else
    "in #{zeropad hours}:#{zeropad minutes}:#{zeropad seconds}"
pluralize = (num) ->
  if num is 1
    ""
  else
    "s"
zeropad = (num) ->
  if num < 10
    "0"+num
  else
    num