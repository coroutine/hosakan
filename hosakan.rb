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

post '/reload_cache' do
  raw_payload = params.fetch("payload")
  payload = JSON.parse(raw_payload)
  logger.info "Log reload request received: #{payload}"

  results = extract_paths(payload).map do |(host, path)|
    # Forces a reload of the offending cache entry based on the path that was
    # found.
    [path, `curl 'https://#{host}#{path}' -H 'Pragma: no-cache' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: en-US,en;q=0.8,sq;q=0.6' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9[ ] mage/webp,*/*;q=0.8' -H 'Cache-Control: no-cache' -H 'Connection: keep-alive' --compressed`]
  end

  json results: results
end

def extract_paths(payload)
  payload["events"].map { |event| event["message"] =~ /path="(.+)" host=(.+) request"/ && [$2, $1]}.uniq
end

def find_dynos(payload)
  payload["events"].map { |event| parse_dyno_name(event["program"], event["message"]) }.uniq
end

def parse_dyno_name(program, message)
  reporting_dyno = program.split('/')[1]

  if reporting_dyno == "router"
    extract_dyno_from_message(message)
  else
    reporting_dyno
  end
end

def extract_dyno_from_message(message)
   pairs = message.split(/\s+/).map { |p| p.split("=") }
   _, dyno_name = pairs.select { |key, *rest| key == "dyno" }.flatten

   puts "Falling back to message-parsed dyno name [#{dyno_name}] instead of 'router'..."
   dyno_name
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
