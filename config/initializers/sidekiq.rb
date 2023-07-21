schedule_file = "config/schedule.yml"
if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::JOb.load_fromhash YAML.load_file(schedule_file)
end

