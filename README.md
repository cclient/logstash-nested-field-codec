# logstash-nested-field-codec

### use original logstash-codec-plugins and logstash-filter-ruby decode nested-filed

like 

{
"name": "logstash-nested-field-codec",
"base64_encode": "CghKb2huIERvZRDSCRoQamRvZUBleGFtcGxlLmNvbSIMCgg1NTUtNDMyMRAB"
}

=>

{
"name": "logstash-nested-field-codec",
"base64_decode": {}
}

## RUN DEMO

### start docker contain

git clone git@github.com:cclient/logstash-n

docker run -d --name logstash-nested-field-codec -v $(pwd)/logstash-nested-field-codec:/usr/share/logstash/logstash-nested-field-codec docker.elastic.co/logstash/logstash:6.3.2  tail -f /dev/null

### start logstash server

docker exec -it logstash-nested-field-codec bash

logstash-plugin install logstash-codec-protobuf

logstash -f nested-field-codec.conf

this demo test for protobuf

to other logstash-codec-plugins just replace 

### view

https://github.com/logstash-plugins/logstash-codec-{name}/blob/master/spec/codecs/{name}_spec.rb

https://www.elastic.co/guide/en/logstash/6.3/plugins-codecs-{name}.html

get the detail config info

### example

avro 

https://github.com/logstash-plugins/logstash-codec-avro/blob/master/spec/codecs/avro_spec.rb

https://www.elastic.co/guide/en/logstash/6.3/plugins-codecs-avro.html

```avro
require 'logstash/devutils/rspec/spec_helper'
require 'avro'
require 'base64'
require 'logstash/codecs/avro'
require 'logstash/event'
...
    let (:avro_config) {{ 'schema_uri' => '
                        {"type": "record", "name": "Test",
                        "fields": [{"name": "foo", "type": ["null", "string"]},
                                   {"name": "bar", "type": "int"}]}' }}
    subject do
      allow_any_instance_of(LogStash::Codecs::Avro).to \
      receive(:open_and_read).and_return(avro_config['schema_uri'])
      next LogStash::Codecs::Avro.new(avro_config)
    end                                   
...                                   
        schema = Avro::Schema.parse(avro_config['schema_uri'])
        dw = Avro::IO::DatumWriter.new(schema)
        buffer = StringIO.new
        encoder = Avro::IO::BinaryEncoder.new(buffer)
        dw.write(test_event.to_hash, encoder)

        subject.decode(Base64.strict_encode64(buffer.string)) do |event|
          insist {event.is_a? LogStash::Event}
          insist {event.get("foo")} == test_event.get("foo")
          insist {event.get("bar")} == test_event.get("bar")
...

```

protobuf 

```protobuf
require "logstash/codecs/protobuf"
$plugin = LogStash::Codecs::Protobuf.new("class_name" => "AdsServing::Proto::BidRequest", "include_path" => ["/usr/share/logstash/protobuf.pb.rb"],"protobuf_version" => 2)
$plugin.register

def decode(encode)
  $plugin.decode(encode) do |event|
    return event.to_hash
  end
end

```

```avro
require "logstash/codecs/avro"
$subject do
      allow_any_instance_of(LogStash::Codecs::Avro).to \
      receive(:open_and_read).and_return(avro_config['schema_uri'])
      next LogStash::Codecs::Avro.new(avro_config)
end

def decode(encode)
  $subject.decode(encode) do |event|
    return event.to_hash
  end
end

```
