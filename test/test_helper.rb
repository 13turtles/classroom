# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'mocha/mini_test'
require 'timecop'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('test', 'support', '**', '*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

class ActiveSupport::TestCase
  include Chewy::Minitest::Helpers
  include FixturesHelper

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def self.test(test_name, &block)
    return super if block.nil?

    super(test_name) do
      # Wrap every test in Chewy :bypass strategy
      Chewy.strategy(:bypass) do
        instance_eval(&block)
      end
    end
  end

  def before_setup
    # Set the OmniAuth mock config back to it's original state
    # between tests to avoid pollution.
    reset_omniauth

    # Wrap every action in setup to use the Chewy :bypass strategy.
    Chewy.strategy(:bypass) do
      # Enable VCR and configure a cassette named
      # based on the test method and grab anything in the setup block.
      #
      # This means that a test written like this:
      #
      # class OrderTest < ActiveSupport::TestCase
      #   test 'user can place an order' do
      #     ...
      #   end
      # end
      #
      # will automatically use VCR to intercept and record/play back any external
      # HTTP requests using `fixtures/cassettes/order_test/test_user_can_place_order.json`.
      base_path = self.class.name.underscore
      VCR.insert_cassette(base_path + '/' + name)

      super
    end
  end

  def after_teardown
    # Wrap every action in teardown to use the Chewy :bypass strategy.
    Chewy.strategy(:bypass) do
      super
      VCR.eject_cassette
    end
  end
end

class ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  include SignInHelper
end
