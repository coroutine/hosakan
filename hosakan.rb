require 'sinatra'
require 'yajl'
require 'dotenv'
require 'heroku-api'

Dotenv.load

post '/restart_dyno' do
  puts params.inspect
  #payload = Yajl::Parser.parse(params[:payload])
  #find_dynos(payload).each { |dyno| Hosakan.restart!(dyno) }
end

def find_dynos(payload)
  payload["events"].map { |event| parse_dyno_name(event["program"]) }.uniq
end

def parse_dyno_name(program)
  program.delete "app/"
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




