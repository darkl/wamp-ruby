require 'faye/websocket'
require 'json'
require 'eventmachine'

module WAMP
  class Client
    include WAMP::Bindable

    attr_accessor :id, :socket, :wamp_protocol, :server_ident, :topics, :callbacks,
                  :prefixes, :ws_server

    # WAMP Client
    #   Connects to WAMP server, after connection client should receve WELCOME message
    #   from server.
    #   Client can then register prefix, call, subscribe, unsubscribe, and publish

    def initialize(options = {})
      @ws_server = options[:host] || "ws://localhost:9000"
      @protocols = options[:protocols]
      @headers = options[:headers]
      @id     = nil
      @socket = nil
      @wamp_protocol = nil
      @server_ident  = nil

      @prefixes  = {}
      @topics    = []
      @callbacks = {}
    end

    def available_bindings
      [:connect, :challenge, :welcome, :abort, :goodbye, :heartbeat, :error, :registered, :unregistered, :invocation, :interrupt, :result, :published, :subscribed, :unsubscribed, :event, :disconnect]
    end

    def start
      EM.run do
        ws = Faye::WebSocket::Client.new(ws_server, @protocols, {:headers => @headers})

        ws.onopen    = lambda { |event| handle_open(ws, event) }
        ws.onmessage = lambda { |event| handle_message(event) }
        ws.onclose   = lambda { |event| handle_close(event) }
      end
    end

    def abort(details, reason)
      @websocket.send @protocol.abort(details, reason).to_json
    end

    def authenticate(signature, extra)
      @websocket.send @protocol.authenticate(signature, extra).to_json
    end

    def goodbye(details, reason)
      @websocket.send @protocol.goodbye(details, reason).to_json
    end

    def heartbeat(incoming_seq, outgoing_seq, discard = nil)
      @websocket.send @protocol.heartbeat(incoming_seq, outgoing_seq, discard).to_json
    end

    def register(request_id, options, procedure)
      @websocket.send @protocol.register(request_id, options, procedure).to_json
    end

    def unregister(request_id, registration_id)
      @websocket.send @protocol.unregister(request_id, registration_id).to_json
    end

    def call(request_id, options, procedure, arguments = nil, arguments_keywords = nil)
      @websocket.send @protocol.call(request_id, options, procedure, arguments, arguments_keywords).to_json
    end

    def cancel(request_id, options)
      @websocket.send @protocol.cancel(request_id, options).to_json
    end

    def yield(request_id, options, arguments = nil, arguments_keywords = nil)
      @websocket.send @protocol.yield(request_id, options, arguments, arguments_keywords).to_json
    end

    def error(request_type, request_id, details, error, arguments = nil, arguments_keywords = nil)
      @websocket.send @protocol.error(request_type, request_id, details, error, arguments, arguments_keywords).to_json
    end

    def publish(request_id, options, topic_uri, arguments = nil, argument_keywords = nil)
      @websocket.send @protocol.publish(request_id, options, topic_uri, arguments, argument_keywords).to_json
    end

    def subscribe(request_id, options, topic_uri)
      @websocket.send @protocol.subscribe(request_id, options, topic_uri).to_json
    end

    def unsubscribe(request_id, subscription_id)
      @websocket.send @protocol.unsubscribe(request_id, subscription_id).to_json
    end

    def hello(realm, details)
      @websocket.send @protocol.hello(realm, details).to_json
    end

    def stop
      EM.stop
    end

    private

    def handle_open(websocket, event)
      @socket = websocket

      trigger(:connect, self)
    end

    def handle_message(data)
      data     = JSON.parse(event.data)
      msg_type = data.shift

      case WAMP::MessageType[msg_type]
        when :CHALLENGE
          handle_challenge(data)
        when :WELCOME
          handle_welcome(data)
        when :ABORT
          handle_abort(data)
        when :GOODBYE
          handle_goodbye(data)
        when :HEARTBEAT
          handle_heartbeat(data)
        when :ERROR
          handle_error(data)
        when :REGISTERED
          handle_registered(data)
        when :UNREGISTERED
          handle_unregistered(data)
        when :INVOCATION
          handle_invocation(data)
        when :INTERRUPT
          handle_interrupt(data)
        when :RESULT
          handle_result(data)
        when :PUBLISHED
          handle_published(data)
        when :SUBSCRIBED
          handle_subscribed(data)
        when :UNSUBSCRIBED
          handle_unsubscribed(data)
        when :EVENT
          handle_event(data)
        else
          handle_unknown(data)
      end
    end

    # Handle a challenge message from a client
    # CHALLENGE data structure [CHALLENGE, challenge, extra]
    def handle_challenge(data)
      challenge, extra = data

      trigger(:challenge, challenge, extra)
    end

    # Handle a welcome message from a client
    # WELCOME data structure [WELCOME, session, details]
    def handle_welcome(data)
      session, details = data

      trigger(:welcome, session, details)
    end

    # Handle a abort message from a client
    # ABORT data structure [ABORT, details, reason]
    def handle_abort(data)
      details, reason = data

      trigger(:abort, details, reason)
    end

    # Handle a goodbye message from a client
    # GOODBYE data structure [GOODBYE, details, reason]
    def handle_goodbye(data)
      details, reason = data

      trigger(:goodbye, details, reason)
    end

    # Handle a heartbeat message from a client
    # HEARTBEAT data structure [HEARTBEAT, incoming_seq, outgoing_seq, discard]
    def handle_heartbeat(data)
      incoming_seq, outgoing_seq, discard = data

      trigger(:heartbeat, incoming_seq, outgoing_seq, discard)
    end

    # Handle a error message from a client
    # ERROR data structure [ERROR, request_type, request_id, details, error, arguments, arguments_keywords]
    def handle_error(data)
      request_type, request_id, details, error, arguments, arguments_keywords = data

      trigger(:error, request_type, request_id, details, error, arguments, arguments_keywords)
    end

    # Handle a registered message from a client
    # REGISTERED data structure [REGISTERED, request_id, registration_id]
    def handle_registered(data)
      request_id, registration_id = data

      trigger(:registered, request_id, registration_id)
    end

    # Handle a unregistered message from a client
    # UNREGISTERED data structure [UNREGISTERED, request_id]
    def handle_unregistered(data)
      request_id = data

      trigger(:unregistered, request_id)
    end

    # Handle a invocation message from a client
    # INVOCATION data structure [INVOCATION, request_id, registration_id, details, arguments, arguments_keywords]
    def handle_invocation(data)
      request_id, registration_id, details, arguments, arguments_keywords = data

      trigger(:invocation, request_id, registration_id, details, arguments, arguments_keywords)
    end

    # Handle a interrupt message from a client
    # INTERRUPT data structure [INTERRUPT, request_id, options]
    def handle_interrupt(data)
      request_id, options = data

      trigger(:interrupt, request_id, options)
    end

    # Handle a result message from a client
    # RESULT data structure [RESULT, request_id, details, arguments, arguments_keywords]
    def handle_result(data)
      request_id, details, arguments, arguments_keywords = data

      trigger(:result, request_id, details, arguments, arguments_keywords)
    end

    # Handle a published message from a client
    # PUBLISHED data structure [PUBLISHED, request_id, publication_id]
    def handle_published(data)
      request_id, publication_id = data

      trigger(:published, request_id, publication_id)
    end

    # Handle a subscribed message from a client
    # SUBSCRIBED data structure [SUBSCRIBED, request_id, subscription_id]
    def handle_subscribed(data)
      request_id, subscription_id = data

      trigger(:subscribed, request_id, subscription_id)
    end

    # Handle a unsubscribed message from a client
    # UNSUBSCRIBED data structure [UNSUBSCRIBED, request_id, subscription_id]
    def handle_unsubscribed(data)
      request_id, subscription_id = data

      trigger(:unsubscribed, request_id, subscription_id)
    end

    # Handle a event message from a client
    # EVENT data structure [EVENT, subscription_id, publication_id, details, arguments, arguments_keywords]
    def handle_event(data)
      subscription_id, publication_id, details, arguments, arguments_keywords = data

      trigger(:event, subscription_id, publication_id, details, arguments, arguments_keywords)
    end

    def handle_unknown(data)
      # Do nothing
    end

    def handle_close(event)
      socket = nil
      id     = nil

      trigger(:disconnect, self)
    end
  end
end