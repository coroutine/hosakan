require 'dotenv'
require 'heroku-api'

Dotenv.load

APP_NAME = ENV.fetch("HEROKU_APP_NAME")
API_KEY = ENV.fetch("HEROKU_API_KEY")
DYNO = "web.1"

heroku = Heroku::API.new(api_key: API_KEY)

heroku.post_ps_stop(APP_NAME, 'ps' => DYNO)

h = heroku.get_ps(APP_NAME)
puts h.data[:body].each {|b| b.inspect}


