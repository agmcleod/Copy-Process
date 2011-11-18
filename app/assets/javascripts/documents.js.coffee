Note = Backbone.Model.extend({})

edit_note_fn = (notes, id, note)->
  n = notes[id]
  note.children('p').first().remove()
  note.prepend('<input type="text" id="edit_note" value="' + n.get('body') + '" />')
  note.unbind('click')
  
  $('#edit_note').keyup (e) ->
    en = $(this)
    if e.keyCode == 13
      $.ajax({
        
        success: (data) ->
          n.set({ body: en.val() })
          en.remove()
          note.prepend('<p>' + n.get('body') + '</p>')
          note.click ->
            edit_note_fn(notes, id, note)
      })
  .focus()

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
    id = $(this).attr('id').split('sel_')[1]
    notes[id] = new Note({
      top: $(this).offset().top - view_top,
      left: $(this).offset().left - view_left,
      body: $('#note_' + id + ' p').first().text()
    })
    
  $('.note').each ->
    id = $(this).attr('id').split('note_')[1]
    $(this).css({
      top: notes[id].get('top') + 'px'
    }).mouseover -> 
      $(this).css({ 'z-index':'3' })
    .mouseout ->
      $(this).css({ 'z-index':'2' })
    .click ->
      edit_note_fn(notes, id, $(this))
        

    $('.view').append('<div class="note_line" id="line_' + id + '"></div>')
    $('#line_' + id).css({
      top: notes[id].get('top') + 10 + 'px',
      width: notes[id].get('left') + 8 + 'px'
    })