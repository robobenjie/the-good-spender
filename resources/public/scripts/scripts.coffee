CORE = {}

new_user_obj = (email,name, pw) ->
  {
    email: email
    name: name
    password: pw
    cash: 5.0028
    rate: UTILS.dpm_to_dps 700
    items: [{name: "Blue Suede Shoes", price: 85},{name: "Les Paul Guitar", price: 500}]
  }
CORE.new_user_obj = new_user_obj

updateTime = 0

make_item = (args) ->
  [name, price] = args
  {name: name, price: price}

update_and_save = (user) ->
  updateObj user
  IO.save_data user

updateObj = (user) ->
  user.rate = UTILS.dpm_to_dps $('#money-rate').val()
  user.items = get_items_from_dom()
  return user

get_items_from_dom = ()->
  names = $('.item-name')
  prices = $('.item-price')
  {name: $(name).html(), price: $(prices[i]).html()} for name, i in names

hideModal = () ->
  $('.modal').hide()
CORE.hideModal = hideModal

CORE.create_item = (user) ->
  item = {
  name: $('#name-box').val()
  price: $('#price-box').val()
  }
  $('.make-item-input').val('')
  hideModal()
  $('#queue-div').append(HTML.item item)
  attach_item_button_events(user)
  update_and_save(user)


redraw_items = (user, callback = (->), target = '#queue-div') ->
  list_html = for item in user.items
      HTML.item(item)
  $(target).html list_html.join " "
  $('#money-rate').val((UTILS.dps_to_dpm user.rate).toFixed(2))
  attach_item_button_events(user)

attach_item_button_events = (user) ->
  $('.delete-item').off()
  $('.delete-item').click ->
    deletethis this, user
  $( "#queue-div" ).sortable({stop: ()->update_and_save(user)});
  $( "#queue-div" ).disableSelection()
  $('.buy-item-btn').off()
  $('.buy-item-btn').click ->
    buythis this, user


CORE.display_money = (user, cash = user.cash) ->
  UTILS.assert user, "called display_money without user"
  if not user.rate
    a = 4
    b = 5
  dollars_per_second = user.rate
  date_obj = new Date()
  now = date_obj.getTime()
  $('#money-saved').html(cash.toFixed(2))
  for item_elem in $('.queue-item')
    progressbar = $(item_elem).find('.progressBar')
    progressbar.hide()
    cost =  parseInt($(item_elem).find('.item-price').html())
    cash -= cost if cost
    if cash > 0
      $(item_elem).find('.item-main-text').html('<h1> Buy it now! </h1>')
      $(item_elem).find('.buy-date').html(" ")
      $(item_elem).find('.wait-time').html(" ")
    else
      if cost + cash > 0
        progressbar.progressbar {value: (cash + cost) / cost * 100}
        progressbar.show()

      wait_time = -cash/dollars_per_second
      now = new Date()
      time_to_buy = new Date()
      time_to_buy.setDate(now.getDate() + wait_time/86400)
      $(item_elem).find('.item-main-text').html('you can buy it')
      $(item_elem).find('.buy-date').html( time_to_buy.toLocaleDateString())
      $(item_elem).find('.wait-time').html( HTML.time_string(wait_time))

buythis = (thing, user)->
  amount = parseInt $(thing).closest('.queue-item').find('.item-price').html()
  add_money user, -amount
  deletethis thing, user


deletethis = (thing, user)->
  console.log $(thing)
  $(thing).closest('.queue-item').fadeOut ()=>
    $(thing).closest('.queue-item').html(" ")
    update_and_save user

CORE.update_cash = (user)->
  time = new Date()
  now = time.getTime()
  cash = user.cash + (now - updateTime) * user.rate /1000
  CORE.display_money user, cash

add_money = (user, amount) ->
  user.cash += parseInt amount if $.isNumeric amount
  update_and_save user

CORE.submit_money_change_form = (user, kind) ->
  add_money user, $("##{kind}-money-box").val() * if kind is "add" then 1 else -1
  $("##{kind}-money-box").val("")
  hideModal()

CORE.change_main_panel = (name) ->
  for panel in ["queue","sign-up","about"]
    $(".main-panel-#{panel}").hide()
  $(".main-panel-#{name}").show()
  setTimeout (()->
    if $('.not-logged-in').css('display') isnt "none" and $('.main-panel-queue').css('display') isnt "none"
      $('#save-your-work-modal').show())
  , 100000

setup_blank_user = ()->
  user = new_user_obj()
  time = new Date()
  updateTime = time.getTime()
  return user

login = (user, time) ->
  redraw_items user
  SETUP.on_user_change user, CORE
  $(".sign-up").hide()
  $(".signed-in").show()
  CORE.change_main_panel 'queue'
  updateTime = time
  $('.logged-in').show()
  $('.not-logged-in').hide()


$(document).ready ->
  user = setup_blank_user()
  redraw_items user
  SETUP.on_user_change user, CORE
  $('form').submit(()->return false)
  hideModal()

  $('#sign-in').click ->
    IO.get_data
            email: $("#username-box").val(),
            password: $("#password-box").val(),
            login

  $('.close-modal').click(hideModal)
  $('#new-item').click ->
    $('#create-item-modal').show()
    $('#name-box').focus()
  $('.create-account-btn').click ->
    CORE.change_main_panel('sign-up')
    CORE.hideModal()
  $('#add-money').click ()->
    $('#add-money-modal').show()
    $('#add-money-box').focus()
  $('#subtract-money').click ()->
    $('#subtract-money-modal').show()
    $('#subtract-money-box').focus()
  $('.logged-in').hide()
  IO.get_data {}, (user, time) ->
    if user.email?
      login user, time
  SETUP.add_user(CORE, user)
  CORE.change_main_panel('about')
  IO.get_data



