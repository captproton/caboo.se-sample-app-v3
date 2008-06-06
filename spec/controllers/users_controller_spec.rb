require File.dirname(__FILE__) + '/../spec_helper'

describe "Routes for the UsersController should map" do
  controller_name :users

  it "{ :controller => 'users', :action => 'index' } to /users" do
    route_for(:controller => "users", :action => "index").should == "/users"
  end
  
  it "{ :controller => 'users', :action => 'new' } to /users/new" do
    route_for(:controller => "users", :action => "new").should == "/users/new"
  end
  
  it "{ :controller => 'users', :action => 'show', :id => 1 } to /users/1" do
    route_for(:controller => "users", :action => "show", :id => 1).should == "/users/1"
  end
  
  it "{ :controller => 'users', :action => 'edit', :id => 1 } to /users/1/edit" do
    route_for(:controller => "users", :action => "edit", :id => 1).should == "/users/1/edit"
  end
  
  it "{ :controller => 'users', :action => 'update', :id => 1} to /users/1" do
    route_for(:controller => "users", :action => "update", :id => 1).should == "/users/1"
  end
  
  it "{ :controller => 'users', :action => 'destroy', :id => 1} to /users/1" do
    route_for(:controller => "users", :action => "destroy", :id => 1).should == "/users/1"
  end
end

describe "Requesting /users using GET" do
  controller_name :users

  before(:each) do
    @user = mock_model(User)
    User.stub!(:find).and_return(@user)
  end
  
  def do_get
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should render index.html.erb" do
    do_get
    response.should render_template('index')
  end
  
  it "should find all users" do
    User.should_receive(:find).with(:all).and_return([@user])
    do_get
  end
  
  it "should assign the found users for the view" do
    do_get
    assigns[:users].should equal(@user)
  end
end

describe "Requesting /users.xml using GET" do
  controller_name :users

  before(:each) do
    @user = mock_model(User, :to_xml => "XML")
    User.stub!(:find).and_return(@user)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :index
  end
  
  it "should be successful" do
    do_get
    response.should be_success
  end

  it "should find all users" do
    User.should_receive(:find).with(:all).and_return([@user])
    do_get
  end
  
  it "should render the found users as xml" do
    @user.should_receive(:to_xml).and_return("XML")
    do_get
    response.body.should == "XML"
  end
end

describe "Requesting /users/1 using GET" do
  controller_name :users

  before(:each) do
    @user = mock_model(User)
    User.stub!(:find_by_param).and_return(@user)
  end
  
  def do_get
    get :show, :id => "1"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render show.html.erb" do
    do_get
    response.should render_template('show')
  end
  
  it "should find the user requested" do
    User.should_receive(:find_by_param).with("1").and_return(@user)
    do_get
  end
  
  it "should assign the found user for the view" do
    do_get
    assigns[:user].should equal(@user)
  end
end

describe "Requesting /users/1.xml using GET" do
  controller_name :users

  before(:each) do
    @user = mock_model(User, :to_xml => "XML")
    User.stub!(:find_by_param).and_return(@user)
  end
  
  def do_get
    @request.env["HTTP_ACCEPT"] = "application/xml"
    get :show, :id => "1"
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should find the user requested" do
    User.should_receive(:find_by_param).with("1").and_return(@user)
    do_get
  end
  
  it "should render the found user as xml" do
    @user.should_receive(:to_xml).and_return("XML")
    do_get
    response.body.should == "XML"
  end
end

describe "Requesting /users/new using GET" do
  controller_name :users

  before(:each) do
    @user = mock_model(User)
    User.stub!(:new).and_return(@user)
  end
  
  def do_get
    get :new
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render new.html.erb" do
    do_get
    response.should render_template('new')
  end
  
  it "should create an new user" do
    User.should_receive(:new).and_return(@user)
    do_get
  end
  
  it "should not save the new user" do
    @user.should_not_receive(:save)
    do_get
  end
  
  it "should assign the new user for the view" do
    do_get
    assigns[:user].should be(@user)
  end
end

describe "Requesting /users/1/edit using GET" do
  controller_name :users

  before(:each) do
    ## outdated with rails 2.1 @user = mock_model(User, :tz => nil)
    User.stub!(:find_by_param).and_return(@user)
    controller.stub!(:current_user).and_return @user
  end
  
  def do_get
    get :edit, :id => 1
  end

  it "should fail if current user doesn't match" do
    controller.should_receive(:current_user).at_least(1).and_return(User.new)
    do_get
    response.should be_redirect
  end

  it "should be successful" do
    do_get
    response.should be_success
  end
  
  it "should render edit.html.erb" do
    do_get
    response.should render_template('edit')
  end
  
  it "should find the user requested" do
    User.should_receive(:find_by_param).and_return(@user)
    do_get
  end
  
  it "should assign the found User for the view" do
    do_get
    assigns[:user].should equal(@user)
  end
end

describe "Requesting /users using POST" do
  controller_name :users

  before(:each) do
    @user = mock_model(User, :to_param => "1", :save => true)
    User.stub!(:new).and_return(@user)
  end
  
  def do_post
    post :create, :user => {:name => 'User'}
  end
  
  it "should create a new user" do
    User.should_receive(:new).with({'name' => 'User'}).and_return(@user)
    do_post
  end

  it "should redirect to the new user" do
    do_post
    response.should redirect_to("http://test.host/users/1")
  end
end

describe "Requesting /users/1 using PUT" do
  controller_name :users

  before(:each) do
    ## outdate with rails 2.1 ## @user = mock_model(User, :to_param => "1", :update_attributes => true, :tz => nil)
    User.stub!(:find_by_param).and_return(@user)
    
    controller.stub!(:current_user).and_return(@user)
  end
  
  def do_update
    put :update, :id => "1"
  end
  
  it "should find the user requested" do
    User.should_receive(:find_by_param).with("1").and_return(@user)
    do_update
  end

  it "should update the found user" do
    @user.should_receive(:update_attributes)
    do_update
    assigns(:user).should equal(@user)
  end

  it "should assign the found user for the view" do
    do_update
    assigns(:user).should equal(@user)
  end

  it "should redirect to the user" do
    do_update
    response.should be_redirect
    response.redirect_url.should == "http://test.host/users/1"
  end
end

describe "Requesting /users/1 using DELETE" do
  controller_name :users

  before(:each) do
    ## outdate with rails 2.1 ## @user = mock_model(User, :destroy => true, :tz => nil)
    User.stub!(:find_by_param).and_return(@user)
    controller.stub!(:current_user).and_return @user
  end
  
  def do_delete
    delete :destroy, :id => "1"
  end

  it "should find the user requested" do
    User.should_receive(:find_by_param).with("1").and_return(@user)
    do_delete
  end
  
  it "should call destroy on the found user" do
    @user.should_receive(:destroy)
    do_delete
  end
  
  it "should redirect to the users list" do
    do_delete
    response.should redirect_to("http://test.host/users")
  end
end
