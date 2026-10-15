#!/bin/bash
# usage: etcd-backup.sh nonprod|prod
set -euo pipefail
case "${1:-}" in
  nonprod) KC=/root/.kube/nonprod.conf; MASTER=10.30.5.57; NODE=nonprod-master ;;
  prod)    KC=/root/.kube/prod.conf;    MASTER=10.30.5.60; NODE=prod-master ;;
  *) echo "usage: $0 nonprod|prod"; exit 1 ;;
esac
B=/root/backups/k8s/$1/$(date -u +%Y%m%d-%H%M); mkdir -p $B; chmod 700 $B
echo "=== $(date -u) etcd backup of $1 -> $B ==="
CERTS="--endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key"
kubectl --kubeconfig $KC -n kube-system exec etcd-$NODE -- etcdctl $CERTS snapshot save /var/lib/etcd/snapshot.db
ssh ubuntu@$MASTER "sudo cat /var/lib/etcd/snapshot.db" > $B/snapshot.db
ssh ubuntu@$MASTER "sudo tar czf - -C /etc/kubernetes pki admin.conf" > $B/pki.tgz
chmod 600 $B/*
etcdutl snapshot status $B/snapshot.db -w table | tee $B/status.txt
source /root/seaweedfs/creds.env
docker run --rm --network host -v $B:$B -e AWS_ACCESS_KEY_ID=$ADMIN_KEY -e AWS_SECRET_ACCESS_KEY=$ADMIN_SECRET \
  -e AWS_DEFAULT_REGION=us-east-1 amazon/aws-cli --endpoint-url http://127.0.0.1:8333 \
  s3 cp --recursive --only-show-errors $B s3://k8s-etcd/$1/$(basename $B)/
find /root/backups/k8s/$1 -mindepth 1 -maxdepth 1 -type d -mtime +7 -exec rm -rf {} +
echo "=== $(date -u) etcd backup of $1 OK ==="
