add_document_ids_to_form = (form) ->
  $('input[name^="include"]:checked').each ->
    form.append('<input type="hidden" name="' + $(this).attr('name') + '" value="1" />')

$ ->
  $('#compile_documents_form').submit ->
    add_document_ids_to_form($(this))
    