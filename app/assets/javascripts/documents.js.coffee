$ ->
  $('#listify').click ->
    contents = $('#document_content')
    val = contents.val()
    len = val.length
    start = contents[0].selectionStart
    end = contents[0].selectionEnd
    selectedText = val.substring(start, end)
    
    items = selectedText.split(/\n/)
    list = for item in items
      "<li>#{item}</li>"
    
    contents.val(val.substring(0, start) + "<ul>" + list.join("\n") + "</ul>" + val.substring(end, len))
    