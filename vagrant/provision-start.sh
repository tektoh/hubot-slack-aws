cd /vagrant
if [ -f tmp/pids/server.pid ]; then
  kill -KILL `cat tmp/pids/server.pid`
  rm -f tmp/pids/server.pid
fi
bundle install
bundle exec rails server -d -p 3000 -b 0.0.0.0 -e development
