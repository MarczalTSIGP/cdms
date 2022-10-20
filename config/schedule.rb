env :PATH, ENV['PATH']
set :output, "/log/cron.log"

every 2.minute do
  runner "SendEmails.send"
end