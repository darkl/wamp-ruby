require 'json'

module WAMP
  class JsonClient
    attr_accessor :id, :websocket

    def initialize(id, websocket)
      @id        = id
      @websocket = websocket
      @protocol  = WAMP::Protocols::Version2.new
    end

    def challenge(challenge, extra)
      @websocket.send @protocol.challenge(challenge, extra).to_json
    end

    def welcome(session, details)
      @websocket.send @protocol.welcome(session, details).to_json
    end

    def goodbye(reason, details)
      @websocket.send @protocol.goodbye(reason, details).to_json
    end

    def heartbeat(incoming_seq, outgoing_seq, discard = nil)
      @websocket.send @protocol.heartbeat(incoming_seq, outgoing_seq, discard).to_json
    end

    def error(reqest_type, request_id, details, error, arguments = nil, arguments_keywords = nil)
      @websocket.send @protocol.error(reqest_type, request_id, details, error, arguments, arguments_keywords).to_json
    end

    def registered(request_id, registration_id)
      @websocket.send @protocol.registered(request_id, registration_id).to_json
    end

    def unregistered(request_id)
      @websocket.send @protocol.unregistered(request_id).to_json
    end

    def invocation(request_id, registration_id, details, arguments = nil, arguments_keywords = nil)
      @websocket.send @protocol.invocation(request_id, registration_id, details, arguments, arguments_keywords).to_json
    end

    def interrupt(request_id, options)
      @websocket.send @protocol.interrupt(request_id, options).to_json
    end

    def result(request_id, details, arguments = nil, arguments_keywords = nil)
      @websocket.send @protocol.result(request_id, details, arguments, arguments_keywords).to_json
    end

    def published(request_id, publication_id)
      @websocket.send @protocol.published(request_id, publication_id).to_json
    end

    def subscribed(request_id, subscription_id)
      @websocket.send @protocol.subscribed(request_id, subscription_id).to_json
    end

    def unsubscribed(request_id, subscription_id)
      @websocket.send @protocol.unsubscribed(request_id, subscription_id).to_json
    end

    def event(subscription_id, publication_id, details, arguments = nil, arguments_keywords = nil)
      @websocket.send @protocol.event(subscription_id, publication_id, details, arguments, arguments_keywords).to_json
    end
  end
end
