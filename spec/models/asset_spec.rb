require File.dirname(__FILE__) + '/../spec_helper'

#Delete this context and add some real ones
describe "Given a generated asset_spec.rb with fixtures loaded" do
  fixtures :assets

  it "fixtures should load two Assets" do
    Asset.should have(2).records
  end
  
  it "should be valid" do
    asset = Asset.find 1
    asset.should be_valid
    asset.should have_valid_associations

  end
end
