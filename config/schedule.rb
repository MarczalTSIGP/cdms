set :output, "log/cron.log"
set :environment, ENV["RAILS_ENV"]
ENV.each_key do |key|
  env key.to_sym, ENV[key]
end

every 1.day, at: ['4:00 am', '11:04 pm'] do
  runner "SendEmails.new().perform"
end