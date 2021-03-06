    
# Mac中使用Vagrant安装Hadoop
# 1 基础配置



## 1.1 安装nginx
    brew install nginx
    
    
    
-------


    server {
        server_name soft.home;
        listen 80;
        access_log  /usr/local/var/log/nginx/proxy_access.log;
        error_log   /usr/local/var/log/nginx/proxy_error.log;
        root /Users/chengtao/cloud/vagrant/soft;
    }    


# 2.配置Hadoop环境

## 1.1 配置vagrant环境

    mkdir -p ~/cloud/vagrant/hadoop
    vagrant box add centos/7
    

## 1.2 配置虚拟机的文件


**Vagrantfile**



    Vagrant.configure("2") do |config|
      config.vm.box = "centos/7"
      config.vm.network "public_network", auto_config: false, bridge: "en1: Wi-Fi (AirPort)"
      config.vm.provision "shell", inline: <<-SHELL
        #install base soft
        #cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
        #cp /vagrant/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
        
        yum install -y net-tools wget tree 
        #install jdk
        echo "192.168.31.185 soft.home" >> /etc/hosts
        mkdir /root/soft
        wget -O /root/soft/jdk-8u144-linux-x64.rpm http://soft.home/jdk-8u144-linux-x64.rpm
        rpm -ivh /root/soft/jdk-8u144-linux-x64.rpm
        JAVA_HOME=/usr/java/jdk1.8.0_144
        PATH=$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/lib 
        CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
        export JAVA_HOME PATH CLASSPATH
        echo "JAVA_HOME=/usr/java/jdk1.8.0_144" >> /root/.bash_profile
        echo "PATH=$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/lib " >> /root/.bash_profile
        echo "CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar" >> /root/.bash_profile
        echo "export JAVA_HOME PATH CLASSPATH" >> /root/.bash_profile
        echo "alias vim=vi" >> /root/.bash_profile
        #stop SELinux
        setenforce 0 
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
        #config sshd
        echo "RSAAuthentication yes" >>/etc/ssh/sshd_config
        echo "PubkeyAuthentication yes" >>/etc/ssh/sshd_config
        sed -i 's/PasswordAuthentication\ no/PasswordAuthentication\ yes/' /etc/ssh/sshd_config
        /bin/systemctl restart  sshd.service
        mkdir -p /root/.ssh
        touch /root/.ssh/authorized_keys
        chmod 700 -R /root/.ssh
        chmod 600 /root/.ssh/authorized_keys
        ssh-keygen -t rsa -P "" -f /root/.ssh/id_rsa
        cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys 
        
        echo '192.168.31.130 hadoop_master' >> /etc/hosts 
        echo '192.168.31.131 hadoop_node1' >> /etc/hosts 
        echo '192.168.31.132 hadoop_node2' >> /etc/hosts  
        
      SHELL
    
      config.vm.define "hadoop_master" do |hadoop_master|
        #download hadoop
        hadoop_master.vm.provision "shell",inline:<<-SHELL
          mkdir -p /home/hadoop/tmp
          mkdir -p /home/hadoop/hdfs/data
          mkdir -p /home/hadoop/hdfs/name
          cd /home/hadoop
          wget http://soft.home/hadoop-2.8.1.tar.gz
          tar zvxf hadoop-2.8.1.tar.gz
          cd /home/hadoop/hadoop-2.8.1/etc/hadoop
          sed -i 's/export JAVA_HOME=${JAVA_HOME}/export JAVA_HOME=\/usr\/java\/jdk1.8.0_144/' hadoop-env.sh
          mv core-site.xml core-site.xml.bak
          mv hdfs-site.xml hdfs-site.xml.bak
          mv slaves slaves.bak
          cp /vagrant/slaves .
          cp /vagrant/*.xml . 
          systemctl stop firewalld.service
          hostnamectl set-hostname hadoop_master
        SHELL
    
        #config network
        hadoop_master.vm.provision "shell",run: "always",inline:<<-SHELL
          ifconfig eth1 192.168.31.130 netmask 255.255.255.0 up
        SHELL
      end
      
      config.vm.define "hadoop_node1" do |hadoop_node1|
        hadoop_node1.vm.provision "shell",inline:<<-SHELL
          hostnamectl set-hostname hadoop_node1
        SHELL
        hadoop_node1.vm.provision "shell",run: "always",inline:<<-SHELL
          ifconfig eth1 192.168.31.131 netmask 255.255.255.0 up
        SHELL
      end
      
      config.vm.define "hadoop_node2" do |hadoop_node2|
        hadoop_node2.vm.provision "shell",inline:<<-SHELL
          hostnamectl set-hostname hadoop_node2
        SHELL
        hadoop_node2.vm.provision "shell",run: "always",inline:<<-SHELL
          ifconfig eth1 192.168.31.132 netmask 255.255.255.0 up
        SHELL
      end
    end


-------

    
    1.配置/home/hadoop/hadoop-2.8.1/etc/hadoop目录下的core-site.xml
    <configuration>
        <property>
            <name>fs.defaultFS</name>
            <value>hdfs://192.168.31.130:9000</value>
        </property>
        <property>
            <name>hadoop.tmp.dir</name>
            <value>file:/home/hadoop/tmp</value>
        </property>
        <property>
            <name>io.file.buffer.size</name>
            <value>131702</value>
        </property>
     </configuration>
    
    
    2.配置/home/hadoop/hadoop-2.8.1/etc/hadoop目录下的hdfs-site.xml
     <configuration>
        <property>
            <name>dfs.namenode.name.dir</name>
            <value>file:/home/hadoop/dfs/name</value>
        </property>
        <property>
            <name>dfs.datanode.data.dir</name>
            <value>file:/home/hadoop/dfs/data</value>
        </property>
        <property>
            <name>dfs.replication</name>
            <value>2</value>
        </property>
        <property>
            <name>dfs.namenode.secondary.http-address</name>
            <value>192.168.31.130:9001</value>
        </property>
        <property>
    	    <name>dfs.webhdfs.enabled</name>
    	    <value>true</value>
        </property>
     </configuration>
    
    3.配置/home/hadoop/hadoop-2.8.1/etc/hadoop目录下的mapred-site.xml
     <configuration>
        <property>
            <name>mapreduce.framework.name</name>
            <value>yarn</value>
        </property>
        <property>
            <name>mapreduce.jobhistory.address</name>
            <value>192.168.31.130:10020</value>
        </property>
        <property>
            <name>mapreduce.jobhistory.webapp.address</name>
            <value>192.168.31.130:19888</value>
        </property>
     </configuration>
    
    
    4.配置/home/hadoop/hadoop-2.8.1/etc/hadoop目录下的mapred-site.xml
     <configuration>
        <property>
            <name>yarn.nodemanager.aux-services</name>
            <value>mapreduce_shuffle</value>
        </property>
        <property>
            <name>yarn.nodemanager.auxservices.mapreduce.shuffle.class</name>
            <value>org.apache.hadoop.mapred.ShuffleHandler</value>
        </property>
        <property>
            <name>yarn.resourcemanager.address</name>
            <value>192.168.31.130:8032</value>
        </property>
        <property>
            <name>yarn.resourcemanager.scheduler.address</name>
            <value>192.168.31.130:8030</value>
        </property>
        <property>
            <name>yarn.resourcemanager.resource-tracker.address</name>
            <value>192.168.31.130:8031</value>
        </property>
        <property>
            <name>yarn.resourcemanager.admin.address</name>
            <value>192.168.31.130:8033</value>
        </property>
        <property>
            <name>yarn.resourcemanager.webapp.address</name>
            <value>192.168.31.130:8088</value>
        </property>
        <property>
            <name>yarn.nodemanager.resource.memory-mb</name>
            <value>768</value>
        </property>
     </configuration>



    


## 2.3 使用Hadoop

    浏览器打开http://192.168.31.130:8088/
    浏览器打开http://192.168.31.130:50070/
    
    scp -r /home/hadoop 192.168.31.131:/home/
    scp -r /home/hadoop 192.168.31.132:/home/
    
    
    
    
    

12、在Master服务器启动hadoop，从节点会自动启动，进入/home/hadoop/hadoop-2.7.0目录
1.初始化，输入命令，bin/hdfs namenode -format
2.全部启动sbin/start-all.sh，也可以分开sbin/start-dfs.sh、sbin/start-yarn.sh
3.停止的话，输入命令，sbin/stop-all.sh
4.输入命令，jps，可以看到相关信息
    
# 3.安装hadoop

    ssh root@192.168.31.131 echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDO4kf+k3j0wwifKhC/lg2dTjXC8H3ktpn70srJAga5J5DUkKtcXvOpJRz8bsZEqKDZKLqSJ36ZRDCB5ZxOYJe0tJZBrmc7eLLLAinDvP1JjtB7MUDZP6wKntIIkj88aWiGJcqOdVv/o9yxIGzkZj8AFeORxyHu3Re0rYnzAO6OlSx+WZUfetYwub+GrsYwtSX3mvQW8oq2tumY8mSXJ4GKF8WWtypllYbRXDK4W1+N63z+yR0hqRz/G/v53uOEDEF37i9FMa4/Mtc2H83Y92OR3KegZMpi1ma9po98gid0Ey2VU+H/LGNIgN1eD17DGjZZ/0DkyWLQBnYzTjpc22Gl root@localhost.localdomain" >> /root/.ssh/authorized_keys
    

