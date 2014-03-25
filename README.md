# Tube Depot Hosakan

_"Hosa-kan" - Japanese for "Aide"_

## Description

Tiny Sinatra application designed to receive [Papertrail](http://papertrailapp.com/ "Papertrail") webhooks, and restart failing dynos.

Given the generic nature of webhooks from Papertrail, the application should be able to gracefully handle a variety of error responses.

Notes regarding the webhooks can be found at: [Papertrail Webhooks](http://help.papertrailapp.com/kb/how-it-works/web-hooks/ "Webhooks")

## Setup
1. `bundle`

2. `cp .env.example .env`

3. update `.env` with:
	* Heroku App Name
	* Heroku Api Key - Found at [User Dashboard](https://dashboard.heroku.com/account)
	