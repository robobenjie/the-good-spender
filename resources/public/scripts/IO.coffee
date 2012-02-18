window.IO = {}

do_ajax = (mtype, object, callback = ()->)->
  json_obj = JSON.stringify {mtype, object}
  $.post "/", {"send_object": json_obj}, callback

IO.log_out = (callback = ->) ->
  do_ajax "log-out", {}, (result) ->
    callback(result)

IO.get_data = (data_obj, callback = (obj)-> ) ->
  do_ajax "get-data", data_obj,
    (result) ->
      user = JSON.parse result
      user.password = data_obj.password ? "" #stuff password back in because the server doesn't store it
      time = new Date()
      callback user, time
      #because it is Asynchronous, get_data returns something crazy

IO.save_data = (dataObj, callback = ()->) ->
  if dataObj.email
    do_ajax "save-data",  dataObj, callback