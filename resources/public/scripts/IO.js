(function() {
  var do_ajax;
  window.IO = {};
  do_ajax = function(mtype, object, callback) {
    var json_obj;
    if (callback == null) {
      callback = function() {};
    }
    json_obj = JSON.stringify({
      mtype: mtype,
      object: object
    });
    return $.post("/", {
      "send_object": json_obj
    }, callback);
  };
  IO.log_out = function(callback) {
    if (callback == null) {
      callback = function() {};
    }
    return do_ajax("log-out", {}, function(result) {
      return callback(result);
    });
  };
  IO.get_data = function(data_obj, callback) {
    if (callback == null) {
      callback = function(obj) {};
    }
    return do_ajax("get-data", data_obj, function(result) {
      var time, user, _ref;
      user = JSON.parse(result);
      user.password = (_ref = data_obj.password) != null ? _ref : "";
      time = new Date();
      return callback(user, time);
    });
  };
  IO.save_data = function(dataObj, callback) {
    if (callback == null) {
      callback = function() {};
    }
    if (dataObj.email) {
      return do_ajax("save-data", dataObj, callback);
    }
  };
}).call(this);
