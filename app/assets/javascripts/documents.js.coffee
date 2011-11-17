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
    
  view_top = $('.view').first().offset().top
  view_left = $('.view').first().offset().left
  
  notes = {}
  
  $('pre .to_change').each ->
    notes[$(this).attr('id').split('sel_')[1]] = {
      top: $(this).offset().top - view_top,
      left: $(this).offset().left - view_left
    }
    
  $('.note').each ->
    id = $(this).attr('id').split('note_')[1]
    $(this).css({
      top: notes[id].top + 'px'
    }).mouseover -> 
      $(this).css({ 'z-index':'3' })
    .mouseout ->
      $(this).css({ 'z-index':'2' })

    $('.view').append('<div class="note_line" id="line_' + id + '"></div>')
    $('#line_' + id).css({
      top: notes[id].top + 10 + 'px',
      width: notes[id].left + 8 + 'px'
    })