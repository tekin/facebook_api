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

    context '#authorize_url' do
      should 'return the Facebook OAuth2 authorization url with redirect_uri' do
        assert_equal "https://graph.facebook.com/oauth/authorize?client_id=#{APP_ID}&type=web_server&redirect_uri=REDIRECT_URI",
          FacebookApi.authorize_url('REDIRECT_URI')
      end
      should 'return the Facebook OAuth2 authorization url with redirect_uri and optional params' do
        assert_equal "https://graph.facebook.com/oauth/authorize?scope=offline_access&client_id=#{APP_ID}&type=web_server&redirect_uri=REDIRECT_URI",
          FacebookApi.authorize_url('REDIRECT_URI', :scope => 'offline_access')
      end
    end

    context '#get_access_token' do
      should 'make a request to retrieve the token' do
        stub_request(:post, 'https://graph.facebook.com/oauth/access_token').to_return(:body => 'access_token=ACCESS_TOKEN_HERE')
        assert_equal 'ACCESS_TOKEN_HERE', FacebookApi.get_access_token('CODE', 'REDIRECT_URI')
        assert_requested(:post, 'https://graph.facebook.com/oauth/access_token', :body => {:redirect_uri => 'REDIRECT_URI', :code => 'CODE', :client_secret => SECRET_KEY, :client_id => APP_ID, :type => 'web_server'})
      end
    end

    context '#convert_time' do
      should 'convert a ActiveSupport::TimeWithZone to an ISO 8601 string without a specified timezone' do
        Time.zone = 'London'
        time = Time.zone.local(2010, 8, 15, 15, 30) # 15 Aug 2010 15:30 +01:00 for British summertime
        assert_equal '2010-08-15T15:30:00', FacebookApi.convert_time(time)
      end
    end
  end
end
