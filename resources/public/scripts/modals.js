(function() {

  /*
  # example code for how to use the modal class:
    test = new Modal "myModal","Title of the Modal", [
        name: "input"
        label: "Some kind of input: "]
      , [
        text: "Click me"
        dont_close: true
        click: (data)-> alert(data.input)]
    test.show()
  */

  var Modal;

  Modal = (function() {

    function Modal(unique_id, title, formElements, buttons) {
      var button, elem, getData, _i, _len;
      var _this = this;
      this.unique_id = unique_id;
      this.title = title;
      this.formElements = formElements;
      this.buttons = buttons;
      this.html = "<div class=\"modal\" id=\"" + unique_id + "\" style=\"display: none; \">\n<form>\n<div class=\"modal-header\">\n  <a id=\"" + unique_id + "-close\" class=\"close\" href=\"#\">x</a>\n  <h3>" + this.title + "</h3>\n</div>\n<div class=\"modal-body\">\n  <div>";
      this.html += (function() {
        var _i, _len, _ref, _ref2, _ref3, _ref4, _results;
        _ref = this.formElements;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          elem = _ref[_i];
          _results.push("<div class=\"clearfix\">\n  <label for=\"" + elem.name + "\">" + elem.label + "</label>\n  <div class=\"input\">\n    <input class=" + ((_ref2 = elem["class"]) != null ? _ref2 : "large") + "\n           id=\"" + (this.unique_id + elem.name) + "\"\n           name=\"" + elem.name + "\"\n           size=\"" + ((_ref3 = elem.size) != null ? _ref3 : 30) + "\"\n           type=\"" + ((_ref4 = elem.type) != null ? _ref4 : "text") + "\">\n  </div>\n</div>");
        }
        return _results;
      }).call(this);
      this.html += "  </div>\n</div>\n<div class=\"modal-footer\">\n  <div>";
      this.html += (function() {
        var _i, _len, _ref, _results;
        _results = [];
        for (_i = 0, _len = buttons.length; _i < _len; _i++) {
          button = buttons[_i];
          _results.push("<a class=\"btn " + ((_ref = button["class"]) != null ? _ref : "") + "\"\nid=\"" + (this.unique_id + button.text.dasherize()) + "\">" + button.text + "</a>");
        }
        return _results;
      }).call(this);
      this.html += "  </div>\n</div>\n</form>\n</div>";
      $('body').append(this.html);
      getData = function() {
        var elem, ret, _i, _len, _ref;
        ret = {};
        _ref = _this.formElements;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          elem = _ref[_i];
          ret[elem.name] = $("#" + (_this.unique_id + elem.name)).val();
        }
        return ret;
      };
      for (_i = 0, _len = buttons.length; _i < _len; _i++) {
        button = buttons[_i];
        $("#" + (this.unique_id + button.text.dasherize())).click(function() {
          button.click(getData());
          if (!button.dont_close) return $("#" + unique_id).hide();
        });
      }
      $("#" + this.unique_id + "-close").click(function() {
        return $("#" + unique_id).hide();
      });
    }

    Modal.prototype.show = function() {
      return $("#" + this.unique_id).show();
    };

    Modal.prototype.hide = function() {
      return $("#" + this.unique_id).hide();
    };

    return Modal;

  })();

  window.Modal = Modal;

}).call(this);
