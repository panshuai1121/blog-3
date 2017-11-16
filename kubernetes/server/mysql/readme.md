docker run -p 3306:3307 -t -i -v /Users/k8s-data/mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=123456 mysql:5.6
