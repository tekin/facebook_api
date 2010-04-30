require 'logger'
require 'digest/sha2'
require 'rest_client'
require 'json'

require 'facebook_api/session'

module FacebookApi
  
  class Configuration #:nodoc:
    attr_accessor :api_key, :secret_key, :canvas_page_name, :callback_url
  end

  API_VERSION = '1.0' #:nodoc:
  REST_URL = 'http://api.facebook.com/restserver.php' #:nodoc:

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

  # Returns the api key. set this with #configure.
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

  # Verifies the signature of parmaters sent by Facebook.
  # Returns true if the signature is valid, false otherwise
  # See the API docs here[http://wiki.developers.facebook.com/index.php/Verifying_The_Signature] for
  # more details on how this is calculated.
  def self.verify_facebook_params_signature(args)
    signature = args.delete('fb_sig')
    return false if signature.nil?

    signed_args = Hash.new
    args.each do |k, v|
      if k =~ /^fb_sig_(.*)/
        signed_args[$1] = v
      end
    end

    signature == calculate_signature(signed_args)
  end

  # Verifies the signature in the cookies set by Facebook Connect checks out.
  # Returns true if the signature is valid, false otherwise.
  # See the API docs here[http://wiki.developers.facebook.com/index.php/Verifying_The_Signature#Signatures_and_Facebook_Connect_Sites] for
  # more details on how this is calculated.
  def self.verify_connect_cookies_signature(args)
    signature = args.delete(api_key)
    return false if signature.nil?

    signed_args = Hash.new
    args.each do |k, v|
      if k =~ /^#{api_key}_(.*)/
        signed_args[$1] = v
      end
    end
    
    signature == calculate_signature(signed_args)
  end

  # Calculates a signature, as described in the API docs here[http://wiki.developers.facebook.com/index.php/Verifying_The_Signature#Generating_the_Signature].
  def self.calculate_signature(params)
    params_string = params.sort.inject('') { |str, pair| str << pair[0] << '=' << pair[1] }
    Digest::MD5.hexdigest(params_string + secret_key)
  end

  # Helper to convert <tt>ActiveSupport::TimeWithZone</tt> from local time to Pacific time.
  # Use this when sending date/times to Facebook as Facebook expects times to be 
  # sent as Pacific time converted to a Unix timestamp.
  def self.convert_time(time)
    if time.is_a?(ActiveSupport::TimeWithZone)
      pacific_zone = ActiveSupport::TimeZone["Pacific Time (US & Canada)"]
      pacific_zone.parse(time.strftime("%Y-%m-%d %H:%M:%S"))
    else
      time
    end
  end

  # Raised if a Facebook API call fails and returns an error response.
  class Error < StandardError
    def initialize(error_msg, error_code = 1) #:nodoc:
      super("FacebookApi::Error #{error_code}: #{error_msg}" )
    end
  end
end
