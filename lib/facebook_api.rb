require 'logger'
require 'digest/sha2'
require 'rest_client'
require 'json'
require 'oauth2'

require 'facebook_api/session'

module FacebookApi
  
  class Configuration #:nodoc:
    attr_accessor :app_id, :api_key, :secret_key, :canvas_page_name, :callback_url
  end

  REST_URL = 'https://api.facebook.com/method/' #:nodoc:
  GRAPH_URL = 'https://graph.facebook.com/' #:nodoc:

  @logger = nil
  @config = Configuration.new

  # Returns the logger for Facebook calls.
  # By default, this outputs to STDOUT.
  def self.logger
    unless @logger
      @logger = ::Logger.new($stdout)
      @logger.level = Logger::INFO
    end
    @logger
  end

  # Returns the App id. set this with #configure.
  def self.app_id
    config.app_id
  end

  # Returns the api key. set this with #configure.
  # Note: Redundant now we use OAuth2?
  def self.api_key
    config.api_key
  end

  # Returns the secret key. set this with #configure.
  def self.secret_key
    config.secret_key 
  end

  # Allows you to set your Facebook configuration for accessing the REST API:
  #
  #   FacebookApi.configure do |config|
  #     config.app_id = 'YOUR_APP_ID'
  #     config.api_key = 'YOUR_API_KEY'
  #     config.secret_key = 'YOUR_SECRET_KEY'
  #     config.canvas_page_name = 'YOUR_CANVAS_PAGE_NAME'
  #     config.callback_url = 'YOUR_CALLBACK_URL'
  #   end
  def self.configure(&block)
    yield @config
  end

  # Returns the current Facebook configuration. This gets set with #configure.
  def self.config
    @config
  end

  # Returns the OAuth2 authorization url to redirect users to for authorization
  def self.authorize_url(redirect_uri, params={})
    oauth_client.auth_code.authorize_url(params.merge(:redirect_uri => redirect_uri))
  end

  # Peforms the final step of OAuth2 authorization by retrieving the access token.
  # call with the verification code returned by Facebook and the same redirect_uri
  # used with the original call to #authorize_url.
  # Returns an access_token
  def self.get_access_token(code, redirect_uri)
    response = oauth_client.auth_code.get_token(code, :parse => :query, :redirect_uri => redirect_uri)
    response.token
  end

  def self.oauth_client
    OAuth2::Client.new(app_id, secret_key, :site => 'https://graph.facebook.com', :token_url => 'oauth/access_token')
  end

  # Helper to convert <tt>ActiveSupport::TimeWithZone</tt> from local time to a timezone-less
  # ISO 8601 datetime string, e.g. '2010-08-15T15:30:00'
  # Use this when sending date/times for Facebook events as Facebook currently expects times
  # to be sent as a ISO 8601 datetime string without a timezone.
  # see http://bugs.developers.facebook.net/show_bug.cgi?id=7210 for the full, painful, story.
  def self.convert_time(time)
    utc_zone = ActiveSupport::TimeZone["UTC"]
    utc_zone.parse(time.strftime("%Y-%m-%d %H:%M:%S")).iso8601.chop
  end

  # Raised if a Facebook API call fails and returns an error response.
  class Error < StandardError
    def initialize(error_msg, error_code = 1) #:nodoc:
      super("FacebookApi::Error #{error_code}: #{error_msg}" )
    end
  end
end
