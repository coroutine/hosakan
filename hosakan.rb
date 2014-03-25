require 'sinatra'
require 'yajl'
require 'dotenv'
require 'heroku-api'

Dotenv.load

post '/restart_dyno' do
  payload = Yajl::Parser.parse(params[:payload])
  # search payload for dyno id
  puts payload.inspect
  # restart specific heroku dyno
  #Hosakan.restart!(find_dyno(payload))
end

def find_dyno(payload)
  "web.1"
end

class Hosakan

  APP_NAME = ENV.fetch("HEROKU_APP_NAME")
  API_KEY = ENV.fetch("HEROKU_API_KEY")

  def self.connection
    Heroku::API.new(api_key: API_KEY)
  end

  def self.restart!(dyno)
    if dyno_up?(dyno)
      connection.post_ps_restart(APP_NAME, 'ps' => dyno)
      "Dyno #{dyno} restarted...."
    else
      "Dyno #{dyno} is already up."  # log?
    end
  end

  private

  def self.dyno_up?(dyno)
    status = connection.get_ps(APP_NAME)
    status.data[:body].any? { |st| st[:process] == dyno && st[:state] == "down" }
  end

end




