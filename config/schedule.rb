set :output, "log/cron.log"
set :environment, ENV["RAILS_ENV"]
ENV.each_key do |key|
  env key.to_sym, ENV[key]
end

every 1.day, at: ['4:00 am', '11:48 am'] do
  runner "SendEmails.new().perform"
end

every 10.minute do
  runner "SendEmails.new().perform"
end