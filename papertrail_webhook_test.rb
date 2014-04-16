#!/usr/bin/ruby -w

# See http://help.papertrailapp.com/kb/how-it-works/web-hooks

require 'yajl'
require 'faraday'

class PapertrailWebhookRequest
  def self.connection
    Faraday::Connection.new
  end

  def self.run
    results = {
      "payload" => {
        "saved_search" => {
          :id   => 42,
          :name => "Test search",
          :html_search_url => "https://papertrailapp.com/searches/42",
          :html_edit_url => "https://papertrailapp.com/searches/42/edit"
        },
        "events" => [
          { "program" => "appname/web.1",
            "display_received_at" => "May 06 12:28:00",
            "source_ip" => "1.2.3.4",
            "source_name" => "somehost1",
            "received_at" => "2011-07-06T12:28:00-07:00",
            "message" => "NOQUEUE: reject: RCPT from 112-104-145-149.adsl.dynamic.seed.net.tw[112.104.145.149]: 554 5.7.1 <a@b.com>: Relay access denied; from=<c@d.com>",
            "facility" => "User",
            "severity" => "Notice",
            "source_id" => 27223,
            "id" => 3241602919305216,
            "hostname" => "somehost1" },

          { "program" => "appname/web.1",
            "display_received_at" => "May 06 12:28:30",
            "source_ip" => "4.5.6.7",
            "source_name" => "somehost4",
            "received_at" => "2011-07-06T12:28:30-07:00",
            "message" => "Completed in 50ms (View: 2, DB: 22) | 200 OK [https://adomain.com/path]",
            "facility" => "User",
            "severity" => "Notice",
            "source_id" => 38281,
            "id" => 3241602919305299,
            "hostname" => "somehost4" }
        ],
        "max_id" => 3241602919300000,
        "min_id" => 3241602919310000
      }
    }

    connection.post do |req|
      req.url 'http://localhost:4567/restart_dyno'
      req.body = {
        :payload  => Yajl::Encoder.encode(results['payload'])
      }
    end
  end
end

r = PapertrailWebhookRequest.run

puts "Response:\n#{r.body}"
