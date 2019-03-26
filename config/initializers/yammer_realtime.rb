module YammerRealtime
    class << self
        attr_accessor :auth_token

        def configure
        yield self
        end
    end
end
  
module YammerRealtime
    class Client
        ENDPOINT = 'https://www.yammer.com/api/v1/realtime.json'

        def initialize(daemonize = true)
            @daemonize = daemonize
        end

        def start(channel_id, &block)
            @seq = 0
            @realtime_uri, token = initialization
            client_id = handshake(token)
            subscribe(client_id, channel_id)
                if @daemonize
                loop { connect(client_id, &block) }
            else
                connect(client_id, &block)
            end
        end

        def initialization
            json = get(ENDPOINT, YammerRealtime.auth_token)
            [json['realtimeURI'], json['authentication_token']]
        end

        def handshake(token)
            body = [{
                ext: { "token": token },
                version: "1.0",
                minimumVersion: "0.9",
                channel: "/meta/handshake",
                supportedConnectionTypes: ["long-polling"],
                id: @seq += 1
            }].to_json
            json = post(@realtime_uri + 'handshake', body)
            json[0]["clientId"]
        end

        def subscribe(client_id, channel_id)
            body = [{
                channel: "/meta/subscribe",
                subscription: "/feeds/#{channel_id}/primary",
                id: @seq += 1,
                clientId: client_id
            },
            {
                channel: "/meta/subscribe",
                subscription: "/feeds/#{channel_id}/secondary",
                id: @seq += 1,
                clientId: client_id
            }].to_json
            post(@realtime_uri, body)
        end

        def connect(client_id, &block)
            body = [{
                channel: "/meta/connect",
                connectionType: "long-polling",
                id: @seq += 1,
                clientId: client_id
            }].to_json
            json = post(@realtime_uri + 'connect', body)[0]
            if json and json["data"] and json["data"]["data"]
                references = json["data"]["data"]["references"]
                messages = json["data"]["data"]["messages"]
                (messages || []).each do |message|
                block.call(message, references)
                end
            end
        end

        private

        def get(url, auth_token = nil)
            uri = URI.parse(url)
            https = Net::HTTP.new(uri.host, uri.port)
            https.use_ssl = true
            https.start {
                header = if auth_token
                {
                    "Content-Type" => "application/json",
                    "Authorization" => "Bearer #{auth_token}"
                }
                else
                { "Content-Type" => "application/json" }
                end

                response = https.get(uri.path, header)
                return ::JSON.parse(response.body)
            }
            {}
        end

        def post(url, body)
            uri = URI.parse(url)
            https = Net::HTTP.new(uri.host, uri.port)
            https.use_ssl = true
            https.read_timeout = 60
            https.start {
                header = { "Content-Type" => "application/json" }

                response = https.post(uri.path, body, header)
                return ::JSON.parse(response.body)
            }
            {}
        end
    end
end

YammerRealtime.configure do |c|
    c.auth_token = ENV['YAMMER_AUTH_TOKEN']
end