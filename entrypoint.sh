#!/bin/bash

set -x

# 将环境变量保存至 /etc/default/locale
rm -rf /etc/default/locale
env >> /etc/default/locale
# 启动 crontab
/etc/init.d/cron start

# 启动 apache
/usr/sbin/apache2ctl -D FOREGROUND
