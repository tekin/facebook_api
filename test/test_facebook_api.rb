require 'test_helper'

class TestFacebookApi < Test::Unit::TestCase
  context 'FacebookApi module' do
    should 'be configurable' do
      FacebookApi.config.expects(:api_key=).with('api key')
      FacebookApi.configure { |config| config.api_key = 'api key' }
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

    context '#verify_connect_cookies' do
      should 'return true with a valid signature' do
        assert FacebookApi.verify_connect_cookies(facebook_connect_cookie_params)
      end

      should 'return false with an invalid signature' do
        assert !FacebookApi.verify_connect_cookies(facebook_connect_cookie_params.merge(FacebookApi.config.api_key => 'wrong signature'))
      end
    end

    context '#convert_time' do
      # TODO: Figure out how to test this without ActiveSupport
      should 'convert an ActiveSupport::TimeWithZone to Pacific time (PST and PDT)'
    end
  end
end
