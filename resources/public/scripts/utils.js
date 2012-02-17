(function() {
  var isArray;
  var __slice = Array.prototype.slice;

  window.UTILS = {};

  UTILS.dps_to_dpm = function(dps) {
    return dps * 2629744;
  };

  UTILS.dpm_to_dps = function(dpm) {
    return dpm / 2629744;
  };

  UTILS.assert = function(exp, message) {
    if (!exp) throw "Assert Error: " + message;
  };

  Function.prototype.method = function(name, fn) {
    return this.prototype[name] = fn;
  };

  isArray = function(a) {
    return object.prototype.toString.apply(a === '[object Array]');
  };

  String.method("repeat", function(times) {
    return (new Array(times + 1)).join(this);
  });

  String.method("trim", function() {
    return this.replace(/^\s+|\s+$/g, "");
  });

  String.method("dasherize", function() {
    return this.trim().replace(/\s+|_/g, "-");
  });

  String.method("underscorize", function() {
    return this.trim().replace(/\s+|-/g, "_");
  });

  Function.method("curry", function() {
    var c_args;
    var _this = this;
    c_args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return function() {
      var l_args;
      l_args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return _this.apply(null, c_args.concat(l_args));
    };
  });

  Array.method("reduce", function(f, value) {
    var elem, _i, _len;
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      elem = this[_i];
      if (!(value != null)) {
        value = elem;
      } else {
        value = f(value, elem);
      }
    }
    return value;
  });

  Math.randomInt = function(max, min) {
    var _ref;
    if (min == null) min = 0;
    if (max < min) _ref = [max, min], min = _ref[0], max = _ref[1];
    return Math.floor(Math.random() * (max - min)) + min;
  };

}).call(this);
