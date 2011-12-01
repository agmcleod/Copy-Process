class VersionsController < ApplicationController
  def create
    @document = Document.find(params[:document_id])
    @version = @document.versions.build(content: @document.content)
    @document.active_version = @version
    if @document.save
      redirect_to site_path(@document.site), notice: "New version created and set as active. It can now be edited and reviewed."
    else
      flash[:error] = "Unable to create new version. #{@document.errors.full_messages.join(' | ')}"
      redirect_to site_path(@document.site)
    end
  end
  
  def show
    @document = Document.find(params[:document_id])
    @version = Version.find(params[:id])
  end

end
