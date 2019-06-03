#Image base
FROM ubuntu:16.04

#User info
MAINTAINER dewly_tg@163.com

WORKDIR /tmp
# Install apache2, php 5.6, subversion, IF.SVNAdmin ,svn-admin
RUN apt update && \
    apt install --no-install-recommends -y software-properties-common && \
    LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && \
    apt update && \
    apt install --no-install-recommends -y apache2 libapache2-mod-php5.6 php5.6-xml subversion subversion-tools libapache2-mod-svn libapache2-svn curl unzip libcgi-session-perl cron vim && \
    curl -L https://sourceforge.net/projects/ifsvnadmin/files/svnadmin-1.6.2.zip/download > svnadmin-1.6.2.zip && \
    unzip svnadmin-1.6.2.zip -d /var/www/html/ && rm -f svnadmin-1.6.2.zip && mv /var/www/html/iF.SVNAdmin-stable-1.6.2 /var/www/html/ifadmin && \
    apt remove -y python-software-properties software-properties-common curl unzip && \
    apt clean && apt autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    bash -c 'mkdir -p /var/lib/svn/{conf,repos,cgi}' && \
    touch /var/lib/svn/conf/davsvn.passwd && \
    touch /var/lib/svn/conf/davsvn.authz && \
    chown -R www-data /var/lib/svn && \
    a2dismod -f autoindex


# Copy svn-admin.cgi to container
COPY admin.cgi  /var/lib/svn/cgi/

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV SVN_LOCATION svn
ENV SVN_ADMIN_LOCATION svnadmin
ENV SVN_HOT_BACKUPS /data/svn/backups/
ENV SVN_REPOS /var/lib/svn/repos/

#Load cig module
RUN echo 'LoadModule cgid_module /usr/lib/apache2/modules/mod_cgid.so' >> /etc/apache2/apache2.conf

#Custom dav svn configure
RUN echo '\n\
<location /${SVN_LOCATION}>\n\
    DAV svn\n\
    SVNParentPath /var/lib/svn/repos/\n\
    AuthType Basic\n\
    AuthName "Repositorios Subversion"\n\
    AuthUserFile /var/lib/svn/conf/davsvn.passwd\n\
    Require valid-user\n\
    AuthzSVNAccessFile /var/lib/svn/conf/davsvn.authz\n\
 </location>\n\

\n\
ScriptAlias /${SVN_ADMIN_LOCATION} /var/lib/svn/cgi/admin.cgi\n\
<location /${SVN_ADMIN_LOCATION}>\n\
    Options +ExecCGI\n\
    Order allow,deny\n\
    Allow from all\n\
    Satisfy All\n\
    Require valid-user\n\
    AuthType Basic\n\
    AuthName "Subversion repository"\n\
    AuthUserFile /var/lib/svn/conf/davsvn.passwd\n\
 </location>\n'\
>> /etc/apache2/mods-enabled/dav_svn.conf

RUN chmod 777 /var/www/html/ifadmin/data

# Expose apache.
EXPOSE 80


# 复制配置文件 /var/spool/cron/crontabs/
ADD root_crontab /var/spool/cron/crontabs/root
ADD hotcopy_svn.sh /root/
# 设置文件所有者和文件关联组为 root:crontab ，关联组必须为 crontab
RUN chown -R root:crontab /var/spool/cron/crontabs/root \
# 修改文件的权限，必须为 600，否则不认
 && chmod 600 /var/spool/cron/crontabs/root
# 创建 log 文件
RUN touch /var/log/cron.log

ADD entrypoint.sh .
# 在 entrypoint.sh 脚本里加入启动 apache 和 crontab 的相关命令
RUN chmod 777 ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
