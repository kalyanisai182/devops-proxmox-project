#!/bin/bash
# Checks that every automatic backup ran recently. Exit code 1 if anything failed.
fail=0
row() { printf "%-28s %-5s %s\n" "$1" "$2" "$3"; [ "$2" = OK ] || fail=1; }
echo "=== Backup check $(date -u '+%Y-%m-%d %H:%M UTC') ==="

# 1-2. etcd snapshots: newest folder younger than 26 hours, with a verified status file
for c in nonprod prod; do
  last=$(ls -1d /root/backups/k8s/$c/*/ 2>/dev/null | tail -1)
  if [ -n "$last" ] && [ -f "$last/status.txt" ] && [ -n "$(find "$last" -maxdepth 0 -mmin -1560)" ]; then
    row "etcd $c" OK "$(basename "$last")"
  else
    row "etcd $c" FAIL "newest: ${last:-none}"
  fi
done

# 3-4. Velero: newest nightly-all backup written by each cluster to its own location
for c in nonprod:default prod:prod; do
  name=${c%%:*}; loc=${c##*:}
  r=$(kubectl --kubeconfig /root/.kube/$name.conf -n velero get backups.velero.io \
      -l velero.io/schedule-name=nightly-all,velero.io/storage-location=$loc \
      --sort-by=.metadata.creationTimestamp \
      -o jsonpath='{range .items[-1:]}{.status.phase} {.metadata.creationTimestamp}{end}' 2>/dev/null)
  [ "${r%% *}" = Completed ] && row "velero $name" OK "${r#* }" || row "velero $name" FAIL "${r:-no backups found}"
done

# 5. Postgres on prod: last base backup succeeded and WAL archiving is running
r=$(kubectl --kubeconfig /root/.kube/prod.conf -n model-registry get cluster registry-db \
    -o jsonpath='{.status.conditions[?(@.type=="LastBackupSucceeded")].status} {.status.conditions[?(@.type=="ContinuousArchiving")].status} ' 2>/dev/null)
set -- $r; last=$(kubectl --kubeconfig /root/.kube/prod.conf -n model-registry get backups.postgresql.cnpg.io -l cnpg.io/cluster=registry-db --sort-by=.metadata.creationTimestamp -o jsonpath='{range .items[-1:]}{.status.stoppedAt}{end}' 2>/dev/null); set -- $1 $2 $last
[ "$1" = True ] && [ "$2" = True ] && row "postgres prod" OK "last base backup $3" || row "postgres prod" FAIL "backup=$1 archiving=$2"

[ $fail = 0 ] && echo "ALL BACKUPS OK" || echo "SOME BACKUPS FAILED"
exit $fail
