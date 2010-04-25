require "logger"
require "digest/sha2"

module FacebookApi
  class Configuration
    attr_accessor :api_key, :secret_key, :canvas_page_name, :callback_url
  end

  REST_URL = "http://api.facebook.com/restserver.php"
  @config = Configuration.new
  @logger = nil

  def self.logger
    unless @logger
      @logger = ::Logger.new($stdout)
      @logger.level = Logger::INFO
    end
    @logger
  end

  # Allows you to set your Facebook configuration for accessing the API:
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

  # Returns the current Facebook configuration
  def self.config
    @config
  end

  # Verifies the signature in the cookies set by Facebook Connect checks out.
  # Returns true if the signature is valid, fase otherwise.
  # See http://wiki.developers.facebook.com/index.php/Verifying_The_Signature#Signatures_and_Facebook_Connect_Sites
  def self.verify_connect_cookies(args)
    signature = args.delete(config.api_key)
    return false if signature.nil?

    signed_args = Hash.new
    args.each do |k, v|
      if k =~ /^#{config.api_key}_(.*)/
        signed_args[$1] = v
      end
    end

    signature == calculate_signature(signed_args)
  end

  # Calculates a signature, as described here: http://wiki.developers.facebook.com/index.php/Verifying_The_Signature#Generating_the_Signature
  def self.calculate_signature(params)
    params_string = params.sort.inject('') { |str, pair| str << pair[0] << '=' << pair[1] }
    Digest::MD5.hexdigest(params_string + config.secret_key)
  end

  # Helper to convert ActiveSupport::TimeWithZone from local time to Pacific time.
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
end
