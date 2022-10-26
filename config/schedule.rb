set :output, "log/cron.log"

every 1.minute do
  rake "mail:send"
end

runner "SendEmails.new().perform"