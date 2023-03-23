set :output, 'log/cron.log'
set :environment, ENV.fetch('RAILS_ENV', nil)
ENV.each_key do |key|
  env key.to_sym, ENV.fetch(key, nil)
end

every :day, at: '4:00 am' do
  runner 'SendEmails.new.perform'
end
