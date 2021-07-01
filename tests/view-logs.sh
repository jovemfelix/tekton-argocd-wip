oc logs -f $(oc get pods -l app=fuse-app-01 --field-selector status.phase==Running | awk 'FNR > 1  {print $1}' )
