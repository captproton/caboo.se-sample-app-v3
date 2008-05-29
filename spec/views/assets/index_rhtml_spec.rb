require File.dirname(__FILE__) + '/../../spec_helper'

describe "/assets/index.html.erb" do
  include AssetsHelper
  
  before(:each) do
    asset_98 = mock_model(Asset, :to_param => '98', :public_filename => '/foo/bar.jpg')
    asset_98.stub!(:to_param).and_return("98")
    asset_98.should_receive(:width).and_return("1")
    asset_98.should_receive(:height).and_return("1")
    asset_98.should_receive(:content_type).and_return("MyString")
    asset_98.should_receive(:size).and_return("1")
    asset_98.should_receive(:attachable_type).and_return("MyString")
    asset_98.should_receive(:attachable_id).and_return("1")
    asset_98.should_receive(:updated_at).and_return(Time.now)
    asset_98.should_receive(:created_at).and_return(Time.now)

    asset_99 = mock_model(Asset, :to_param => '99', :public_filename => '/foo/xx.jpg')
    asset_99.should_receive(:width).and_return("1")
    asset_99.should_receive(:height).and_return("1")
    asset_99.should_receive(:content_type).and_return("MyString")
    asset_99.should_receive(:size).and_return("1")
    asset_99.should_receive(:attachable_type).and_return("MyString")
    asset_99.should_receive(:attachable_id).and_return("1")
    asset_99.should_receive(:updated_at).and_return(Time.now)
    asset_99.should_receive(:created_at).and_return(Time.now)

    assigns[:assets] = [asset_98, asset_99]

    @user = mock_model(User)
    assigns[:attachable] = @user
    
    # Views are tested in isolation here - however there are a number of helpers
    # that resource_fu creates which are defined in the controller and exposed to
    # views with helper_method().  We set expectations for calls to those helpers
    # but don't bother wiring them up - they will be tested in helper tests.
    @controller.template.should_receive(:user_asset_path).with(asset_98).exactly(2).times.and_return('ASSET_98_PATH')
    @controller.template.should_receive(:user_asset_path).with(asset_99).exactly(2).times.and_return('ASSET_99_PATH')
    @controller.template.should_receive(:edit_user_asset_path).with(asset_98).and_return('EDIT_ASSET_98_PATH')
    @controller.template.should_receive(:edit_user_asset_path).with(asset_99).times.and_return('EDIT_ASSET_99_PATH')
    @controller.template.should_receive(:new_user_asset_path).with().times.and_return('NEW_ASSET_PATH')
    @controller.template.should_receive(:asset_attachable_path).with(@user).times.and_return('NEW_ASSET_PATH')
    
  end

  it "should render list of assets" do
    render "/assets/index.html.erb"

    response.should have_tag('td', :content => "MyString")
    response.should have_tag('td', :content => "1")
    response.should have_tag('td', :content => "1")
    response.should have_tag('td', :content => "MyString")
    response.should have_tag('td', :content => "1")
    response.should have_tag('td', :content => "MyString")
  end
end

