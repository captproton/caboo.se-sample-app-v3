# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec/rails'
## outdate with rails 2.1 ## require 'tzinfo'

require 'rspec_extensions' # custom in lib/

# Even if you're using RSpec, RSpec on Rails is reusing some of the
# Rails-specific extensions for fixtures and stubbed requests, response
# and other things (via RSpec's inherit mechanism). These extensions are 
# tightly coupled to Test::Unit in Rails, which is why you're seeing it here.
Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures'

  # so that helpers which call controller() work?
  def controller
    @controller
  end

  # You can set up your global fixtures here, or you
  # can do it in individual contexts using "fixtures :table_a, table_b".
  #
  #self.global_fixtures = :table_a, :table_b
  def mock_user
    user = mock_model(User, 
      :id => 1, 
      ## outdate with rails 2.1 ## :tz => TimeZone.new('USA/PDT'),
      :login => 'flappy',
      :email => 'flappy@email.com',
      :password => '', :password_confirmation => '',
      :time_zone => 'USA/PDT'
    ) 
  end
end



