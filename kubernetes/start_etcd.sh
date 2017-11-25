#!/bin/bash

WORK_DIR=/code/kubernetes/server

# etcd
ETCD_NAME=default
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_CLIENT_URLS="http://localhost:2379"
ETCD_ADVERTISE_CLIENT_URLS="http://localhost:2379"
GOMAXPROCS=$(nproc) ${WORK_DIR}/etcd \
            --name=${ETCD_NAME} \
            --data-dir=${ETCD_DATA_DIR} \
            --listen-client-urls=${ETCD_LISTEN_CLIENT_URLS} \
            --advertise-client-urls=${ETCD_ADVERTISE_CLIENT_URLS} &

# flannel
FLANNEL_ETCD_ENDPOINTS="http://127.0.0.1:2379"
FLANNEL_ETCD_PREFIX="/atomic.io/network"
#FLANNEL_OPTIONS=""

etcdctl mkdir /atomic.io/network
etcdctl mk /atomic.io/network/config "{ \"Network\": \"172.30.0.0/16\", \"SubnetLen\": 24, \"Backend\": { \"Type\": \"vxlan\" } }"

${WORK_DIR}/flanneld \
        -etcd-endpoints=${FLANNEL_ETCD_ENDPOINTS:-${FLANNEL_ETCD}} \
        -etcd-prefix=${FLANNEL_ETCD_PREFIX:-${FLANNEL_ETCD_KEY}} \
        $FLANNEL_OPTIONS &


{WORK_DIR}/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/docker &
