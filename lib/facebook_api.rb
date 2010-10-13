require 'logger'
require 'digest/sha2'
require 'rest_client'
require 'json'

require 'facebook_api/session'

module FacebookApi
  
  class Configuration #:nodoc:
    attr_accessor :app_id, :api_key, :secret_key, :canvas_page_name, :callback_url
  end

  REST_URL = 'https://api.facebook.com/method/' #:nodoc:

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

  # Raised if a Facebook API call fails and returns an error response.
  class Error < StandardError
    def initialize(error_msg, error_code = 1) #:nodoc:
      super("FacebookApi::Error #{error_code}: #{error_msg}" )
    end
  end
end
