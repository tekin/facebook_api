require 'rubygems'
require 'facebook_api'
require 'test/unit'
require 'mocha'
require 'shoulda'
require 'webmock/test_unit'

include WebMock::API

APP_ID = '12334567'
API_KEY = '650503b8455d7ae1cd4524da50d88129'
SECRET_KEY = '86cd871c996910064ab9884459c58bab'

FacebookApi.configure do |config|
  config.app_id = APP_ID
  config.api_key = API_KEY
  config.secret_key = SECRET_KEY
end

class Test::Unit::TestCase

  def valid_facebook_params
    { 'fb_sig_in_canvas' => '1',
      'fb_sig_request_method' => 'GET',
      'fb_sig_friends' => '4,6,...',
      'fb_sig_position_fix' => '1',
      'fb_sig_locale' => 'en_US',
      'fb_sig_in_new_facebook' => '1',
      'fb_sig_time' => '1221071115.1896',
      'fb_sig_added' => '1',
      'fb_sig_profile_update_time' => '1220998418',
      'fb_sig_user' => '2901279',
      'fb_sig_session_key' => '9a7e04226b1a3c85823bfafd-2901279',
      'fb_sig_expires' => '0',
      'fb_sig_api_key' => API_KEY,
      'fb_sig' => '3221a15c4e2804c04da31670a7b64516' }
  end

  def valid_facebook_connect_cookie_params
    { "#{FacebookApi.api_key}_expires" => '1221157773',
      "#{FacebookApi.api_key}_session_key" => '67bc4aa090e0d34954c1146b-2901279',
      "#{FacebookApi.api_key}_ss" => '7fe9f4fe1035ea92466975fa94176763',
      "#{FacebookApi.api_key}_user" => '2901279',
      FacebookApi.api_key => 'ca4c37ea9d1dec12520bce945d1c3439',
      "fbsetting_#{FacebookApi.api_key}" => 'should-be-ignored' }
  end

  def stub_facebook_request(method, body = '12345', status = 200)
    stub_request(:any, FacebookApi::REST_URL + method).to_return(:body => body, :status => status)
  end

  def expect_facebook_request(method, params = {})
    RestClient.expects(:post).with(FacebookApi::REST_URL + method, params)
  end

  def stubbed_response(body = '341341252346', code = 200)
    response = mock
    response.stubs(:body).returns(body)
    response.stubs(:code).returns(code)
    response
  end
end
