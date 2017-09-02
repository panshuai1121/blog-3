## 安装

    docker-machine create \
    --driver virtualbox \
    --virtualbox-memory "2048"  \
    --engine-registry-mirror "http://184486c6.m.daocloud.io" \
    default

    eval $(docker-machine env default)
