require 'sinatra'
require 'sinatra/json'
require 'dotenv'
require 'heroku-api'
require 'json'

Dotenv.load

get '/' do
  "I'm listening."
end

post '/restart_dyno' do
  raw_payload = params.fetch("payload")
  payload     = JSON.parse(raw_payload)
  logger.info "Restart request received: #{payload}"

  results = find_dynos(payload).map { |dyno|
    [dyno, Hosakan.restart!(dyno)]
  }

  json results: results
end

def find_dynos(payload)
  payload["events"].map { |event| parse_dyno_name(event["program"]) }.uniq
end

def parse_dyno_name(program)
  program.split('/')[1]
end

class Hosakan

  APP_NAME = ENV.fetch("HEROKU_APP_NAME")
  API_KEY = ENV.fetch("HEROKU_API_KEY")

  def self.connection
    Heroku::API.new(api_key: API_KEY)
  end

  def self.restart!(dyno)
    dyno = dyno.to_s.strip
    raise ArgumentError, "Invalid dyno name: #{dyno.inspect}" if dyno.empty?

    puts "Restarting [#{APP_NAME}/#{dyno}]..."
    if dyno_up?(dyno)
      connection.post_ps_restart(APP_NAME, 'ps' => dyno)
      body = "Dyno [#{APP_NAME}/#{dyno}] was restarted!"
    else
      body = "Dyno [#{APP_NAME}/#{dyno}] is down.  Not going to kick it any harder."
    end
    puts body # let's see this in the syslog!
    body      # implicit return shows this to the HTTP client
  end

  private

  def self.dyno_up?(dyno)
    dyno = dyno.to_s.strip
    raise ArgumentError, "Invalid dyno name: #{dyno.inspect}" if dyno.empty?

    statuses = connection.get_ps(APP_NAME).data.fetch(:body)
    status   = statuses.find { |st| st.fetch("process") == dyno }
    raise NameError, "No such dyno on heroku: #{dyno} >>> #{statuses}" unless !!status

    status.fetch("state").start_with? "up"
  end
end
