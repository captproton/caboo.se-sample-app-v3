#
# As you read this, bear in mind that this controller
# is involved in a polymorphic relationship and should
# *never* appear directly in a route.  
# 
# Create subclasses that know how to deal with the 
# specifics of the relationship between the Asset and
# its polymorhpic 'attachable' (see UserAssetsController).
#
# Another option would be to put all of this stuff into a
# module that the polymorphs would include().  However
# doing it this way means we just have one set of templates
# under app/views/assets that are re-used by the polymorphs.
# See self.controller_path in UserAssetsController.
#
class AssetsController < ApplicationController

  before_filter :load_attachable
  before_filter :load_asset, :except => [ :index, :create, :new ]
  before_filter :check_auth, :only => protected_actions
  
protected

  # assets() is used for find() and build()
  delegate :assets, :to => '@attachable'
  helper_method :assets
  
  def load_asset
    @asset = assets.find(params[:id])
  end

public

  # GET /assets
  # GET /assets.xml
  def index
    @assets = assets.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @assets.to_xml }
    end
  end

  # GET /assets/1
  # GET /assets/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @asset.to_xml }
    end
  end

  # GET /assets/new
  def new
    @asset = assets.build
  end

  # GET /assets/1/edit
  def edit
  end

  # POST /assets
  # POST /assets.xml
  def create
    @asset = assets.build(params[:asset])

    respond_to do |format|
      if @asset.save
        flash[:notice] = 'Asset was successfully created.'
        format.html { redirect_to user_asset_url(@asset) }
        format.xml  { head :created, :location => user_asset_url(@asset) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @asset.errors.to_xml }
      end
    end
  end

  # PUT /assets/1
  # PUT /assets/1.xml
  def update
    respond_to do |format|
      if @asset.update_attributes(params[:asset])
        flash[:notice] = 'Asset was successfully updated.'
        format.html { redirect_to user_asset_url(@asset) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @asset.errors.to_xml }
      end
    end
  end

  # DELETE /assets/1
  # DELETE /assets/1.xml
  def destroy
    @asset.destroy

    respond_to do |format|
      format.html { redirect_to user_assets_url() }
      format.xml  { head :ok }
    end
  end
end
