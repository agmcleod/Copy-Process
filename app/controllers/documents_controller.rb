class DocumentsController < ApplicationController
  before_filter :authenticate_user!
  # GET /documents
  # GET /documents.json
  def index
    @documents = Document.all
    @site = Site.find(params[:site_id])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @documents }
    end
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
    @document = Document.find(params[:id])
    @site = Site.find(params[:site_id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @document }
    end
  end

  # GET /documents/new
  # GET /documents/new.json
  def new
    @document = Document.new
    @version = Version.new
    @document.active_version = @version
    @document.versions << @version
    @site = Site.find(params[:site_id])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @document }
    end
  end

  # GET /documents/1/edit
  def edit
    @document = Document.find(params[:id])
    @site = Site.find(params[:site_id])
  end

  # POST /documents
  # POST /documents.json
  def create
    @site = Site.find(params[:site_id])
    @document = @site.documents.build(params[:document])
    respond_to do |format|
      if @site.save
        format.html { redirect_to site_url(@site), :notice => 'Document was successfully created.' }
        format.json { render :json => @document, :status => :created, :location => @document }
      else
        format.html { render :action => "new" }
        format.json { render :json => @document.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /documents/1
  # PUT /documents/1.json
  def update
    @document = Document.find(params[:id])
    @site = Site.find(params[:site_id])
    respond_to do |format|
      if @document.update_attributes(params[:document])
        format.html { redirect_to site_url(@site), :notice => 'Document was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @document.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document = Document.find(params[:id])
    @document.destroy
    @site = Site.find(params[:site_id])

    respond_to do |format|
      format.html { redirect_to @site }
      format.json { head :ok }
    end
  end
end
