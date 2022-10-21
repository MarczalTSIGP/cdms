env :PATH, ENV['PATH']
set :output, "/log/cron.log"

every 1.day, at: '8:00 am' do
  runner "SendEmails.send"
end