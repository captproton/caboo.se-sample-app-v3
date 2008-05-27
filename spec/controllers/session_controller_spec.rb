require File.dirname(__FILE__) + '/../spec_helper.rb'

describe SessionsController, "/session/new GET" do

  def do_get
    get :new
  end

  it "should render new" do
    do_get
    response.should render_template(:new)
  end
end

describe SessionsController, "POST without remember me" do

  before(:each) do
    @user = mock_user
    User.stub!(:authenticate).and_return(@user)
    # controller.stub!(:logged_in?).and_return(true)
  end

  it 'should authenticate user' do
    User.should_receive(:authenticate).with('user', 'password').and_return(@user)
    post :create, :login => 'user', :password => 'password'
  end

  it 'should login user' do
    controller.should_receive(:logged_in?).and_return(false, true)
    post :create
  end

  it "should not remember me" do
    post :create
    response.cookies["auth_token"].should be_nil
  end

  it "should redirect to root" do
    post :create
    response.should redirect_to('http://test.host/')
  end
end

describe SessionsController, "POST with remember me" do

  before(:each) do
    @user = mock_user

    @ccookies = mock('cookies')
    User.stub!(:authenticate).and_return(@user)
    controller.stub!(:logged_in?).and_return(false, true)
    @user.stub!(:remember_me)
    controller.stub!(:cookies).and_return(@ccookies)

    @ccookies.stub!(:[]=)
    @ccookies.stub!(:[])
    @user.stub!(:remember_token).and_return('1111')
    @user.stub!(:remember_token_expires_at).and_return(Time.now)
  end

  it "should remember me" do
    @user.should_receive(:remember_me)
    post :create, :login => "derek", :password => "password", :remember_me => "1"
  end    

  it 'should create cookie' do
    @ccookies.should_receive(:[]=).with(:auth_token, { :value => '1111' , :expires => @user.remember_token_expires_at })
    post :create, :login => "derek", :password => "password", :remember_me => "1"
  end
end

describe SessionsController, "POST when invalid" do

  before(:each) do
    @user = mock_user

    controller.stub!(:logged_in?).and_return(false, false)
    User.stub!(:authenticate).and_return(nil)
  end

  it 'should authenticate user' do
    User.should_receive(:authenticate).with('user', 'password').and_return(nil)
    post :create, :login => 'user', :password => 'password'
  end

  it 'should login user' do
    controller.should_receive(:logged_in?).and_return(false, false)
    post :create
  end

  it "should not remember me" do
    post :create
    response.cookies["auth_token"].should be_nil
  end

  it "should render new" do
    post :create
    response.should render_template('new')
  end
end

describe SessionsController, "logout" do

  before(:each) do
    @user = mock_user

    @ccookies = mock('cookies')
    controller.stub!(:current_user).and_return(@user)
    controller.stub!(:logged_in?).and_return(true, true)
    @user.stub!(:forget_me)
    controller.stub!(:cookies).and_return(@ccookies)
    @ccookies.stub!(:delete)
    @ccookies.stub!(:[])
    response.cookies.stub!(:delete)
    controller.stub!(:reset_session)
  end

  it "should get current user" do
    controller.should_receive(:current_user).and_return(@user, @user)
    delete :destroy
  end

  it 'should forget current user' do
    @user.should_receive(:forget_me)
    delete :destroy
  end

  it "should delete token on logout" do
    @ccookies.should_receive(:delete).with(:auth_token)
    delete :destroy
  end

  it 'should reset session' do 
    controller.should_receive(:reset_session)
    delete :destroy
  end

  it "should redirect to root" do
    delete :destroy
    response.should redirect_to('http://test.host/')
  end
end
