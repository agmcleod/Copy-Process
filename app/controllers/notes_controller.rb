class NotesController < ApplicationController
  respond_to :json
  
  def index
    @version = parent_version(params)
    @notes = @version.notes
    respond_with(@notes)
  end

  def create
    @version = parent_version(params)
    @note = Note.new(params[:note])
    
    respond_to do |format|
      if @note.save
        format.json { render json: @note }
      else
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    @version = parent_version(params)
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
    @version = parent_version(params)
    @note = Note.find(params[:id])
    @note.destroy
    respond_with(@note)
  end
  
  private
  
  def parent_version(params)
    Version.find(params[:version_id])
  end

end
