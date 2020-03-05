#!/bin/bash

# Install packages
apt install -y supervisor
apt install -y redis-server
apt install -y cron

# Create Supervisor/Horizon configuration file
touch /etc/supervisor/conf.d/horizon.conf

# Add contents to Supervisor/Horizon configuration file
echo "[program:horizon]
process_name=%(program_name)s
command=php /home/site/wwwroot/artisan horizon
autostart=true
autorestart=true
user=root
redirect_stderr=true
stdout_logfile=/home/site/wwwroot/storage/horizon.log
stopwaitsecs=3600" >> /etc/supervisor/conf.d/horizon.conf

# Add scheduler runner to crontab
echo "* * * * * cd /home/site/wwwroot && php artisan schedule:run >> /dev/null 2>&1" >> /etc/crontab

# Reload Supervisor config, update and start Horizon
service cron start
service supervisor start
service redis-server start
supervisorctl reload
supervisorctl reread
supervisorctl update
supervisorctl start horizon

rm /home/site/wwwroot/bootstrap/cache/*

php /home/site/wwwroot/artisan telescope:publish
php /home/site/wwwroot/artisan horizon:publish

php /home/site/wwwroot/artisan cache:clear
php /home/site/wwwroot/artisan config:cache
