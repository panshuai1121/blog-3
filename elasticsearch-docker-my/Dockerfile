FROM centos:7
MAINTAINER chengtao "751753158@qq.com"
ADD ./files/CentOS7-Base-163.repo /etc/yum.repos.d/CentOS-Base.repo
ADD ./files/init.sh /root/init.sh
ADD ./files/run.sh /root/run.sh
RUN chmod +x /root/init.sh
RUN /bin/bash /root/init.sh



EXPOSE 9200
EXPOSE 9300


#CMD ["/bin/bash","/root/run.sh"]
CMD ["sudo", "-u", "elasticsearch", "/home/elasticsearch/elasticsearch-5.5.1/bin/elasticsearch"]