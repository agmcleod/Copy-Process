$ ->
  if $('#accordion h3').length > 1
    $('#accordion').accordion({
      collapsible:true,
      active:false
    })
  return