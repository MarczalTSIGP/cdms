set :output, 'log/cron.log'
set :environment, ENV['RAILS_ENV']
ENV.each_key do |key|
  env key.to_sym, ENV[key]
end

every :day, at: '4:00 am' do
  runner 'SendEmails.new.perform'
end
