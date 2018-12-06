require "logstash/codecs/protobuf"
$plugin = LogStash::Codecs::Protobuf.new("class_name" => "AdsServing::Proto::BidRequest", "include_path" => ["/usr/share/logstash/protobuf.pb.rb"],"protobuf_version" => 2)
$plugin.register

def decode(encode)
  $plugin.decode(encode) do |event|
    return event.to_hash
  end
end

def register(params)
  @source = params["source"]
  @target = params["target"]
end

def filter(event)
  decode_hash=decode(event.get(@source))
  event.set(@drop_percentage, decode_hash)
  return [event]
end