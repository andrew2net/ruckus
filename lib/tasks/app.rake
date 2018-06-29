namespace :app do
  desc 'Migrate data from sidekiq to last_payment column in CreditCardHolder model' # Must be run only once

  task migrate_last_payment: :environment do
    jobs = Sidekiq::ScheduledSet.new
    scheduled_ids = []
    jobs.select{|x| x.klass == 'DeRecurrentPayer'}.each do |job|
      id = job.args[0]
      current_time = Time.current
      # last_payment payment should be equal to month before + amount days of days to run in sidekiq
      # See PremiumPeriodicPayments where we find those ones which has last_payment more than 1 month
      CreditCardHolder.find(id).update(last_payment: (current_time - 1.month + (current_time.to_i - job['enqueued_at'])))
      scheduled_ids << id
    end

    CreditCardHolder.where.not(id: scheduled_ids).update_all(last_payment: Time.current - 1.month)
  end
end
