require 'test_helper'

class TestSession < Test::Unit::TestCase
  context 'A Facebook::Session instance' do
    setup do
      @session = FacebookApi::Session.new('67bc4aa090e0d34954c1146b-2901279', '2901279')
    end

    should 'defer to the Facebook logger' do
      assert_equal FacebookApi.logger, @session.logger
    end


    context '#prepare_params' do
      setup do
        @params = {:method => 'Admin.getAppProperties', :properties => 'application_name'}
      end
      
      should 'stringify keys' do
        assert_equal 'Admin.getAppProperties', @session.prepare_params(@params)['method']
      end

      should 'add the api_key' do
        assert_equal FacebookApi.config.api_key, @session.prepare_params(@params)['api_key']
      end

      should 'add the API version number' do
        assert_equal FacebookApi::API_VERSION, @session.prepare_params(@params)['v']
      end

      should 'add :format as JSON' do
        assert_equal 'JSON', @session.prepare_params(@params)['format']
      end

      should 'add a generated signature' do
        FacebookApi.expects(:calculate_signature).returns('calculated signature')
        assert_equal 'calculated signature', @session.prepare_params(@params)['sig']
      end
    end


    context '#parse_facebook_json' do

      should 'parses valid JSON responses' do
        assert_equal [10, 20, 30], @session.parse_facebook_json(mock_rest_response('[10,20,30]'))
        assert_equal ({'key' => 'value'}), @session.parse_facebook_json(mock_rest_response('{"key": "value"}'))
      end

      should 'evaluate "true" response to true' do
        assert_equal true, @session.parse_facebook_json(mock_rest_response('true'))
      end

      should 'evaluate "false" response to false' do
        assert_equal false, @session.parse_facebook_json(mock_rest_response('false'))
      end

      should 'evaluate and return all other non-JSON literal responses as is' do
        assert_equal '341341252346', @session.parse_facebook_json(mock_rest_response)
      end
    end


    context '#call' do
      setup do
        stub_request(:post, FacebookApi::REST_URL).to_return(:body => '[10,20,30]')
      end

      should 'send the prepared params as a post request to the Facebook REST url' do
        @prepared_params = {:foo => 'bar'}
        @session.expects(:prepare_params).with(:method => 'Friends.get', :uid => '123456').returns(@prepared_params)
        @session.call('Friends.get', :uid => '123456')
        assert_requested(:post, FacebookApi::REST_URL) { |request| request.body == "foo=bar" }
      end

      should 'parse and return the response' do
        assert_equal [10,20,30], @session.call('Friends.get', :uid => '123456')
      end
    end

    context '#call method with a file' do
      should 'include the file in the payload' do
        params = {}
        file = stub
        @session.expects(:prepare_params).with(:method => 'Photos.upload').returns(params)
        RestClient.expects(:post).with(FacebookApi::REST_URL, {:method => 'Photos.upload', nil => file}).returns stub('response', :body => '123456')
        @session.call('Photos.upload', params, file)
      end
    end

    context '#call method when Facebook returns an error response' do
      setup do
        stub_request(:post, FacebookApi::REST_URL).to_return(:body => '{"error_code":100,"error_msg":"Parameter properties is required."}')
      end
      should 'raise an exception if an error response is received from Facebook' do
        assert_raise FacebookApi::Error do
          @session.call('Friends.get', :uid => '123456')
        end
      end
    end

    context '#call_fql' do
      setup do
        stub_request(:post, FacebookApi::REST_URL).to_return(:body => '[{"offline_access":1}]')
        @query = 'SELECT offline_access FROM permissions WHERE uid = "123456"'
      end
      should 'make an Fql.query call with the supplied quiery' do
        RestClient.expects(:post).with(FacebookApi::REST_URL, has_entries('query' => @query, 'method' => 'Fql.query')).returns(stub('response', :body => '[{"offline_access":1}]'))
        @session.call_fql(@query)
      end

      should 'parse and return the response' do
        assert_equal ([{'offline_access' => 1}]), @session.call_fql(@query)
      end
    end
  end
end
