require File.dirname(__FILE__) + '/../../spec_helper'

describe "/assets/show.html.erb" do
  include AssetsHelper
  
  before(:each) do
    @asset = mock_model(Asset, 
      :to_param => '99',
      :public_filename => '/foo.jpg',
      :filename => 'foo.jpg',
      :width => '1', :height => '1',
      :content_type => 'text/jpeg',
      :size => 10024,
      :attachable_type => 'User',
      :attachable_id => '1',
      :updated_at => Time.now,
      :created_at => Time.now
    )

    assigns[:asset] = @asset
    @user = mock_model(User)
    assigns[:attachable] = @user
    
    # Views are tested in isolation here - however there are a number of helpers
    # that resource_fu creates which are defined in the controller and exposed to
    # views with helper_method().  We set expectations for calls to those helpers
    # but don't bother wiring them up - they will be tested in helper tests.
    @controller.template.should_receive(:user_assets_path).with().and_return('ASSETS_PATH')
    @controller.template.should_receive(:edit_user_asset_path).with(@asset).and_return('EDIT_ASSET_PATH')
  end

  it "should render attributes in <p>" do
    render "/assets/show.html.erb"

    # response.should have_tag('p', :content => "MyString")
    # response.should have_tag('p', :content => "1")
    # response.should have_tag('p', :content => "1")
    # response.should have_tag('p', :content => "MyString")
    # response.should have_tag('p', :content => "1")
    # response.should have_tag('p', :content => "MyString")
  end
end

