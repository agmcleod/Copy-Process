Note = Backbone.Model.extend({})

NoteView = Backbone.View.extend({
  el: null,
  initialize: ->
    this.model.view = this
    $('.view').append("<div class=\"note\" id=\"note_#{this.model.get('id')}\"><a>X</a><p>#{this.model.get('body')}</p><cite>#{this.model.get('author')}</cite></div>")
    this.el = $("#note_#{this.model.get('id')}")
    self = this
    this.el.children('a').click ->
      $.ajax({
        url:"/versions/#{self.model.get('version_id')}/notes/#{self.model.get('id')}.json",
        type: "DELETE",
        beforeSend: (jqXHR, settings) ->
          jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
        ,
        success: (data) ->
          $("#note_#{self.model.get('id')}").remove()
          $("#line_#{self.model.get('id')}").remove()
          text = $("#sel_#{self.model.get('id')}").text()
          outer = $("#sel_#{self.model.get('id')}").outer()
          html = $('.view pre').first().html()
          
          html = html.substring(0, html.indexOf(outer)) + 
            text + html.substring(html.indexOf(outer) + outer.length)
          $('.view pre').first().html(html)
      })
    
  setup: ->
    self = this
    this.el.css({
      top: this.model.get('top') + 'px'
    })
    .mouseover -> 
      $(this).css({ 'z-index':'3' })
    .mouseout ->
      $(this).css({ 'z-index':'2' })
    this.el.children('p').click ->
      self.edit(self.el, self.model)
        

    $('.view').append('<div class="note_line" id="line_' + this.model.get('id') + '"></div>')
    $('#line_' + this.model.get('id')).css({
      top: this.model.get('top') + 10 + 'px',
      width: this.model.get('left') + 8 + 'px'
    })
  draw_selection: (start_character, end_character) ->
    total_span_tag_size = 0
    html = $('.view pre').first().html()
    
    $('.to_change').each ->
      l = $(this).outer().length
      t = $(this).text().length
      size = (l - t)
      
      if (html.indexOf($(this).outer()) - total_span_tag_size) > start_character
        start_character += total_span_tag_size
        end_character += total_span_tag_size
        return false
      else
        total_span_tag_size += size
    
    html = html.substring(0, start_character) +
      "<span class=\"to_change\" id=\"sel_#{this.model.get('id')}\">" +
      html.substring(start_character, end_character) +
      "</span>" +
      html.substring(end_character)
      
    
    $('.view pre').first().html(html)
    
  edit: (el, n)->
    el.children('p').first().remove()
    el.prepend('<input type="text" id="edit_note" value="' + n.get('body') + '" />')
    el.unbind('click')
    
    
    $('#edit_note').keyup (e) ->
      en = $(this)
      if e.keyCode == 13
        $.ajax({
          url: '/versions/' + n.get('version_id') + '/notes/' + n.get('id') + '.json'
          type:'PUT',
          data: 'note[body]=' + en.val(),
          beforeSend: (jqXHR, settings) ->
            jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
          ,
          success: (data) ->
            n.set(data)
            n.view.update()
            
        })
    .focus()
  
  update: ->
    self = this
    this.el.prepend('<p>' + this.model.get('body') + '</p>')
    this.el.click ->
      self.edit(self.el, self.model)
    this.el.children('#edit_note').remove()
})

find_x_position = (node) ->
  x = 0
  node = node[0]
  while node.offsetParent
    x += node.offsetLeft
    node = node.offsetParent
  x - window.scrollX
  
find_y_position = (node) ->
  y = 0
  node = node[0]
  while node.offsetParent
    y += node.offsetTop
    node = node.offsetParent
  y - window.scrollY

get_version_id = ->
  window['version-id']
  
load_notes_on_page = (notes) ->
  view_top = $('.view').first().position().top
  view_left = $('.view').first().position().left
  $('pre .to_change').each ->
    id = $(this).attr('id').split('sel_')[1]
    if typeof notes[id] != "undefined"
      notes[id].set({
        top: $(this).offset().top - view_top,
        left: $(this).offset().left - view_left,
        body: $('#note_' + id + ' p').first().text()
      })
    return
    
  for own id, note of notes
    note.view.setup()
    
draw_selection_tags = (notes) ->
  for own id, note of notes
    note.view.draw_selection(note.get('start_character'), note.get('end_character'))
    
# Event handling for selecting text
add_text_selection = ->
  $('.view pre').first().mouseup (e) ->
    $('.new_note').remove()
    selection = window.getSelection()
    start_offset = selection.anchorOffset
    currentNode = selection.anchorNode
    while(currentNode != this)
      if currentNode.previousSibling
        start_offset += $(currentNode.previousSibling).text().length
        currentNode = currentNode.previousSibling
      else
        currentNode = currentNode.parentNode
        
    end_offset = selection.extentOffset - selection.anchorOffset + start_offset
    # if the end is less then the start, that means they are selecting in a current <span> tag
    if end_offset != null && start_offset != null
      text = $('.view pre').first().text()
      text = text.substring(start_offset, end_offset)
      # check that selection is valid, and that it does not contain HTML tags.
      if end_offset > start_offset && text.indexOf('<') == -1 && text.indexOf('>') == -1
        open_create_box(e, start_offset, end_offset)
        
open_create_box = (e, start_offset, end_offset) ->
  view = $('.view').first()
  x = e.clientX - find_x_position(view)
  y = e.clientY - find_y_position(view)
  $('.view').append('<div class="new_note">'+
    '<form id="new_note_form">' +
      '<fieldset>' +
        '<p>' +
          '<label for="note_body">Body:</label><input type="text" name="note_body" value="" id="note_body" />' +
        '</p>' +
        '<p>' +
          '<label for="note_author">Author:</label><input type="text" name="note_author" value="" id="note_author" />' +
        '</p>' +
        '<p><input type="submit" value="Save" /></p>' +
        '<p><a>Close</a></p>' +
        '<input type="hidden" name="note_start_character" value="' + start_offset  + '" id="note_start_character" />' +
        '<input type="hidden" name="note_end_character" value="' + end_offset + '" id="note_end_character" />' +
      '</fieldset>' +
    '</form>' +
  '</div>')
  $('.new_note').css({
    'top':y + 'px',
    'left':x + 'px'
  })
  
  $('.new_note a').click ->
    $('.new_note').remove()
    
  new_note_setup_event()
    
new_note_setup_event = ->
  $('#new_note_form').submit (e) ->
    e.preventDefault()
    valid = true;
    message = ''
    $('#new_note_form input').each ->
      if !is_valid($(this).val())
        message += $(this).attr('id') + " is a required field, and must be filled in\n"
        valid = false
    if !valid
      alert(message)
    else
      body = $('#note_body').val()
      start = $('#note_start_character').val()
      end = $('#note_end_character').val()
      author = $('#note_author').val()
      d_id = get_version_id()
      $.ajax({
        url:'/versions/' + d_id + '/notes.json',
        type:'POST',
        data:'note[body]=' + body + '&note[start_character]=' + start + '&note[end_character]=' + end + '&note[author]=' + author + '&note[version_id]=' + d_id,
        beforeSend: (jqXHR, settings) ->
          jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
        ,
        success: (data) ->
          $('.new_note').remove()
          notes = {}
          model = new Note(data)
          new NoteView({
            model: model
          })
          notes[data.id] = model
          draw_selection_tags(notes)
          load_notes_on_page(notes)
      })
    
    return false
    
is_valid = (value) ->
  value != "" && value != null

$.fn.outer = ->
  $( $('<div></div>').html(this.clone()) ).html()

$ ->
  
  $('#select-version').change ->
    window.location.href = window.location.pathname + "?version_id=" + $(this).val()
    
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
  
  # retrieves and loads the notes from the JSON response
  if get_version_id() != null && typeof get_version_id() != 'undefined'
    $.ajax({
      url: '/versions/' + get_version_id() + '/notes.json',
      type: 'GET',
    
      beforeSend: (jqXHR, settings) ->
        jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
      ,
      success: (data) ->
        notes = {}
        for note in data
          model = new Note(note)
          notes[note.id] = model
          new NoteView({
            model: model
          })
      
        load_notes_on_page(notes)
    })
  
  add_text_selection()
  
  
  