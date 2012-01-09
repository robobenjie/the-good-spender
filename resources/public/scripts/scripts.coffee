#user object is of the form:
# {
  # email: "bmholson@gmail.com"
  # name: "Benjamin Holson"
  # password: "s3cr3t"
  # cash: 453
  # rate: .0001
  # items:
    # [item1, item2, item3, item4]
# }
#
nop = ()->
new_user_obj = (email,name, pw) ->
  {
    email: email
    name: name
    password: pw
    cash: 0
    rate: 0
    items: []
  }

userobj = {}
updateTime = 0

make_item = (args) ->
  [name, price] = args
  {name: name, price: price}

do_ajax = (mtype, object, callback = ()->)->
  json_obj = JSON.stringify {mtype, object}
  $.post "/", {"send_object": json_obj}, callback

getData = (username, password, callback = (obj)-> ) ->
  do_ajax "get-data", {email: username, password: password},
    (result) ->
      userobj = JSON.parse result
      time = new Date()
      updateTime = time.getTime()
      callback userobj

saveData = (dataObj = userobj, callback = nop) ->
  do_ajax "save-data",  updateObj(dataObj), callback

updateObj = (user) ->
  user.rate = dpm_to_dps $('#money-rate').val()
  user.items = get_items_from_dom()
  user

get_items_from_dom = ()->
  names = $('.item-name')
  prices = $('.item-price')
  {name: $(name).html(), price: $(prices[i]).html()} for name, i in names

hideModal = () ->
  $('.modal').hide()

create_item = () ->
  item = {
  name: $('#name-box').val()
  price: $('#price-box').val()
  }
  $('.make-item-input').val(' ')
  hideModal()
  $('#queue-div').append(HTML.item item)
  attach_item_button_events()
  saveData()


dps_to_dpm = (dps)-> # dollars per second -> dollars per month
  dps*2629744
dpm_to_dps = (dpm)->
  dpm/2629744



redraw_items = (user, callback = nop, target = '#queue-div') ->
  list_html = for item in userobj.items
      HTML.item(item)
  $(target).html list_html.join " "
  $('#money-rate').val((dps_to_dpm user.rate).toFixed(2))
  $('#money-rate').keyup ()->
    user.rate = dpm_to_dps Math.max 1, $('#money-rate').val()
  $('#money-rate').change ()->
    rate = $('#money-rate').val()
    if $.isNumeric rate
      user.rate = dpm_to_dps $('#money-rate').val()
      saveData user
    else
      alert("That monthly rate is not a number")
  attach_item_button_events()
  callback()

attach_item_button_events = () ->
  $('.delete-item').click(deletethis)
  $( "#queue-div" ).sortable({stop: ()->save_reordering()});
  $( "#queue-div" ).disableSelection()
  $('.buy-item-btn').click(buythis)


display_money = (user, cash) ->
  dollars_per_second = user.rate
  date_obj = new Date()
  now = date_obj.getTime()
  $('#money-saved').html(cash.toFixed(2))
  for item_elem in $('.queue-item')
    cost =  parseInt($(item_elem).find('.item-price').html())
    cash -= cost if cost
    if cash > 0
      $(item_elem).find('.item-main-text').html('<h1> Buy it now! </h1>')
      $(item_elem).find('.buy-date').html(" ")
      $(item_elem).find('.wait-time').html(" ")
    else
      wait_time = -cash/dollars_per_second
      now = new Date()
      time_to_buy = new Date()
      time_to_buy.setDate(now.getDate() + wait_time/86400)
      $(item_elem).find('.item-main-text').html('you can buy it')
      $(item_elem).find('.buy-date').html( time_to_buy.toLocaleDateString())
      $(item_elem).find('.wait-time').html( HTML.time_string(wait_time))

buythis = ()->
  amount = parseInt $(this).closest('.queue-item').find('.item-price').html()
  add_money userobj, -amount
  $(this).closest('.queue-item').fadeOut ()=>
    $(this).closest('.queue-item').html(" ")
    saveData()


save_reordering = ()->
  saveData()

deletethis = ()->
  $(this).closest('.queue-item').fadeOut ()=>
    $(this).closest('.queue-item').html(" ")
    saveData()


update_cash = (user)->
  time = new Date()
  now = time.getTime()
  cash = user.cash + (now - updateTime) * user.rate /1000
  display_money user, cash

add_money = (user, amount) ->
  user.cash += parseInt amount if $.isNumeric amount
  saveData()

submit_money_change_form = (kind) ->
  add_money userobj, $("##{kind}-money-box").val() * if kind is "add" then 1 else -1
  $("##{kind}-money-box").val("")
  hideModal()

setup_add_user = () ->
  $('#user-name-box').focus (e) ->
    $('#sign-up-tips').html('My name is Benjie, what\'s yours?')
  $('#user-email-box').focus (e) ->
    $('#sign-up-tips').html("Nice to meet you, #{$('#user-name-box').val()}. What's your email?")
  $('#user-password-box').focus (e) ->
    $('#sign-up-tips').html('Time to pick a password. Everyone loves picking passwords, right?')
  $('#user-password-repeat-box').focus (e) ->
    $('#sign-up-tips').html('In accordance with tradition, you must type your password twice. This is the last step!')
  $('#user-password-repeat-box').keyup (e) ->
    if $('#user-password-repeat-box').val() == $('#user-password-box').val()
      $('#user-repeat-password-clearfix').addClass("success")
      $('#user-repeat-password-clearfix').removeClass("error")
      $('#repeat-password-tip').html('Match!')
    else
      $('#user-repeat-password-clearfix').addClass("error")
      $('#user-repeat-password-clearfix').removeClass("success")
      $('#repeat-password-tip').html('Passwords do not yet match')
  errors = false
  add_error = (str) ->
    $('#sign-up-errors').append('<p class="alert-message error">'+str+'</p>')
    errors = true
  $('#sign-up-btn').click () ->
    $('#sign-up-errors').html("")
    if $('#user-name-box').val() is ""
      add_error "You need to enter a name"
    if $('#user-email-box').val() is ""
      add_error "You left your email blank"
    if $('#user-password-box').val() is ""
      add_error "You need to enter a password"
    if $('#user-password-repeat-box').val() != $('#user-password-box').val()
      add_error "your passwords need to match"
    if not errors
      user_obj = new_user_obj $('#user-email-box').val(), $('#user-name-box').val(), $('#user-password-box').val()
      saveData user_obj, ()->
        getData user_obj.email, user_obj.password
        $(".sign-up").hide()
        $(".signed-in").show()
        $('#create-item-modal').show()

$(document).ready ->
  $('#sign-in').click ->
    getData $("#username-box").val(),
            $("#password-box").val(),
            ->
              redraw_items(userobj)
              $(".sign-up").hide()
              $(".signed-in").show()
  hideModal()

  $('form').submit(()->return false)
  $('.close-modal').click(hideModal)
  $('#new-item').click(()->$('#create-item-modal').show())
  $('#create-btn').click(create_item)
  $('#add-money').click ()->
    $('#add-money-modal').show()
    $('#add-money-box').focus()
  $('#subtract-money').click ()->
    $('#subtract-money-modal').show()
    $('#subtract-money-box').focus()
  $('#add-money-box').keyup (e)->
    submit_money_change_form "add" if e.which is 13
  $('#subtract-money-box').keyup (e)->
    submit_money_change_form "subtract" if e.which is 13
  $('#add-money-btn').click ()->
    submit_money_change_form "add"
  $('#subtract-money-btn').click () ->
    submit_money_change_form "subtract"
  setup_add_user()
  $(".signed-in").hide()

  repeat 100, ()->update_cash(userobj)
