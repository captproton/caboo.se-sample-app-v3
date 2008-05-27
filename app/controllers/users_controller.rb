class UsersController < ApplicationController

  @protected_actions = [ :edit, :update, :destroy ]
  before_filter :load_user, :except => [ :index, :create, :new ]
  before_filter :check_auth, :only => @protected_actions
  
  delegate_url_helpers :for => UserAssetsController
  
protected
  def load_user
    @user = User.find_by_param(params[:id]) or raise ActiveRecord::RecordNotFound
  end
  
  def check_auth
    current_user == @user or raise AccessDenied
  end

public
  # GET /users
  # GET /users.xml
  def index
    @users = User.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users.to_xml }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user.to_xml }
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
  
    respond_to do |format|
      if @user.save
        self.current_user = @user
        format.html { 
          flash[:notice] = 'User was successfully created.'
          redirect_to user_url(@user) 
        }
        format.xml  { head :created, :location => user_url(@user) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to user_url(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.xml  { head :ok }
    end
  end
end
