window.UTILS = {}

UTILS.dps_to_dpm = (dps)-> # dollars per second -> dollars per month
  dps*2629744
UTILS.dpm_to_dps = (dpm)->
  dpm/2629744

UTILS.assert = (exp, message) ->
  if not exp
    throw "Assert Error: " + message
#Add a handy way to attach methods to objects a la Javascript the Good Parts
Function.prototype.method = (name, fn) ->
  @prototype[name] = fn

isArray = (a)->
  object.prototype.toString.apply a is '[object Array]'

  #############
# ## Strings ##

# repeat method for strings
String.method "repeat", (times) ->
  (new Array times+1).join this

# trim
String.method "trim", ->
  @replace /^\s+|\s+$/g, ""

# dasherize:
# trim whitespace and replace spaces and underscores with dashes
String.method "dasherize", ->
  @.trim().replace ///\s+|_///g, "-"

# Underscorize
# trim whitespace and replace spaces and dashes with underscores
String.method "underscorize", ->
  @.trim().replace ///\s+|-///g, "_"



  ###############
# ## Functions ##

# Currying for functions
Function.method "curry", (c_args...)->
  (l_args...)=>
    this.apply null, c_args.concat l_args

#reduce for Arrays
Array.method "reduce", (f, value) ->
  for elem in this
    if not value?
      value = elem
    else
      value = f(value, elem)
  value

#returns a random number int the range [0, max) or [min, max]
# depending on the number of args
Math.randomInt = (max, min = 0) ->
  if max < min
    [min, max] = [max, min] #swap them
  Math.floor(Math.random() * (max - min)) + min;