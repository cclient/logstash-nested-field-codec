require "logstash/codecs/protobuf" #logstash-plugin install logstash-codec-protobuf
$plugin = LogStash::Codecs::Protobuf.new("class_name" => "Tutorial::Person", "include_path" => ["/usr/share/logstash/logstash-nested-field-codec/addressbook.pb.rb"],"protobuf_version" => 2)
$plugin.register

def protobuf_decode(protobuf_encode)
  $plugin.decode(protobuf_encode) do |event|
    return event.to_hash
  end  
end

def json_decode(json_encode)
  return  LogStash::Json.load(json_encode)
end

def base64_decode(base64_encode)
  return Base64.decode64(base64_encode)
end

def filter(event)
  json_decode=json_decode(event.get('json_encode'))
  event.set('json_decode', json_decode)
  base64_decode=base64_decode(event.get('base64_encode'))
  event.set('base64_decode', base64_decode)
  protobuf_decode=protobuf_decode(base64_decode)
  event.set('protobuf_decode', protobuf_decode)
  return [event]
end