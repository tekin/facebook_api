require 'test_helper'

class TestSession < Test::Unit::TestCase
  context 'A Facebook::Session instance' do
    setup do
      @session = FacebookApi::Session.new('ACCESS_TOKEN')
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

      should 'add format as JSON' do
        assert_equal 'JSON', @session.prepare_params(@params)['format']
      end

      should 'add the access_token' do
        assert_equal 'ACCESS_TOKEN', @session.prepare_params(@params)['access_token']
      end
    end

    context '#parse_facebook_json' do
      should 'parses valid JSON responses' do
        assert_equal [10, 20, 30], @session.parse_facebook_json(stubbed_response('[10,20,30]'))
        assert_equal ({'key' => 'value'}), @session.parse_facebook_json(stubbed_response('{"key": "value"}'))
      end

      should 'evaluate "true" response to true' do
        assert_equal true, @session.parse_facebook_json(stubbed_response('true'))
      end

      should 'evaluate "false" response to false' do
        assert_equal false, @session.parse_facebook_json(stubbed_response('false'))
      end

      should 'evaluate and return all other non-JSON literal responses as is' do
        assert_equal '341341252346', @session.parse_facebook_json(stubbed_response('341341252346'))
      end
    end


    context '#call' do
      setup do
        stub_facebook_request('Friends.get', '[10,20,30]')
      end

      should 'send the prepared params as a post request to the Facebook REST url' do
        unprepared_params = {:unprepared => 'params'}
        prepared_params = {'prepared' => 'params'}
        @session.expects(:prepare_params).with(unprepared_params).returns(prepared_params)
        @session.call('Friends.get', unprepared_params)
        assert_requested(:post, (FacebookApi::REST_URL + 'Friends.get'), :query => prepared_params)
      end

      should 'parse and return the response' do
        assert_equal [10,20,30], @session.call('Friends.get', :uid => '123456')
      end
    end


    context '#call method with a file' do
      should 'include the file in the payload' do
        params = {'format' => 'JSON'}
        file = stub
        @session.expects(:prepare_params).with({}).returns(params)
        expect_facebook_request('Photos.upload', params.merge(nil => file)).returns stubbed_response('123456')
        @session.call('Photos.upload', {}, file)
      end
    end

    context '#call method when Facebook returns an error response' do
      setup do
        stub_facebook_request('Friends.get', '{"error_code":100,"error_msg":"Parameter properties is required."}')
      end
      should 'raise an exception if an error response is received from Facebook' do
        assert_raise FacebookApi::Error do
          @session.call('Friends.get', :uid => '123456')
        end
      end
    end

    context '#call_fql' do
      setup do
        stub_facebook_request('Fql.query', '[{"offline_access":1}]')
        @query = 'SELECT offline_access FROM permissions WHERE uid = "123456"'
      end
      should 'make an Fql.query call with session params and the the supplied query' do
        expect_facebook_request('Fql.query', {'format' => 'JSON', 'query' => @query, 'access_token' => @session.access_token}).returns stubbed_response('[{"offline_access":1}]')
        @session.call_fql(@query)
      end

      should 'parse and return the response' do
        assert_equal ([{'offline_access' => 1}]), @session.call_fql(@query)
      end
    end

    context '#graph' do
      should 'make a call to the Facebook graph API' do
        stub_request(:any, (FacebookApi::GRAPH_URL + 'me')).to_return(:body => '{id: 12354}')
        @session.graph('me')
        assert_requested(:post, (FacebookApi::GRAPH_URL + 'me'), :query => {'access_token' => @session.access_token})
      end
    end
  end
end
