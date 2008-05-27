require File.dirname(__FILE__) + '/../../spec_helper'

describe "/users/new.html.erb" do
  include UsersHelper
  
  before(:each) do
    @errors = mock("errors")
    @errors.stub!(:count).and_return(0)

    @user = mock_user
    @user.stub!(:errors).and_return @errors
    assigns[:user] = @user
  end

  it "should render new form" do
    render "/users/new.html.erb"
    response.should have_tag('form', :attributes =>{:action => users_path, :method => 'post'})

  end
end


