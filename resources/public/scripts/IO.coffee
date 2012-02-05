window.IO = {}

do_ajax = (mtype, object, callback = ()->)->
  json_obj = JSON.stringify {mtype, object}
  $.post "/", {"send_object": json_obj}, callback

IO.get_data = (username, password, callback = (obj)-> ) ->
  do_ajax "get-data", {email: username, password: password},
    (result) ->
      user = JSON.parse result
      time = new Date()
      callback user, time
      #because it is Asynchronous, get_data returns something crazy

IO.save_data = (dataObj, callback = ()->) ->
  if dataObj.email
    do_ajax "save-data",  dataObj, callback