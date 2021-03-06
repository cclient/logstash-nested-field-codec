# logstash-nested-field-codec

### use original logstash-codec-plugins and logstash-filter-ruby decode nested-filed

like 

```source

{
    "name": "logstash-nested-field-codec",
    "base64_encode": "CghKb2huIERvZRDSCRoQamRvZUBleGFtcGxlLmNvbSIMCgg1NTUtNDMyMRAB"
}

```


=>

```target

{
  "name": "logstash-nested-field-codec",
  "base64_decode": {
    "key":"value"
  }
}
```

## RUN DEMO

### run docker contain

* `git clone git@github.com:cclient/logstash-nested-field-codec`

* `docker run -d --name logstash-nested-field-codec -v $(pwd)/logstash-nested-field-codec:/usr/share/logstash/logstash-nested-field-codec docker.elastic.co/logstash/logstash:6.3.2  tail -f /dev/null`

### start logstash

* `docker exec -it logstash-nested-field-codec bash`

* `logstash-plugin install logstash-codec-protobuf`

* `logstash -f logstash-nested-field-codec/nested-field-codec.conf`

#### new session

`docker exec -it logstash-nested-field-codec bash`

`echo -e "\n" >>  logstash-nested-field-codec/log/demo.json`

#expect out

```json
{
    "base64_encode": "CghKb2huIERvZRDSCRoQamRvZUBleGFtcGxlLmNvbSIMCgg1NTUtNDMyMRAB",
    "name": "logstash-nested-field-codec",
    "json_decode": {
        "k": "v"
    },
    "base64_decode": "\n\bJohn Doe\u0010Ò\t\u001a\u0010jdoe@example.com\"\f\n\b555-4321\u0010\u0001",
    "protobuf_decode": {
        "@version": "1",
        "phones": [
            {
                "type": 1,
                "number": "555-4321"
            }
        ],
        "email": "jdoe@example.com",
        "id": 1234,
        "@timestamp": "2018-12-07T02:52:08.497Z",
        "name": "John Doe"
    },
    "path": "/usr/share/logstash/logstash-nested-field-codec/log/demo.json",
    "host": "1753d2919ebe",
    "json_encode": "{\"k\":\"v\"}",
    "@timestamp": "2018-12-07T02:52:07.945Z",
    "@version": "1"
}
```

this demo test for protobuf to other logstash-codec-plugins

### view

https://github.com/logstash-plugins/logstash-codec-{name}/blob/master/spec/codecs/{name}_spec.rb

https://www.elastic.co/guide/en/logstash/6.3/plugins-codecs-{name}.html

get detail config info

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
        subject.decode(buffer.string) do |event|
          insist {event.is_a? LogStash::Event}
          insist {event.get("foo")} == test_event.get("foo")
          insist {event.get("bar")} == test_event.get("bar")
        end
...

```

custom_codec_avro.rb

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
