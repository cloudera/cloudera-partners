#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

SOURCE=$1
BASENAME=$(basename $SOURCE)
SERVER_DIR=/files
POD=$(kubectl get pods -l app=demo-nginx -o name | sed 's#pod/##')
kubectl exec $POD -- mkdir -p $SERVER_DIR
if [[ -f $SOURCE ]]; then
  kubectl cp $SOURCE ${POD}:${SERVER_DIR}/${BASENAME}
elif [[ -d $SOURCE ]]; then
  DIRNAME=$(dirname $SOURCE)
  TARBALL=/tmp/upload.tar.$$.gz
  pushd $DIRNAME > /dev/null 2>&1
  trap "rm -f $TARBALL" 0
  tar -zcf $TARBALL $BASENAME
  kubectl cp $TARBALL ${POD}:${TARBALL}
  kubectl exec ${POD} -- bash -c "tar -C /files -zxf ${TARBALL}; rm -f ${TARBALL}" 2>&1 | grep -v "Ignoring unknown extended header keyword"
fi