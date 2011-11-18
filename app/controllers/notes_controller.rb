class NotesController < ApplicationController
  respond_to :json
  
  def index
    @document = parent_document(params)
    @notes = @document.notes
    respond_with(@notes)
  end

  def create
    @document = parent_document(params)
    @note = Note.new(params[:note])
    @note.save
    respond_with(@note)
  end

  def update
    @document = parent_document(params)
    @note = Note.find(params[:id])
    respond_to do |format|
      if @note.update_attributes(params[:note])
        format.json { render json: @note }
      else
        format.json { render :json => @note.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @document = parent_document(params)
    @note = Note.find(params[:id])
    @note.destroy
    respond_with(@note)
  end
  
  private
  
  def parent_document(params)
    Document.find(params[:document_id])
  end

end
