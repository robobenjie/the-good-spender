(function() {
  var money_updater;
  window.SETUP = {};
  money_updater = {};
  SETUP.add_user = function(CORE, user) {
    var add_error, errors;
    $('#save-btn').click(function() {
      CORE.change_main_panel('sign-up');
      return CORE.hideModal();
    });
    $('#try-now-btn').click(function() {
      return CORE.change_main_panel('queue');
    });
    $('#cancel-account-create-btn').click(function() {
      return CORE.change_main_panel('queue');
    });
    $('#user-name-box').focus(function(e) {
      return $('#sign-up-tips').html('My name is Benjie, what\'s yours?');
    });
    $('#user-email-box').focus(function(e) {
      return $('#sign-up-tips').html("Nice to meet you, " + ($('#user-name-box').val()) + ". What's your email?");
    });
    $('#user-password-box').focus(function(e) {
      return $('#sign-up-tips').html('Time to pick a password. Everyone loves picking passwords, right?');
    });
    $('#user-password-repeat-box').focus(function(e) {
      return $('#sign-up-tips').html('In accordance with tradition, you must type your password twice. This is the last step!');
    });
    $('#user-password-repeat-box').keyup(function(e) {
      if ($('#user-password-repeat-box').val() === $('#user-password-box').val()) {
        $('#user-repeat-password-clearfix').addClass("success");
        $('#user-repeat-password-clearfix').removeClass("error");
        return $('#repeat-password-tip').html('Match!');
      } else {
        $('#user-repeat-password-clearfix').addClass("error");
        $('#user-repeat-password-clearfix').removeClass("success");
        return $('#repeat-password-tip').html('Passwords do not yet match');
      }
    });
    errors = false;
    add_error = function(str) {
      $('#sign-up-errors').append('<p class="alert-message error">' + str + '</p>');
      return errors = true;
    };
    return $('#sign-up-btn').click(function() {
      $('#sign-up-errors').html("");
      if ($('#user-name-box').val() === "") {
        add_error("You need to enter a name");
      }
      if ($('#user-email-box').val() === "") {
        add_error("You left your email blank");
      }
      if ($('#user-password-box').val() === "") {
        add_error("You need to enter a password");
      }
      if ($('#user-password-repeat-box').val() !== $('#user-password-box').val()) {
        add_error("your passwords need to match");
      }
      if (!errors) {
        user.email = $('#user-email-box').val();
        user.name = $('#user-name-box').val();
        user.password = $('#user-password-box').val();
        return IO.save_data(user, function() {
          IO.get_data(user.email, user.password);
          CORE.change_main_panel('queue');
          $('.logged-in').show();
          return $('.not-logged-in').hide();
        });
      }
    });
  };
  SETUP.on_user_change = function(user, CORE) {
    $('#money-rate').off();
    $('#money-rate').keyup(function() {
      user.rate = UTILS.dpm_to_dps(Math.max(1, $('#money-rate').val()));
      return CORE.display_money(user);
    });
    $('#money-rate').change(function() {
      var rate;
      rate = $('#money-rate').val();
      if ($.isNumeric(rate)) {
        user.rate = UTILS.dpm_to_dps($('#money-rate').val());
        return IO.save_data(user);
      } else {
        return alert("That monthly rate is not a number");
      }
    });
    $('#create-btn').off();
    $('#create-btn').click(function() {
      return CORE.create_item(user);
    });
    $('#price-box, #name-box').off();
    $('#price-box, #name-box').keyup(function(e) {
      if (e.which === 13) {
        return CORE.create_item(user, "add");
      }
    });
    $('#name-box').keyup(function() {
      return IO.get_images_amazon($('#name-box').val(), function(response) {
        var img_data, target, _i, _len, _ref, _results;
        target = $('#new-item-image-div');
        target.html(' ');
        _ref = response.slice(0, 7);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          img_data = _ref[_i];
          _results.push(target.append("<img src=\"" + img_data.SmallImageUrl + "\"></img>"));
        }
        return _results;
      });
    });
    $('#add-money-box').off();
    $('#add-money-box').keyup(function(e) {
      if (e.which === 13) {
        return CORE.submit_money_change_form(user, "add");
      }
    });
    $('#subtract-money-box').off();
    $('#subtract-money-box').keyup(function(e) {
      if (e.which === 13) {
        return CORE.submit_money_change_form(user, "subtract");
      }
    });
    $('#add-money-btn').off();
    $('#add-money-btn').click(function() {
      return CORE.submit_money_change_form(user, "add");
    });
    $('#subtract-money-btn').off();
    $('#subtract-money-btn').click(function() {
      return CORE.submit_money_change_form(user, "subtract");
    });
    clearInterval(money_updater);
    return money_updater = setInterval(function() {
      return CORE.update_cash(user);
    }, 100);
  };
}).call(this);
