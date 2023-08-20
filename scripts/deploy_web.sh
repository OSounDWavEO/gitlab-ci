#!/bin/bash

set -e

sts_file=$1
full_image=$2
kube_command=$(which kubectl)

function updateVersion(){
    current_tag=$1
    expected_tag=$2
    sts_file=$3
    sed -i -E 's#'"$current_tag"'#'"$expected_tag"'#g' $sts_file
    $kube_command apply -f $sts_file
}

function getVersion(){
    sts_name=$1
    namespace=$2
    image_name=$3
    $kube_command describe sts ${sts_name} -n ${namespace} | grep "${image_name}:" | awk "-F:" '{print $3}'| tr -d '[:space:]'
}

function getStatus(){
    sts_name=$1
    namespace=$2
    $kube_command get sts $sts_name -n $namespace | awk '{print $2}' | awk 'FNR==2{print $0}' | sed 's|\(.*\)/.*|\1|'
}

echo "deploying image: $full_image"

IFS=: read -r image_name image_tag <<< "$full_image"

current_tag=$(cat $sts_file | grep "${image_name}:" | awk "-F:" '{print $3}'| tr -d '[:space:]')
echo "current_tag=$current_tag"

namespace=$(cat $sts_file | grep "namespace:" | awk "-F:" '{print $2}'| tr -d '[:space:]')
echo "namespace=$namespace"

sts_name=$(cat $sts_file | grep "serviceName:" | awk "-F:" '{print $2}'| tr -d '[:space:]')
echo "sts_name=$sts_name"

updateVersion $current_tag $image_tag $sts_file

echo "follow update task..."
retry=0
get_version=$(getVersion $sts_name $namespace $image_name)

while [ "$get_version" != "$image_tag" ]
do
    get_version=$(getVersion $sts_name $namespace $image_name)
    sleep 5
    ((retry=retry+1));
    if [[ $retry == 12 ]]; then
        echo "timeout. rollback to version: ${current_tag}"

        $kube_command describe po ${sts_name}-0 -n ${namespace}
        updateVersion $image_tag $current_tag $sts_file
        exit 1
    fi
done

echo "check service status..."
pod_ready=$(getStatus $sts_name $namespace)
retry=0
      
while [ "$pod_ready" == "0" ]
do
    pod_ready=$(getStatus $sts_name $namespace)
    sleep 5
    ((retry=retry+1))
    if [[ $retry == 12 ]]; then
        echo "timeout. rollback to version: ${current_tag}"

        $kube_command describe po ${sts_name}-0 -n ${namespace}
        updateVersion $image_tag $current_tag $sts_file
        exit 1
    fi
done

echo "deployment success"
