require 'test_helper'

class TestFacebookApi < Test::Unit::TestCase
  context 'FacebookApi module' do

    should 'be configurable' do
      assert_equal API_KEY, FacebookApi.config.api_key
      assert_equal SECRET_KEY, FacebookApi.config.secret_key
    end

    should 'should provide convenience methods for api_key and secret_key' do
      assert_equal FacebookApi.config.api_key, FacebookApi.api_key
      assert_equal FacebookApi.config.secret_key, FacebookApi.secret_key      
    end

    should 'have a Logger' do
      assert FacebookApi.logger.is_a?(Logger)
    end

    should 'logger should default to info' do
      assert_equal Logger::INFO, FacebookApi.logger.level
    end

    should 'calculate a signature' do
      assert_equal 'ca4c37ea9d1dec12520bce945d1c3439',
        FacebookApi.calculate_signature('expires' => '1221157773', 'session_key' => '67bc4aa090e0d34954c1146b-2901279', 'ss' => '7fe9f4fe1035ea92466975fa94176763', 'user' => '2901279')
    end

    context '#verify_facebook_params_signature' do
      should 'return true with a valid signature' do
        assert FacebookApi.verify_facebook_params_signature(valid_facebook_params)
      end

      should 'return false with an invalid signature' do
        assert !FacebookApi.verify_facebook_params_signature(valid_facebook_params.merge('fb_sig' => 'wrong signature'))
      end
    end

    context '#verify_connect_cookies_signature' do
      should 'return true with a valid signature' do
        assert FacebookApi.verify_connect_cookies_signature(valid_facebook_connect_cookie_params)
      end

      should 'return false with an invalid signature' do
        assert !FacebookApi.verify_connect_cookies_signature(valid_facebook_connect_cookie_params.merge(FacebookApi.config.api_key => 'wrong signature'))
      end
    end

    context '#convert_time' do
      # TODO: Figure out how to test this without ActiveSupport
      should 'convert an ActiveSupport::TimeWithZone to UTC'
    end
  end
end
