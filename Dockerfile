FROM ubuntu:16.04

MAINTAINER TG <dewly_tg@163.com>

RUN apt-get update; \
    apt-get install apache2 subversion subversion-tools libapache2-svn libcgi-session-perl -y

RUN echo 'LoadModule cgid_module /usr/lib/apache2/modules/mod_cgid.so' >> /etc/apache2/apache2.conf

RUN mkdir -p /var/lib/svn/{conf,repos,cgi}; \
    touch /var/lib/svn/conf/davsvn.passwd; \
    touch /var/lib/svn/conf/davsvn.passwd; \
    chown -R www-data:www-data /var/lib/svn; 

COPY admin.cgi  /var/lib/svn/cgi/

COPY dav_svn.conf /etc/apache2/mods-enabled/
    

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

EXPOSE 80

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]

