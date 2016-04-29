# Hosakan

_"Hosa-kan" - Japanese for "Aide"_

![screenshot of hosakan restarting a dyno](http://i.imgur.com/l8PVPxq.png)

## Description

Tiny Sinatra application designed to receive [Papertrail](http://papertrailapp.com/ "Papertrail") webhooks, and restart failing dynos.

Given the generic nature of webhooks from Papertrail, the application should be able to gracefully handle a variety of error responses. In Papertrail, simply define the error parameters and point the webhook at the webservice. Hosakan will parse the webhook, find the "broken" dyno, and restart as necessary.

Notes regarding the webhooks can be found at: [Papertrail Webhooks](http://help.papertrailapp.com/kb/how-it-works/web-hooks/ "Webhooks")

## How it works
Hosakan listens on `/restart_dynos` for papertrail webhook data (see a [sample Papertrail payload here](sample_payload.rb)).  We attempt to parse heroku dyno names out of the Papertrail log payload and then restart the dynos by name using the Heroku API.

__Note__:  Hosakan doesn't care why you sent it a log entry, it'll just restart the dyno.  Be sure you only send it alerts for log entries that justify restarting a dyno!

## Local Setup
1. `bundle`

2. `cp .env.sample .env`

3. update `.env` with:
	* Heroku App Name
	* Heroku Api Key - Found at [User Dashboard](https://dashboard.heroku.com/account)


## Testing
`rake test`

### Testing Papertrail webhooks before deploying
Try using [ngrok](https://ngrok.com/) to expose your local Sinatra port (probably 4567) to the outside world and then point a Papertrail webhook at that URL.  You should be able to trigger a test webhook out of Papertrail and see it show up in your Hosakan logs.

## Deployment
[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

Hosakan is intended to run as a Heroku web app, just be sure to set your environment variables `HEROKU_APP_NAME` and `HEROKU_API_KEY` so that it can remotely restart your main app when it receives webhooks from Papertrail.  You can surely run it anywhere else you could deploy Sinatra apps as well.

## License
[MIT License](LICENSE.md)

## Contributors
* Mark Morris
* Daniel Pritchett

[![Coroutine](https://avatars3.githubusercontent.com/u/93263?s=140)](http://coroutine.com)
