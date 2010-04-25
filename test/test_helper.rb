require 'rubygems'
require 'facebook_api'
require "test/unit"
require "shoulda"
require "mocha"

class Test::Unit::TestCase

  FacebookApi.configure do |config|
    config.api_key = '86cd871c996910064ab9884459c58bab'
    config.secret_key = '86cd871c996910064ab9884459c58bab'
  end

  def facebook_connect_cookie_params
    { "#{FacebookApi.config.api_key}_expires" => '1221157773',
      "#{FacebookApi.config.api_key}_session_key" => '67bc4aa090e0d34954c1146b-2901279',
      "#{FacebookApi.config.api_key}_ss" => '7fe9f4fe1035ea92466975fa94176763',
      "#{FacebookApi.config.api_key}_user" => '2901279',
      FacebookApi.config.api_key => 'ca4c37ea9d1dec12520bce945d1c3439',
      "fbsetting_#{FacebookApi.config.api_key}" => 'should-be-ignored' }
  end
end
