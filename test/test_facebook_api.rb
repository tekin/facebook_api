require 'test_helper'

class TestFacebookApi < Test::Unit::TestCase
  context 'FacebookApi module' do

    should 'be configurable' do
      assert_equal APP_ID, FacebookApi.config.app_id
      assert_equal API_KEY, FacebookApi.config.api_key
      assert_equal SECRET_KEY, FacebookApi.config.secret_key
    end

    should 'should provide convenience methods for app_id, api_key and secret_key' do
      assert_equal FacebookApi.config.app_id, FacebookApi.app_id
      assert_equal FacebookApi.config.api_key, FacebookApi.api_key
      assert_equal FacebookApi.config.secret_key, FacebookApi.secret_key
    end

    should 'have a Logger' do
      assert FacebookApi.logger.is_a?(Logger)
    end

    should 'logger should default to info' do
      assert_equal Logger::INFO, FacebookApi.logger.level
    end

    context '#convert_time' do
      # TODO: Figure out how to test this without ActiveSupport
      should 'convert an ActiveSupport::TimeWithZone to UTC'
    end
  end
end
