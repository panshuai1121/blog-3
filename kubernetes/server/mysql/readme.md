docker build -t d1studio/mysql:5.6 . 



mysqldump -uroot -p123456 -h192.168.99.100 -P 30306 sec > /Users/k8s-data/backup/mysql/sec_`date +%F`.sql
mysqldump -uroot -p123456 -h192.168.99.100 -P 30306 bos_plug > /Users/k8s-data/backup/mysql/bos_plug_`date +%F`.sql