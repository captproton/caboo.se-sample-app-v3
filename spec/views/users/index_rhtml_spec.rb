require File.dirname(__FILE__) + '/../../spec_helper'

describe "/users/index.html.erb" do
  include UsersHelper
  
  before(:each) do
    user_98 = mock_model(User, :id => 98, :login => 'joe')
    user_99 = mock_model(User, :id => 99, :login => 'mary')

    assigns[:users] = [user_98, user_99]
  end

  it "should render list of users" do
    render "/users/index.html.erb"

  end
end

