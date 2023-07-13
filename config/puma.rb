max_threads_count = ENV.fetch('RAILS_MAX_THREADS', 5)
min_threads_count = ENV.fetch('RAILS_MIN_THREADS') { max_threads_count }
workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads min_threads_count, max_threads_count

nakayoshi_fork
wait_for_less_busy_worker
fork_worker

rails_env = ENV.fetch('RAILS_ENV', 'development')
rails_port = ENV.fetch('PORT', 3000)
environment rails_env
pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')

if rails_env == 'development'
  ssl_bind(
    '0.0.0.0',
    rails_port,
    key: ENV.fetch('SSL_KEY_FILE', 'config/certs/localhost-key.pem'),
    cert: ENV.fetch('SSL_CERT_FILE', 'config/certs/localhost.pem'),
    verify_mode: 'none'
  )
else
  port rails_port
end

plugin :tmp_restart

preload_app!
