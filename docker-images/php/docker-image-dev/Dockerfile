FROM ubuntu:16.04

MAINTAINER chengtao "751753158@qq.com"

ADD sources.list /etc/apt/sources.list
ADD run.sh /root/run.sh
RUN chmod +x /root/run.sh
RUN apt-get update
RUN apt-get install -y php-fpm php-mysql nginx php-curl php-redis php-xdebug vim tree net-tools
RUN sed -i 's/;date.timezone =/date.timezone = Asia\/Shanghai/' /etc/php/7.0/fpm/php.ini
RUN sed -i 's/;error_log = php_errors.log/error_log = \/var\/log\/php-errors.log/' /etc/php/7.0/fpm/php.ini
RUN sed -i 's/display_errors = Off/display_errors = On/' /etc/php/7.0/fpm/php.ini
RUN touch /var/log/php-errors.log
RUN chown www-data /var/log/php-errors.log
RUN cp /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
RUN mkdir -p /run/php/
RUN mkdir /data
RUN chmod -R 777 /data
RUN echo "xdebug.remote_enable = on"     >> /etc/php/7.0/fpm/conf.d/20-xdebug.ini
RUN echo "xdebug.remote_host = 0.0.0.0"  >> /etc/php/7.0/fpm/conf.d/20-xdebug.ini
RUN echo "xdebug.remote_port = 9001"     >> /etc/php/7.0/fpm/conf.d/20-xdebug.ini
RUN echo "xdebug.idekey = PHPSTORM"      >> /etc/php/7.0/fpm/conf.d/20-xdebug.ini


EXPOSE 80
EXPOSE 9001
CMD ["/bin/bash","/root/run.sh"]