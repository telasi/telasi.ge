class CustomerSmsWorker
  include Sidekiq::Worker

  def perform
    Customer::DebtNotification.send_notifications
  end
end

if SidekiqCron::ENABLED
  Sidekiq::Cron::Job.create(name: 'CustomerSmsWorker', cron: '* */3 * * *', klass: 'CustomerSmsWorker')
end
