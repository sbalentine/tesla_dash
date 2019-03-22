TESLA_API = TeslaApi::Client.new(ENV['TESLA_ACCOUNT_EMAIL'],
                                 ENV['TESLA_CLIENT_ID'],
                                 ENV['TESLA_CLIENT_SECRET'])
TESLA_API.token = ENV['TESLA_ACCOUNT_TOKEN']