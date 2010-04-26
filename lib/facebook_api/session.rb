module FacebookApi
  class Session
    attr_reader :session_key, :uid
    
    def initialize(session_key, uid)
      @session_key = session_key
      @uid = uid
    end

    def logger
      FacebookApi.logger
    end

    # Makes a REST call to the Facebook API.
    # If a file is specified, this will be included in the call, e.g.
    # when calling Events.create or Photos.upload)
    # Example:
    #
    #   session.call('Friends.get', :uid => '12345')
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

    # Make a REST FQL call to the Facebook API.
    # Example:
    #
    #   session.call('SELECT page_id FROM page_admin WHERE uid="12345"') 
    def call_fql(query)
      call('Fql.query', :query => query)
    end

    # Prepares passed in params ready for sending to Facebook with a REST call
    def prepare_params(params)
      s_params = {}
      params.each_pair {|k,v| s_params[k.to_s] = v }
      s_params['api_key'] = FacebookApi.config.api_key
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
