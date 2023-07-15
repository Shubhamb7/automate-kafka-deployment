#!/bin/bash

# This script makes changes to files
# kafka.yml, zoo.yml, zookeeper.properties.j2, deployment.tf, ansibleconf.tf, cruisecontrol.yml, packages.yml,
# schema-registry.yml, service-start.yml, capacityJBOD.json, prometheus.yml, prometheus-config.yml.j2,
# provectus.yml, provectus-app.yml.j2

ZOO=$(cat dev.auto.tfvars | grep zoo_count | awk '{print substr($3, 1, length($3)-1)}')
KAFKA=$(cat dev.auto.tfvars | grep kafka_count | awk '{print substr($3, 1, length($3)-1)}')
MM=$(cat dev.auto.tfvars | grep mm_count | awk '{print substr($3, 1, length($3)-1)}')
CONN=$(cat dev.auto.tfvars | grep connect_count | awk '{print substr($3, 1, length($3)-1)}')
SCHEMA=$(cat dev.auto.tfvars | grep schema_count | awk '{print substr($3, 1, length($3)-1)}')
CRUISE=$(cat dev.auto.tfvars | grep cruise_deploy | awk '{print substr($3, 2, length($3)-3)}')
PROVECTUS=$(cat dev.auto.tfvars | grep provectus_deploy | awk '{print substr($3, 2, length($3)-3)}')
PROMETHEUS=$(cat dev.auto.tfvars | grep prom_count | awk '{print substr($3, 1, length($3)-1)}')
GRAFANA=$(cat dev.auto.tfvars | grep grafana_count | awk '{print substr($3, 1, length($3)-1)}')

DISK=$(cat dev.auto.tfvars | grep disk | head -n 1 | awk -F= '{print substr($2,1,length($2)-1)}')

sed -i "s/bucket_region:.*/bucket_region: \"\"/g" ansible/roles/kafkaconnect/vars/main.yml
sed -i "s/bucket_name:.*/bucket_name: \"\"/g" ansible/roles/kafkaconnect/vars/main.yml
sed -i "45,52s/^#//" ansible/roles/kafkabroker/tasks/main.yml
sed -i "141s/^#//" ansible/roles/kafkabroker/templates/server.properties.j2
sed -i "14,16s/^#//" ansible/roles/provectus/templates/provectus-app.yml.j2
sed -i "34,39s/^#//" ansible/roles/prometheus/templates/prometheus-config.yml.j2

if [ $PROMETHEUS -gt 0 ]
then
    GRAFANA=1
else
    GRAFANA=0
fi

echo zoo=$ZOO kafka=$KAFKA mm=$MM connect=$CONN schema=$SCHEMA 
echo prometheus=$PROMETHEUS grafana=$GRAFANA cruise=$CRUISE provectus-kafka-ui=$PROVECTUS

if [ $CRUISE == "false" ]
then
    sed -i "45,52s/^/#/" ansible/roles/kafkabroker/tasks/main.yml
    sed -i "141s/^/#/" ansible/roles/kafkabroker/templates/server.properties.j2
fi

if [ $CONN -gt 0 ]
then
    REGION=$(cat dev.auto.tfvars | grep aws_region | awk '{print substr($3, 2, length($3)-2)}')
    S3NAME=$(cat dev.auto.tfvars | grep s3bucket_name | awk '{print substr($3, 2, length($3)-2)}')
    sed -i "s/bucket_region: \"\"/bucket_region: \"$REGION\"/g" ansible/roles/kafkaconnect/vars/main.yml
    sed -i "s/bucket_name: \"\"/bucket_name: \"$S3NAME\"/g" ansible/roles/kafkaconnect/vars/main.yml
else
    sed -i "14,16s/^/#/" ansible/roles/provectus/templates/provectus-app.yml.j2
fi

if [ $PROMETHEUS -gt 0 ]
then
    if [ $CONN -lt 0 ]
    then
        sed -i "34,36s/^/#/" ansible/roles/prometheus/templates/prometheus-config.yml.j2
    fi

    if [ $MM -lt 0 ]
    then
        sed -i "37,39s/^/#/" ansible/roles/prometheus/templates/prometheus-config.yml.j2
    fi
fi