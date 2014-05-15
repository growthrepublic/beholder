set :output, "log/whenever.log"

every 1.minute do
  runner "App.monitor_health"
end