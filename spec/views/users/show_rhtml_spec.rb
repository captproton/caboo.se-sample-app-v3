require File.dirname(__FILE__) + '/../../spec_helper'

describe "/users/show.html.erb" do
  include UsersHelper
  
  before(:each) do
    @user = mock_user

    assigns[:user] = @user
    
    # Views are tested in isolation here - however there are a number of helpers
    # that resource_fu creates which are defined in the controller and exposed to
    # views with helper_method().  We set expectations for calls to those helpers
    # but don't bother wiring them up - they will be tested in helper tests.
    @controller.template.should_receive(:user_assets_path).with().and_return('ASSETS_PATH')
  end

  it "should render attributes in <p>" do
    render "/users/show.html.erb"

  end
end

