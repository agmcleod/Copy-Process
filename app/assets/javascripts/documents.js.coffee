Note = Backbone.Model.extend({})

NoteView = Backbone.View.extend({
  el: null,
  initialize: ->
    this.model.view = this
    $('.view').append("<div class=\"note\" id=\"note_#{this.model.get('id')}\"><p>#{this.model.get('body')}</p><cite>#{this.model.get('author')}</cite></div>")
    this.el = $("#note_#{this.model.get('id')}")
    
  setup: ->
    self = this
    this.el.css({
      top: this.model.get('top') + 'px'
    })
    .mouseover -> 
      $(this).css({ 'z-index':'3' })
    .mouseout ->
      $(this).css({ 'z-index':'2' })
    .click ->
      self.edit(self.el, self.model)
        

    $('.view').append('<div class="note_line" id="line_' + this.model.get('id') + '"></div>')
    $('#line_' + this.model.get('id')).css({
      top: this.model.get('top') + 10 + 'px',
      width: this.model.get('left') + 8 + 'px'
    })
  edit: (el, n)->
    el.children('p').first().remove()
    el.prepend('<input type="text" id="edit_note" value="' + n.get('body') + '" />')
    el.unbind('click')
    
    
    $('#edit_note').keyup (e) ->
      en = $(this)
      if e.keyCode == 13
        $.ajax({
          url: '/documents/' + n.get('document_id') + '/notes/' + n.get('id') + '.json'
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
  
load_notes_on_page = (notes) ->
  view_top = $('.view').first().offset().top
  view_left = $('.view').first().offset().left
  $('pre .to_change').each ->
    id = $(this).attr('id').split('sel_')[1]
    notes[id].set({
      top: $(this).offset().top - view_top,
      left: $(this).offset().left - view_left,
      body: $('#note_' + id + ' p').first().text()
    })
    return
    
  for own id, note of notes
    note.view.setup()

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
  
  current_url = document.location.pathname.split('/')
  d_id = 0
  if current_url[4] != null
    d_id = current_url[4]
    
  $.ajax({
    url: '/documents/' + d_id + '/notes.json',
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
  
  