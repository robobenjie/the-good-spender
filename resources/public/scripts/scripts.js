(function() {
  var CORE, add_money, attach_item_button_events, buythis, deletethis, get_items_from_dom, hideModal, login, make_item, new_user_obj, redraw_items, setup_blank_user, updateObj, updateTime, update_and_save;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  CORE = {};
  new_user_obj = function(email, name, pw) {
    return {
      email: email,
      name: name,
      password: pw,
      cash: 5.0028,
      rate: UTILS.dpm_to_dps(700),
      items: [
        {
          name: "Blue Suede Shoes",
          price: 85,
          image_url: "http://ecx.images-amazon.com/images/I/31knX6ttILL._SL75_.jpg"
        }, {
          name: "Les Paul Guitar",
          price: 500,
          image_url: "http://ecx.images-amazon.com/images/I/31OWUS38ndL._SL75_.jpg"
        }
      ]
    };
  };
  CORE.new_user_obj = new_user_obj;
  updateTime = 0;
  make_item = function(args) {
    var name, price;
    name = args[0], price = args[1];
    return {
      name: name,
      price: price
    };
  };
  update_and_save = function(user) {
    updateObj(user);
    return IO.save_data(user);
  };
  updateObj = function(user) {
    user.rate = UTILS.dpm_to_dps($('#money-rate').val());
    user.items = get_items_from_dom();
    return user;
  };
  get_items_from_dom = function() {
    var i, name, names, prices, _len, _results;
    names = $('.item-name');
    prices = $('.item-price');
    _results = [];
    for (i = 0, _len = names.length; i < _len; i++) {
      name = names[i];
      _results.push({
        name: $(name).html(),
        price: $(prices[i]).html()
      });
    }
    return _results;
  };
  hideModal = function() {
    return $('.modal').hide();
  };
  CORE.hideModal = hideModal;
  CORE.create_item = function(user) {
    var item;
    item = {
      name: $('#name-box').val(),
      price: $('#price-box').val()
    };
    $('.make-item-input').val('');
    hideModal();
    $('#queue-div').append(HTML.item(item));
    attach_item_button_events(user);
    return update_and_save(user);
  };
  redraw_items = function(user, callback, target) {
    var item, list_html;
    if (callback == null) {
      callback = (function() {});
    }
    if (target == null) {
      target = '#queue-div';
    }
    list_html = (function() {
      var _i, _len, _ref, _results;
      _ref = user.items;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        _results.push(HTML.item(item));
      }
      return _results;
    })();
    $(target).html(list_html.join(" "));
    $('#money-rate').val((UTILS.dps_to_dpm(user.rate)).toFixed(2));
    return attach_item_button_events(user);
  };
  attach_item_button_events = function(user) {
    $('.delete-item').off();
    $('.delete-item').click(function() {
      return deletethis(this, user);
    });
    $("#queue-div").sortable({
      stop: function() {
        return update_and_save(user);
      }
    });
    $("#queue-div").disableSelection();
    $('.buy-item-btn').off();
    return $('.buy-item-btn').click(function() {
      return buythis(this, user);
    });
  };
  CORE.display_money = function(user, cash) {
    var a, b, cost, date_obj, dollars_per_second, item_elem, now, progressbar, time_to_buy, wait_time, _i, _len, _ref, _results;
    if (cash == null) {
      cash = user.cash;
    }
    UTILS.assert(user, "called display_money without user");
    if (!user.rate) {
      a = 4;
      b = 5;
    }
    dollars_per_second = user.rate;
    date_obj = new Date();
    now = date_obj.getTime();
    $('#money-saved').html(cash.toFixed(2));
    _ref = $('.queue-item');
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item_elem = _ref[_i];
      progressbar = $(item_elem).find('.progressBar');
      progressbar.hide();
      cost = parseInt($(item_elem).find('.item-price').html());
      if (cost) {
        cash -= cost;
      }
      _results.push(cash > 0 ? ($(item_elem).find('.item-main-text').html('<h1> Buy it now! </h1>'), $(item_elem).find('.buy-date').html(" "), $(item_elem).find('.wait-time').html(" ")) : (cost + cash > 0 ? (progressbar.progressbar({
        value: (cash + cost) / cost * 100
      }), progressbar.show()) : void 0, wait_time = -cash / dollars_per_second, now = new Date(), time_to_buy = new Date(), time_to_buy.setDate(now.getDate() + wait_time / 86400), $(item_elem).find('.item-main-text').html('you can buy it'), $(item_elem).find('.buy-date').html(time_to_buy.toLocaleDateString()), $(item_elem).find('.wait-time').html(HTML.time_string(wait_time))));
    }
    return _results;
  };
  buythis = function(thing, user) {
    var amount;
    amount = parseInt($(thing).closest('.queue-item').find('.item-price').html());
    add_money(user, -amount);
    return deletethis(thing, user);
  };
  deletethis = function(thing, user) {
    console.log($(thing));
    return $(thing).closest('.queue-item').fadeOut(__bind(function() {
      $(thing).closest('.queue-item').html(" ");
      return update_and_save(user);
    }, this));
  };
  CORE.update_cash = function(user) {
    var cash, now, time;
    time = new Date();
    now = time.getTime();
    cash = user.cash + (now - updateTime) * user.rate / 1000;
    return CORE.display_money(user, cash);
  };
  add_money = function(user, amount) {
    if ($.isNumeric(amount)) {
      user.cash += parseInt(amount);
    }
    return update_and_save(user);
  };
  CORE.submit_money_change_form = function(user, kind) {
    add_money(user, $("#" + kind + "-money-box").val() * (kind === "add" ? 1 : -1));
    $("#" + kind + "-money-box").val("");
    return hideModal();
  };
  CORE.change_main_panel = function(name) {
    var panel, _i, _len, _ref;
    _ref = ["queue", "sign-up", "about"];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      panel = _ref[_i];
      $(".main-panel-" + panel).hide();
    }
    $(".main-panel-" + name).show();
    return setTimeout((function() {
      if ($('.not-logged-in').css('display') !== "none" && $('.main-panel-queue').css('display') !== "none") {
        return $('#save-your-work-modal').show();
      }
    }), 100000);
  };
  setup_blank_user = function() {
    var time, user;
    user = new_user_obj();
    time = new Date();
    updateTime = time.getTime();
    return user;
  };
  login = function(user, time) {
    redraw_items(user);
    SETUP.on_user_change(user, CORE);
    $(".sign-up").hide();
    $(".signed-in").show();
    CORE.change_main_panel('queue');
    updateTime = time;
    $('.logged-in').show();
    return $('.not-logged-in').hide();
  };
  $(document).ready(function() {
    var user;
    user = setup_blank_user();
    redraw_items(user);
    SETUP.on_user_change(user, CORE);
    $('form').submit(function() {
      return false;
    });
    hideModal();
    $('#log-out-btn').click(function() {
      return IO.log_out(function() {
        return location.reload(true);
      });
    });
    $('#sign-in').click(function() {
      return IO.get_data({
        email: $("#username-box").val(),
        password: $("#password-box").val()
      }, login);
    });
    $('.close-modal').click(hideModal);
    $('#new-item').click(function() {
      $('#create-item-modal').show();
      return $('#name-box').focus();
    });
    $('.create-account-btn').click(function() {
      CORE.change_main_panel('sign-up');
      return CORE.hideModal();
    });
    $('#add-money').click(function() {
      $('#add-money-modal').show();
      return $('#add-money-box').focus();
    });
    $('#subtract-money').click(function() {
      $('#subtract-money-modal').show();
      return $('#subtract-money-box').focus();
    });
    $('.logged-in').hide();
    IO.get_data({}, function(user, time) {
      if (user.email != null) {
        return login(user, time);
      }
    });
    SETUP.add_user(CORE, user);
    CORE.change_main_panel('about');
    return IO.get_data;
  });
}).call(this);
