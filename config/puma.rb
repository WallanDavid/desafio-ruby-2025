# Puma configuration file

# The directory to operate out of.
directory File.expand_path("..", __dir__)

# Set the environment in which the rack's app will run.
environment ENV.fetch("RAILS_ENV", "development")

# Daemonize the server into the background.
# pidfile ENV.fetch("PIDFILE", "tmp/pids/server.pid")

# Store the pid of the server in the file at "path".
pidfile ENV.fetch("PIDFILE", "tmp/pids/server.pid")

# Use "path" as the file to store the server info state. This is
# used by "pumactl" to query and control the server.
state_path ENV.fetch("STATE_PATH", "tmp/pids/puma.state")

# Redirect stdout and stderr to files.
# stdout_redirect "log/puma.stdout.log", "log/puma.stderr.log", true

# Configure "min" to be the minimum number of threads to use to answer
# requests and "max" the maximum.
max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked web server processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
workers ENV.fetch("WEB_CONCURRENCY", 2)

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
preload_app!

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port ENV.fetch("PORT", 3000)

# Specifies the `bind` address that Puma will listen on.
bind ENV.fetch("BIND", "tcp://0.0.0.0:3000")

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

# Only use a pidfile when requested
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
