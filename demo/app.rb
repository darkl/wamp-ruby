require '../lib/wamp'
require 'json'
require 'pry'

App = WAMP::Server.new

def log(text)
  puts "[#{Time.now}] #{text}"
end

App.bind(:connect) do |client|
  log "#{client.id} connected"
end

App.bind(:hello) do |client, realm, details|
  log "#{client.id} called Hello with parameters #{realm}, #{details}"
end

App.bind(:authenticate) do |client, signature, extra|
  log "#{client.id} called Authenticate with parameters #{signature}, #{extra}"
end

App.bind(:goodbye) do |client, reason, details|
  log "#{client.id} called Goodbye with parameters #{reason}, #{details}"
end

App.bind(:heartbeat) do |client, incoming_seq, outgoing_seq, discard|
  log "#{client.id} called Heartbeat with parameters #{incoming_seq}, #{outgoing_seq}, #{discard}"
end

App.bind(:register) do |client, request_id, options, procedure|
  log "#{client.id} called Register with parameters #{request_id}, #{options}, #{procedure}"
end

App.bind(:unregister) do |client, request_id, registration_id|
  log "#{client.id} called Unregister with parameters #{request_id}, #{registration_id}"
end

App.bind(:call) do |client, request_id, options, procedure, arguments, arguments_keywords|
  log "#{client.id} called Call with parameters #{request_id}, #{options}, #{procedure}, #{arguments}, #{arguments_keywords}"
  client.result(request_id, options, [], [procedure])
end

App.bind(:cancel) do |client, request_id, options|
  log "#{client.id} called Cancel with parameters #{request_id}, #{options}"
end

App.bind(:yield) do |client, request_id, options, arguments, arguments_keywords|
  log "#{client.id} called Yield with parameters #{request_id}, #{options}, #{arguments}, #{arguments_keywords}"
end

App.bind(:error) do |client, request_type, request_id, details, error, arguments, arguments_keywords|
  log "#{client.id} called Error with parameters #{request_type}, #{request_id}, #{details}, #{error}, #{arguments}, #{arguments_keywords}"
end

App.bind(:publish) do |client, request_id, options, topic_uri, arguments, argument_keywords|
  log "#{client.id} called Publish with parameters #{request_id}, #{options}, #{topic_uri}, #{arguments}, #{argument_keywords}"
end

App.bind(:subscribe) do |client, request_id, options, topic_uri|
  log "#{client.id} called Subscribe with parameters #{request_id}, #{options}, #{topic_uri}"
end

App.bind(:unsubscribe) do |client, request_id, subscription_id|
  log "#{client.id} called Unsubscribe with parameters #{request_id}, #{subscription_id}"
end


App.bind(:disconnect) do |client|
  log "#{client.id} disconnected"
end