require File.dirname(__FILE__) + '/../spec_helper'

describe "the UserAssetsHelper" do
  helper_name :user_assets

  before(:each) do
    @attachable = mock_model(User, :login => 'JoeLogin')
  end
  
  it "should return user login name" do
    attachable_name().should eql("JoeLogin")
  end
end