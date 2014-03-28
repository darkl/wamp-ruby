module WAMP::MessageType
  # Message types with ID per the WAMP Specification located at
  # http://wamp.ws/spec#message_types

  TYPES = {
      HELLO:        1,
      WELCOME:      2,
      ABORT:        3,
      CHALLENGE:    4,
      AUTHENTICATE: 5,
      GOODBYE:      6,
      HEARTBEAT:    7,
      ERROR:        8,
      PUBLISH:      16,
      PUBLISHED:    17,
      SUBSCRIBE:    32,
      SUBSCRIBED:   33,
      UNSUBSCRIBE:  34,
      UNSUBSCRIBED: 35,
      EVENT:        36,
      CALL:         48,
      CANCEL:       49,
      RESULT:       50,
      REGISTER:     64,
      REGISTERED:   65,
      UNREGISTER:   66,
      UNREGISTERED: 67,
      INVOCATION:   68,
      INTERRUPT:    69,
      YIELD:        70
  }

  class << self
    # Get MessageType ID with symbolized name, or get symbolized name with an ID
    # Usage:
    #   WAMP::MessageType[:WELCOME] #=> 0
    #   WAMP::MessageType[0]        #=> :WELCOME
    def [](id)
      if id.is_a? Integer
        TYPES.key(id)
      else
        TYPES[id]
      end
    end
  end
end
