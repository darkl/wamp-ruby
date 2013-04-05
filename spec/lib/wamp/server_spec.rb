require 'spec_helper'

class DummySocket
  def id
    "sampleid"
  end

  def send(*args)
    true
  end
end

describe WAMP::Server do
  let(:server) { WAMP::Server.new(host: "localhost", port: 9292) }
  let(:dummy_socket) { DummySocket.new }

  context "initilization" do
    it "should accept a hash of options" do
      expect(server.options).to eq({ host: "localhost", port: 9292 })
    end

    it "should have an empty hash of sockets" do
      expect(server.sockets).to eq({})
    end

    it "should have an empty hash of topics" do
      expect(server.topics).to eq({})
    end
  end

  context "#start" do
    # How the hell do I test this?
  end

  context "bind" do
    it "should bind a subscribe callback do" do
      expect { server.bind(:subscribe) { |client_id, topic| } }
        .to_not raise_error ""
    end

    it "should raise an error if an invalid binding name is given" do
      expect { server.bind(:invalid) {} }
        .to raise_error "Invalid binding: invalid"
    end
  end

  context "#handle_open" do
    it "should add the new socket to the hash of sockets" do
      expect { server.send(:handle_open, dummy_socket, {}) }
        .to change(server.sockets, :size).by(1)
    end
  end
end
