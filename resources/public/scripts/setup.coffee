window.SETUP = {}

money_updater = {}
# Sets attaches all the events for the signup paec
SETUP.add_user = (CORE, user) ->
  #the sign-your-work modal:
  $('#save-btn').click ->
    CORE.change_main_panel('sign-up')
    CORE.hideModal()
  $('#try-now-btn').click ->
    CORE.change_main_panel('queue')
  $('#cancel-account-create-btn').click ->
    CORE.change_main_panel('queue')
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
      user.email = $('#user-email-box').val()
      user.name =  $('#user-name-box').val()
      user.password = $('#user-password-box').val()

      IO.save_data user, ()->
        IO.get_data user.email, user.password
        CORE.change_main_panel('queue')
        $('.logged-in').show()
        $('.not-logged-in').hide()



# Called whenever the user object changes
# This should be called on each succesful load from the database and
# when you first create a new user on load.
SETUP.on_user_change = (user,CORE)->
    #these have to be called each time userobj is changed
  #take off the old bindings for each one before adding the new ones
  $('#money-rate').off()
  $('#money-rate').keyup ()->
    user.rate = UTILS.dpm_to_dps Math.max 1, $('#money-rate').val()
    CORE.display_money(user)
  $('#money-rate').change ()->
    rate = $('#money-rate').val()
    if $.isNumeric rate
      user.rate = UTILS.dpm_to_dps $('#money-rate').val()
      IO.save_data user
    else
      alert("That monthly rate is not a number")
  $('#create-btn').off()
  $('#create-btn').click(()->CORE.create_item user)
  $('#price-box, #name-box').off()
  $('#price-box, #name-box').keyup (e)->
    CORE.create_item user, "add" if e.which is 13
  $('#name-box').keyup ->
    IO.get_images_amazon $('#name-box').val(), (response) ->
      target = $('#new-item-image-div')
      target.html(' ')
      for img_data in response[0...7]
        target.append """<img src="#{img_data.SmallImageUrl}"></img>"""
  $('#add-money-box').off()
  $('#add-money-box').keyup (e)->
    CORE.submit_money_change_form user, "add" if e.which is 13
  $('#subtract-money-box').off()
  $('#subtract-money-box').keyup (e)->
    CORE.submit_money_change_form user, "subtract" if e.which is 13
  $('#add-money-btn').off()
  $('#add-money-btn').click ()->
    CORE.submit_money_change_form user, "add"
  $('#subtract-money-btn').off()
  $('#subtract-money-btn').click () ->
    CORE.submit_money_change_form user, "subtract"
  clearInterval money_updater
  money_updater = setInterval ()->
    CORE.update_cash(user)
  , 100
