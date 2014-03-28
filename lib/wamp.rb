module WAMP
  MAJOR = 0
  MINOR = 0
  PATCH = 1

  ROOT = File.expand_path(File.dirname(__FILE__))

  autoload :Bindable,    File.join(ROOT, "wamp", "bindable")
  autoload :Client,      File.join(ROOT, "wamp", "client")
  autoload :Server,      File.join(ROOT, "wamp", "server")
  autoload :JsonClient,      File.join(ROOT, "wamp", "json_client")
  autoload :MessageType, File.join(ROOT, "wamp", "message_type")

  module Engines
    autoload :ClientContainer, File.join(ROOT, "wamp", "engines", "client_container")
  end

  module Protocols
    autoload :Version2, File.join(ROOT, "wamp", "protocols", "version_2")
  end

  class << self
    def version
      "#{MAJOR}.#{MINOR}.#{PATCH}"
    end

    def identity
      "WAMP Ruby/#{self.version}"
    end

    def protocol_version
      1
    end
  end
end
