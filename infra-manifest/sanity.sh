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
    sed -i "63,70s/^/#/" ansible/kafka.yml
    sed -i "141s/^/#/" ansible/server.properties.j2
    sed -i "41s/^/#/" deployment.tf
    sed -i "35,45s/^/#/" ansible/service-start.yml
fi

if [ $PROVECTUS == "false" ]
then
    sed -i "43s/^/#/" deployment.tf
fi

if [ $SCHEMA == 0 ]
then
    sed -i "39s/^/#/" deployment.tf
    sed -i "24,34s/^/#/" ansible/service-start.yml
fi

if [ $CONN -gt 0 ]
then
    REGION=$(cat dev.auto.tfvars | grep aws_region | awk '{print substr($3, 2, length($3)-2)}')
    S3NAME=$(cat dev.auto.tfvars | grep s3bucket_name | awk '{print substr($3, 2, length($3)-2)}')
    sed -i "s/bucket_region: \"\"/bucket_region: \"$REGION\"/g" ansible/connect.yml
    sed -i "s/bucket_name: \"\"/bucket_name: \"$S3NAME\"/g" ansible/connect.yml
else
    sed -i "46,56s/^/#/" ansible/service-start.yml
    sed -i "44s/^/#/" ansible/packages.yml
    sed -i "42s/^/#/" deployment.tf
    sed -i "14,16s/^/#/" ansible/provectus-app.yml.j2
fi

if [ $MM == 0 ]
then
    sed -i "43s/^/#/" ansible/packages.yml
    sed -i "40s/^/#/" deployment.tf
fi

if [ $GRAFANA == 0 ]
then
    sed -i "45s/^/#/" deployment.tf
fi

if [ $PROMETHEUS -gt 0 ]
then
    if [ $CONN -lt 0 ]
    then
        sed -i "34,36s/^/#/" ansible/prometheus-config.yml.j2
    fi

    if [ $MM -lt 0 ]
    then
        sed -i "37,39s/^/#/" ansible/prometheus-config.yml.j2
    fi
else
    sed -i "44s/^/#/" deployment.tf
fi