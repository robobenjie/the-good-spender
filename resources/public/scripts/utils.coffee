window.UTILS = {}

UTILS.dps_to_dpm = (dps)-> # dollars per second -> dollars per month
  dps*2629744
UTILS.dpm_to_dps = (dpm)->
  dpm/2629744

UTILS.assert = (exp, message) ->
  if not exp
    throw "Assert Error: " + message
