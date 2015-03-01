ENV['RAILS_ENV'] ||= 'test'
require 'factory_girl_rails'
require 'rake'
require File.expand_path("../../config/environment", __FILE__)


RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    # FactoryGirl.lint if system "rake db:test:prepare"
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end