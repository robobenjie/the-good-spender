###
# example code for how to use the modal class:
  test = new Modal "myModal","Title of the Modal", [
      name: "input"
      label: "Some kind of input: "]
    , [
      text: "Click me"
      dont_close: true
      click: (data)-> alert(data.input)]
  test.show()
###


class Modal
  constructor: (@unique_id, @title, @formElements, @buttons) ->
#    if @prototype.unique_id?
#      @prototype.unique_id = @prototype.unique_id + 1
#    else
#      @prototype.unique_id = 1
#    unique_id = "modal-" + @prototype.unique_id
    @html = """
    <div class="modal" id="#{unique_id}" style="display: none; ">
    <form>
    <div class="modal-header">
      <a id="#{unique_id}-close" class="close" href="#">x</a>
      <h3>#{@title}</h3>
    </div>
    <div class="modal-body">
      <div>"""
    @html += for elem in @formElements
        """
        <div class="clearfix">
          <label for="#{elem.name}">#{elem.label}</label>
          <div class="input">
            <input class=#{elem.class ? "large"}
                   id="#{@unique_id + elem.name}"
                   name="#{elem.name}"
                   size="#{elem.size ? 30}"
                   type="#{elem.type ? "text"}">
          </div>
        </div>
        """
    @html += """
      </div>
    </div>
    <div class="modal-footer">
      <div>
      """
    @html += for button in buttons
        """<a class="btn #{button.class ? ""}"
            id="#{@unique_id + button.text.dasherize()}">#{button.text}</a>"""
      @html += """
      </div>
    </div>
    </form>
    </div>"""
    $('body').append(@html)
    getData = ()=>
      ret = {}
      for elem in @formElements
        ret[elem.name] = $("##{@unique_id + elem.name}").val()
      ret
    for button in buttons
      $("##{@unique_id + button.text.dasherize()}").click ->
        button.click(getData())
        $("##{unique_id}").hide() unless button.dont_close
    $("##{@unique_id}-close").click ->
      $("##{unique_id}").hide()
  show: ->
    $("##{@unique_id}").show()
  hide: ->
    $("##{@unique_id}").hide()
window.Modal = Modal