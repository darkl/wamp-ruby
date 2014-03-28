require 'securerandom'

module WAMP
  module Engines

    # Engine for managing clients, and topics in system memory. This engine is
    # best used for single servers.
    class ClientContainer
      attr_reader :clients

      # Creates a new instance of the memory engine as well as some empty hashes
      # for holding clients and topics.
      def initialize()
        @clients = {}
      end

      # Creates a new Socket object and adds it as a client.
      # @param websocket [WebSocket] The websocket connection that belongs to the
      #   new client
      # @return [WebSocket] Returns the newly created socket object
      def create_client(websocket)
        client = new_client(websocket)
        @clients[client.id] = client
      end

      # Finds clients by the given parameters. Currently only supports one
      #   parameter. Todo: Support multiple parameters.
      # @param args [Hash] A hash of arguments to match against the given clients
      # @return [Array] Returns an array of all matching clients.
      def find_clients(args = {})
        matching_clients = clients.find_all do |id, socket|
          socket.send(args.first[0]) == args.first[1]
        end

        matching_clients.flat_map { |x| x[1] }
      end

      # Deletes a client
      # @param socket [WebSocket] The websocket to remove from clients
      # @return [WAMP::JsonClient] The client that was removed
      def delete_client(websocket)
        client = find_clients(websocket: websocket).first

        clients.delete client.id
      end

      # Returns an array of all connected clients
      # @return [Array] Array of all connected clients.
      def all_clients
        clients.values
      end

      private

      def new_client(websocket)
        WAMP::JsonClient.new(random_uuid, websocket)
      end

      def random_uuid
        SecureRandom.random_number(2 ** 53)
      end
    end
  end
end
