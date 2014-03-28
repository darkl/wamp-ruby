require 'faye/websocket'
require 'json'

module WAMP
  class Server
    include WAMP::Bindable

    attr_accessor :options, :callbacks, :engine

    def initialize(options = {})
      @topics    = {}
      @callbacks = {}
      @container    = WAMP::Engines::ClientContainer.new()
    end

    def available_bindings
      [:hello, :abort, :authenticate, :goodbye, :heartbeat, :register, :unregister, :call, :cancel, :yield, :error, :publish, :subscribe, :unsubscribe, :connect, :disconnect]
    end

    def start
      lambda do |env|
        Faye::WebSocket.load_adapter('thin')
        if Faye::WebSocket.websocket?(env)
          ws = Faye::WebSocket.new(env, ['wamp.2.json'], ping: 25)

          ws.onopen    = lambda { |event| handle_open(ws, event) }
          ws.onmessage = lambda { |event| handle_message(ws, event) }
          ws.onclose   = lambda { |event| handle_close(ws, event) }

          ws.rack_response
        else
          # Normal HTTP request
          [200, {'Content-Type' => 'text/plain'}, ['Hello']]
        end
      end
    end

    private

    def handle_open(websocket, event)
      client = @container.create_client(websocket)

      trigger(:connect, client)
    end

    def handle_close(websocket, event)
      # client = @container.find_clients(websocket: websocket).first
      client = @container.delete_client(websocket)

      trigger(:disconnect, client)
    end

    def handle_message(websocket, event)
      client = @container.find_clients(websocket: websocket).first

      data     = JSON.parse(event.data)
      msg_type = data.shift

      case WAMP::MessageType[msg_type]
        when :HELLO
          handle_hello(client, data)
        when :ABORT
          handle_abort(client, data)
        when :AUTHENTICATE
          handle_authenticate(client, data)
        when :GOODBYE
          handle_goodbye(client, data)
        when :HEARTBEAT
          handle_heartbeat(client, data)
        when :REGISTER
          handle_register(client, data)
        when :UNREGISTER
          handle_unregister(client, data)
        when :CALL
          handle_call(client, data)
        when :CANCEL
          handle_cancel(client, data)
        when :YIELD
          handle_yield(client, data)
        when :ERROR
          handle_error(client, data)
        when :PUBLISH
          handle_publish(client, data)
        when :SUBSCRIBE
          handle_subscribe(client, data)
        when :UNSUBSCRIBE
          handle_unsubscribe(client, data)
      end
    end

    # Handle a hello message from a client
    # HELLO data structure [HELLO, realm, details]
    def handle_hello(client, data)
      realm, details = data

      # Send real details to client
      client.welcome(client.id, details)

      trigger(:hello, client, realm, details)
    end

    # Handle a abort message from a client
    # ABORT data structure [ABORT, details, reason]
    def handle_abort(client, data)
      details, reason = data

      trigger(:abort, client, details, reason)
    end

    # Handle a authenticate message from a client
    # AUTHENTICATE data structure [AUTHENTICATE, signature, extra]
    def handle_authenticate(client, data)
      signature, extra = data

      trigger(:authenticate, client, signature, extra)
    end

    # Handle a goodbye message from a client
    # GOODBYE data structure [GOODBYE, details, reason]
    def handle_goodbye(client, data)
      details, reason = data

      trigger(:goodbye, client, details, reason)
    end

    # Handle a heartbeat message from a client
    # HEARTBEAT data structure [HEARTBEAT, incoming_seq, outgoing_seq, discard]
    def handle_heartbeat(client, data)
      incoming_seq, outgoing_seq, discard = data

      trigger(:heartbeat, client, incoming_seq, outgoing_seq, discard)
    end

    # Handle a register message from a client
    # REGISTER data structure [REGISTER, request_id, options, procedure]
    def handle_register(client, data)
      request_id, options, procedure = data

      trigger(:register, client, request_id, options, procedure)
    end

    # Handle a unregister message from a client
    # UNREGISTER data structure [UNREGISTER, request_id, registration_id]
    def handle_unregister(client, data)
      request_id, registration_id = data

      trigger(:unregister, client, request_id, registration_id)
    end

    # Handle a call message from a client
    # CALL data structure [CALL, request_id, options, procedure, arguments, arguments_keywords]
    def handle_call(client, data)
      request_id, options, procedure, arguments, arguments_keywords = data

      trigger(:call, client, request_id, options, procedure, arguments, arguments_keywords)
    end

    # Handle a cancel message from a client
    # CANCEL data structure [CANCEL, request_id, options]
    def handle_cancel(client, data)
      request_id, options = data

      trigger(:cancel, client, request_id, options)
    end

    # Handle a yield message from a client
    # YIELD data structure [YIELD, request_id, options, arguments, arguments_keywords]
    def handle_yield(client, data)
      request_id, options, arguments, arguments_keywords = data

      trigger(:yield, client, request_id, options, arguments, arguments_keywords)
    end

    # Handle a error message from a client
    # ERROR data structure [ERROR, request_type, request_id, details, error, arguments, arguments_keywords]
    def handle_error(client, data)
      request_type, request_id, details, error, arguments, arguments_keywords = data

      trigger(:error, client, request_type, request_id, details, error, arguments, arguments_keywords)
    end

    # Handle a publish message from a client
    # PUBLISH data structure [PUBLISH, request_id, options, topic_uri, arguments, argument_keywords]
    def handle_publish(client, data)
      request_id, options, topic_uri, arguments, argument_keywords = data

      trigger(:publish, client, request_id, options, topic_uri, arguments, argument_keywords)
    end

    # Handle a subscribe message from a client
    # SUBSCRIBE data structure [SUBSCRIBE, request_id, options, topic_uri]
    def handle_subscribe(client, data)
      request_id, options, topic_uri = data

      trigger(:subscribe, client, request_id, options, topic_uri)
    end

    # Handle a unsubscribe message from a client
    # UNSUBSCRIBE data structure [UNSUBSCRIBE, request_id, subscription_id]
    def handle_unsubscribe(client, data)
      request_id, subscription_id = data

      trigger(:unsubscribe, client, request_id, subscription_id)
    end

  end
end
