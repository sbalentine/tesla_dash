require 'yammer'

Yammer.configure do |c|
    c.access_token = ENV['YAMMER_AUTH_TOKEN']
end