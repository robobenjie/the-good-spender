(function() {
  var do_ajax;

  window.IO = {};

  do_ajax = function(mtype, object, callback) {
    var json_obj;
    if (callback == null) callback = function() {};
    json_obj = JSON.stringify({
      mtype: mtype,
      object: object
    });
    return $.post("/", {
      "send_object": json_obj
    }, callback);
  };

  IO.get_data = function(username, password, callback) {
    if (callback == null) callback = function(obj) {};
    return do_ajax("get-data", {
      email: username,
      password: password
    }, function(result) {
      var time, user;
      user = JSON.parse(result);
      user.password = password;
      time = new Date();
      return callback(user, time);
    });
  };

  IO.save_data = function(dataObj, callback) {
    if (callback == null) callback = function() {};
    if (dataObj.email) return do_ajax("save-data", dataObj, callback);
  };

}).call(this);
