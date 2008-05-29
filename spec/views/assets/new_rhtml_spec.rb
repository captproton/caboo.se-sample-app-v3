require File.dirname(__FILE__) + '/../../spec_helper'

describe "/assets/new.html.erb" do
  include AssetsHelper
  
  before(:each) do
    @errors = mock("errors")
    @errors.stub!(:count).and_return(0)

    @asset = mock("asset")
    @asset.stub!(:to_param).and_return("99")
    @asset.stub!(:errors).and_return(@errors)
    @asset.stub!(:filename).and_return("MyString")
    @asset.stub!(:width).and_return("1")
    @asset.stub!(:height).and_return("1")
    @asset.stub!(:content_type).and_return("MyString")
    @asset.stub!(:size).and_return("1")
    @asset.stub!(:attachable_type).and_return("MyString")
    @asset.stub!(:attachable_id).and_return("1")
    @asset.stub!(:updated_at).and_return(Time.now)
    @asset.stub!(:created_at).and_return(Time.now)

    assigns[:asset] = @asset
    @user = mock_model(User)
    assigns[:attachable] = @user
    
    # Views are tested in isolation here - however there are a number of helpers
    # that resource_fu creates which are defined in the controller and exposed to
    # views with helper_method().  We set expectations for calls to those helpers
    # but don't bother wiring them up - they will be tested in helper tests.
    @controller.template.should_receive(:user_assets_path).with().exactly(2).times.and_return('ASSETS_PATH')
    # This will be available via the polymorphic controllers own helper module - 
    # set an expectation and test output in the helper tests
    @controller.template.should_receive(:attachable_name).with().times.and_return('ATTACHABLE_NAME')
  end

  it "should render new form" do
    render "/assets/new.html.erb"
    response.should have_tag('h1', :content => /ATTACHABLE_NAME/)
    response.should have_tag('form', :attributes =>{:action => 'ASSETS_PATH', :method => 'post'})
    response.should have_tag('input', :attributes =>{:name => 'asset[uploaded_data]'})
  end
end