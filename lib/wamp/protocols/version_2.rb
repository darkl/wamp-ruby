require 'json'

module WAMP::Protocols

  # Describes the WAMP protocol messages per http://www.wamp.ws/spec#call_message
  class Version2
    # @return [Integer] The version of the WAMP protocol defined in this class.
    def version
      2
    end

    def challenge(challenge, extra)
      [type[:CHALLENGE], challenge, extra]
    end

    def welcome(session, details)
      [type[:WELCOME], session, details]
    end

    def goodbye(reason, details)
      [type[:GOODBYE], reason, details]
    end

    def heartbeat(incoming_seq, outgoing_seq, discard = nil)
      msg = [type[:HEARTBEAT], incoming_seq, outgoing_seq]
      msg[2] = discard unless discard.nil?
      msg
    end

    def error(request_type, request_id, details, error, arguments = nil, arguments_keywords = nil)
      msg = [type[:ERROR], request_type, request_id, details, error]
      msg[4] = arguments unless arguments.nil?
      msg[5] = arguments_keywords unless arguments_keywords.nil?
      msg
    end

    def registered(request_id, registration_id)
      [type[:REGISTERED], request_id, registration_id]
    end

    def unregistered(request_id)
      [type[:UNREGISTERED], request_id]
    end

    def invocation(request_id, registration_id, details, arguments = nil, arguments_keywords = nil)
      msg = [type[:INVOCATION], request_id, registration_id, details]
      msg[3] = arguments unless arguments.nil?
      msg[4] = arguments_keywords unless arguments_keywords.nil?
      msg
    end

    def interrupt(request_id, options)
      [type[:INTERRUPT], request_id, options]
    end

    def result(request_id, details, arguments = nil, arguments_keywords = nil)
      msg = [type[:RESULT], request_id, details]
      msg[2] = arguments unless arguments.nil?
      msg[3] = arguments_keywords unless arguments_keywords.nil?
      msg
    end

    def published(request_id, publication_id)
      [type[:PUBLISHED], request_id, publication_id]
    end

    def subscribed(request_id, subscription_id)
      [type[:SUBSCRIBED], request_id, subscription_id]
    end

    def unsubscribed(request_id, subscription_id)
      [type[:UNSUBSCRIBED], request_id, subscription_id]
    end

    def event(subscription_id, publication_id, details, arguments = nil, arguments_keywords = nil)
      msg = [type[:EVENT], subscription_id, publication_id, details]
      msg[3] = arguments unless arguments.nil?
      msg[4] = arguments_keywords unless arguments_keywords.nil?
      msg
    end

    def hello(realm, details)
      [type[:HELLO], realm, details]
    end

    def authenticate(signature, extra)
      [type[:AUTHENTICATE], signature, extra]
    end

    def register(request_id, options, procedure)
      [type[:REGISTER], request_id, options, procedure]
    end

    def unregister(request_id, registration_id)
      [type[:UNREGISTER], request_id, registration_id]
    end

    def call(request_id, options, procedure, arguments = nil, arguments_keywords = nil)
      msg = [type[:CALL], request_id, options, procedure]
      msg[3] = arguments unless arguments.nil?
      msg[4] = arguments_keywords unless arguments_keywords.nil?
      msg
    end

    def cancel(request_id, options)
      [type[:CANCEL], request_id, options]
    end

    def yield(request_id, options, arguments = nil, arguments_keywords = nil)
      msg = [type[:YIELD], request_id, options]
      msg[2] = arguments unless arguments.nil?
      msg[3] = arguments_keywords unless arguments_keywords.nil?
      msg
    end

    def publish(request_id, options, topic_uri, arguments = nil, argument_keywords = nil)
      msg = [type[:PUBLISH], request_id, options, topic_uri]
      msg[3] = arguments unless arguments.nil?
      msg[4] = argument_keywords unless argument_keywords.nil?
      msg
    end

    def subscribe(request_id, options, topic_uri)
      [type[:SUBSCRIBE], request_id, options, topic_uri]
    end

    def unsubscribe(request_id, subscription_id)
      [type[:UNSUBSCRIBE], request_id, subscription_id]
    end

    private

    def type
      WAMP::MessageType
    end
  end
end
