module FacebookApi
  # FacebookApi::Session is your window to the Facebook REST API. Once you have a 
  # valid session, you can make API calls with #call and fql calls with #call_fql.
  #
  # Example usage:
  #
  #   session = FacebookApi::Session.new(session_key, uid)
  #   
  #   # Make REST API calls
  #   response = session.call('Friends.get', :uid => '12345')
  #   # Make calls with file attachments
  #   response = session.call('Photos.upload', {:uid => '12345', :aid => '67890', :caption => 'your caption'}, File.new('/path/to/image.jpg))
  #   # Make fql calls
  #   response = session.call_fql('SELECT page_id FROM page_admin WHERE uid="12345"') 
  class Session
    attr_reader :session_key, :uid #:nodoc:
    
    # Initialise a FacebookApi::Session with a valid session key and uid.
    def initialize(session_key, uid)
      @session_key = session_key
      @uid = uid
    end

    # Alias for the FacebookApi.logger.
    def logger
      FacebookApi.logger
    end

    # Makes a Facebook API REST call.
    # If a file is specified, this will be included in the call, e.g. when calling Photos.upload.
    # Example usage:
    #
    #   response = session.call('Friends.get', :uid => '12345')
    #   response = session.call('Photos.upload', {:uid => '12345', :aid => '67890', :caption => 'your caption'}, File.new('/path/to/image.jpg))
    #
    # Returns the response from Facebook as either a hash, boolean or literal, depending on what Facebook returns.
    # Raises FacebookApi::Error if Facebook returns with an error.
    def call(method, params = {}, file = nil)
      params[:method] = method
      begin
        params = prepare_params(params)
        logger.debug "Sending request to facebook: #{params.inspect}"
        params[nil] = file if file
        response = RestClient.post(FacebookApi::REST_URL, params)
      rescue SocketError => e
        raise IOError.new("Cannot connect to facebook: #{e}")
      end
      logger.debug "Receiving response from facebook: \"#{response.body}\""
      parse_facebook_json response
    end

    # Makes a Facebook API REST FQL call.
    # Returns the response from Facebook as either a hash, boolean or literal, depending on what Facebook returns.
    # Example:
    #
    #   response = session.call('SELECT page_id FROM page_admin WHERE uid="12345"') 
    def call_fql(query)
      call('Fql.query', :query => query)
    end

    # Prepares passed in params ready for sending to Facebook with a REST call.
    def prepare_params(params)
      s_params = {}
      params.each_pair {|k,v| s_params[k.to_s] = v }
      s_params['api_key'] = FacebookApi.api_key
      s_params['v'] = FacebookApi::API_VERSION
      s_params['call_id'] = Time.now.to_f.to_s
      s_params['format'] = 'JSON'
      s_params['sig'] = FacebookApi.calculate_signature(s_params)
      s_params
    end

    # Because Facebook does not always return valid JSON, we need to pre-parse it and catch
    # the special cases.
    # If the response is JSON, this returns the parsed response. Otherwise it catches
    # "true", "false" and string letirals, returning true, false or the string respectively. 
    # Raises Facebook::APIError if the response from Facebook is an error message.
    def parse_facebook_json(response)
      body = response.body
      if looks_like_json? body
        data = JSON.parse body
        raise FacebookApi::Error.new(data['error_msg'], data['error_code']) if data.include?('error_msg')
      else
        data = parse_literal body
      end
      data
    end

    private 

    def looks_like_json?(string)
      # If it starts with a '[' or a '{', then it looks like JSON to me.
      string =~ /^[\[\{]/
    end

    def parse_literal(string)
      case string
        when 'true' then true
        when 'false' then false
        else string
      end
    end
  end
end
