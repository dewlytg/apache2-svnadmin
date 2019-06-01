FROM ubuntu:16.04

MAINTAINER TG <dewly_tg@163.com>

RUN apt-get update; \
    apt-get install apache2 subversion subversion-tools libapache2-svn libcgi-session-perl -y

RUN echo 'LoadModule cgid_module /usr/lib/apache2/modules/mod_cgid.so' >> /etc/apache2/apache2.conf

RUN bash -c 'mkdir -p /var/lib/svn/{conf,repos,cgi}'
RUN touch /var/lib/svn/conf/davsvn.passwd
RUN touch /var/lib/svn/conf/davsvn.passwd
RUN chown -R www-data:www-data /var/lib/svn

COPY admin.cgi  /var/lib/svn/cgi/

COPY dav_svn.conf /etc/apache2/mods-enabled/

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

EXPOSE 80

# By default, simply start apache.
CMD /usr/sbin/apache2ctl -D FOREGROUND

# Tag for docker image
TAG dewlytg/apache2-svnadmin:1.0.1
