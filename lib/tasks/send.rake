namespace :mail do
  desc "send email using cron"
  task send: :environment do
    SendEmails.new().perform
  end
end
