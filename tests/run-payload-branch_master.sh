THIS_SCRIPT=$(basename -- "$0")
echo Running $THIS_SCRIPT
WORKDIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

EL_HOSTNAME=$(oc get route -l app=fuse-app-01 | awk 'FNR == 2 {print $2}')

echo ">> HOSTNAME=$EL_HOSTNAME"
curl -k -d @$WORKDIR/request-payload-branch_master.json http://$EL_HOSTNAME
