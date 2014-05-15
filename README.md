beholder [![Code Climate](https://codeclimate.com/github/growthrepublic/beholder.png)](https://codeclimate.com/github/growthrepublic/beholder)
========

Beholder is watching your applications and notifies you about any breakdowns by sending sms message.

### Ruby version

2.1.1

### Configuration

Install gems:

      $ bundle install

Edit config/database.yml to set up database connection.

Clickatell is reliable and not so expensive platform for sending sms messages,
you can set up your Developers' Central account [here](https://www.clickatell.com/register/).
Then, edit config/secrets.yml to set up clickatell connection.

Create database:

      $ bundle exec rake db:create db:migrate

### How to run the test suite

If it is your first time, running test suite for this app, run this to build db for test:

      $ bundle exec rake db:create RAILS_ENV=test

And then run rspec:

      $ bundle exec rspec