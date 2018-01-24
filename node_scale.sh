#!/bin/bash
#
# Spins up one Marathon app and creates one App monitor
# To stop the monitors and remove the marathon apps: node_scale.sh stop
#
#set -x

AS_URL="http://autoscaler.marathon.l4lb.thisdcos.directory"
MASTER_URL="http://leader.mesos"
NAMESPACE="myapp"
SU_USR=""
SU_PWD=""
TKN=$(curl --silent -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{"uid":"'${SU_USR}'","password":"'${SU_PWD}'"}' http://master.mesos/acs/api/v1/auth/login | jq ".token" | xargs)

function start(){
    curl -H "Content-type: application/json" -H "Authorization: token=${TKN}" -X DELETE ${MASTER_URL}/service/marathon/v2/apps/${NAMESPACE}/node | jq .
        echo
        sed "s/NAMESPACE/\/${NAMESPACE}/g" marathon/node.json > /tmp/node.json
        curl -H "Content-type: application/json" -H "Authorization: token=${TKN}" -X POST ${MASTER_URL}/service/marathon/v2/apps -d @/tmp/node.json | jq .
        echo

    echo "Creating application monitor Using CPU -OR- Memory limits to scale"
    #cpu or mem
    curl -X POST -d '{ "app_id": "/'${NAMESPACE}'/node","max_cpu": 6,"min_cpu": 3,"max_mem": 90,"min_mem": 5,"method": "or","scale_factor": 1,"max_instances": 6,"min_instances": 1,"warm_up": 3,"cool_down": 3,"interval": 30}' ${AS_URL}/apps | jq .
    echo

}

function stop(){
  curl --silent -X DELETE -d '{"app_id": "/'${NAMESPACE}'/node"}' ${AS_URL}/apps &> /dev/null
  #dcos marathon app remove /${NAMESPACE}/node &> /dev/null
  curl -H "Content-type: application/json" -H "Authorization: token=${TKN}" -X DELETE ${MASTER_URL}/service/marathon/v2/apps/${NAMESPACE}/node | jq .
  echo
}

# Main

if  [ "${1}" == "stop" ]; then
    stop
else
    if ! curl ${AS_URL}; then
        echo "Please start autoscaler first."
        exit 1
    fi
    start
fi

echo "Done"
