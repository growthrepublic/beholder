require 'clickatell_proxy'

config = Rails.application.secrets.clickatell
if config
  api = Clickatell::API.authenticate(
    config["api_id"],
    config["username"],
    config["password"])

  clickatell = ClickatellProxy.new(api, config["phone_numbers"])
  Rails.configuration.clickatell = clickatell
end