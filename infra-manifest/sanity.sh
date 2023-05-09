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
    sed -i "45,52s/^/#/" ansible/kafka.yml
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

#########################################################################################################
#########                        ANSIBLE CONFIG TERRAFORM FILE                                  #########
#########################################################################################################

echo "resource \"local_file\" \"ansible_hosts\" {"                                                        > ansibleconf.tf
echo "  content  = <<EOT"                                                                                 >> ansibleconf.tf
echo "[kafka]"                                                                                            >> ansibleconf.tf
echo "%{ for i,ip in aws_instance.ec2broker.*.private_ip ~}"                                              >> ansibleconf.tf
echo "\${ip} id=\${i}"                                                                                    >> ansibleconf.tf
echo "%{ endfor ~}"                                                                                       >> ansibleconf.tf
echo " "                                                                                                  >> ansibleconf.tf
echo "[zoo]"                                                                                              >> ansibleconf.tf
echo "%{ for i,ip in aws_instance.ec2zoo.*.private_ip ~}"                                                 >> ansibleconf.tf
echo "\${ip} id=\${i+1}"                                                                                  >> ansibleconf.tf
echo "%{ endfor ~}"                                                                                       >> ansibleconf.tf
echo " "                                                                                                  >> ansibleconf.tf

if [ $MM -gt 0 ]
then
    echo "[mm]"                                                                                               >> ansibleconf.tf
    echo "%{ for ip in aws_instance.ec2mm.*.private_ip ~}"                                                    >> ansibleconf.tf
    echo "\${ip}"                                                                                             >> ansibleconf.tf
    echo "%{ endfor ~}"                                                                                       >> ansibleconf.tf
    echo " "                                                                                                  >> ansibleconf.tf
fi

if [ $CONN -gt 0 ]
then
    echo "[connect]"                                                                                          >> ansibleconf.tf
    echo "%{ for ip in aws_instance.ec2connect.*.private_ip ~}"                                               >> ansibleconf.tf
    echo "\${ip}"                                                                                             >> ansibleconf.tf
    echo "%{ endfor ~}"                                                                                       >> ansibleconf.tf
    echo " "                                                                                                  >> ansibleconf.tf
fi

if [ $SCHEMA -gt 0 ]
then
    echo "[schemareg]"                                                                                        >> ansibleconf.tf
    echo "%{ for ip in aws_instance.ec2schemareg.*.private_ip ~}"                                             >> ansibleconf.tf
    echo "\${ip}"                                                                                             >> ansibleconf.tf
    echo "%{ endfor ~}"                                                                                       >> ansibleconf.tf
    echo " "                                                                                                  >> ansibleconf.tf
fi

if [ $CRUISE == "true" ]
then
    echo "[cruise]"                                                                                           >> ansibleconf.tf
    echo "%{ for ip in aws_instance.ec2cruise.*.private_ip ~}"                                                >> ansibleconf.tf
    echo "\${ip}"                                                                                             >> ansibleconf.tf
    echo "%{ endfor ~}"                                                                                       >> ansibleconf.tf
    echo " "                                                                                                  >> ansibleconf.tf
fi

if [ $PROVECTUS == "true" ]
then
    echo "[provectus]"                                                                                           >> ansibleconf.tf
    echo "%{ for ip in aws_instance.ec2provectus.*.private_ip ~}"                                                >> ansibleconf.tf
    echo "\${ip}"                                                                                             >> ansibleconf.tf
    echo "%{ endfor ~}"                                                                                       >> ansibleconf.tf
    echo " "                                                                                                  >> ansibleconf.tf

fi

if [ $PROMETHEUS -gt 0 ]
then
    echo "[prometheus]"                                                                                           >> ansibleconf.tf
    echo "%{ for ip in aws_instance.ec2prometheus.*.private_ip ~}"                                                >> ansibleconf.tf
    echo "\${ip}"                                                                                             >> ansibleconf.tf
    echo "%{ endfor ~}"                                                                                       >> ansibleconf.tf
    echo " "                                                                                                  >> ansibleconf.tf

fi

if [ $GRAFANA -gt 0 ]
then
    echo "[grafana]"                                                                                           >> ansibleconf.tf
    echo "%{ for ip in aws_instance.ec2grafana.*.private_ip ~}"                                                >> ansibleconf.tf
    echo "\${ip}"                                                                                             >> ansibleconf.tf
    echo "%{ endfor ~}"                                                                                       >> ansibleconf.tf
    echo " "                                                                                                  >> ansibleconf.tf

fi

echo "  EOT"                                                                                              >> ansibleconf.tf
echo "  filename = \"./ansible/hosts\""                                                                   >> ansibleconf.tf
echo "}"                                                                                                  >> ansibleconf.tf
echo " "                                                                                                  >> ansibleconf.tf


if [ $MM -gt 0 ]
then
    echo "resource \"local_file\" \"mm_properties\" {"                                                        >> ansibleconf.tf
    echo "  content = <<EOT"                                                                                  >> ansibleconf.tf
    echo "# specify any number of cluster aliases"                                                            >> ansibleconf.tf
    echo "clusters = A, B"                                                                                    >> ansibleconf.tf
    echo "# connection information for each cluster"                                                          >> ansibleconf.tf
    echo "# This is a comma separated host:port pairs for each cluster"                                       >> ansibleconf.tf
    echo "# for e.g. \"A_host1:9092, A_host2:9092, A_host3:9092\""                                            >> ansibleconf.tf

    for((i=0;i<$KAFKA;i++))                                                     
    do
        if [ "$KAFKA" == "$((i+1))" ]
        then
            PUBLIC_KAFKA_IPS=$PUBLIC_KAFKA_IPS"\${ aws_instance.ec2broker[$i].public_ip }:9094"
        else
            PUBLIC_KAFKA_IPS=$PUBLIC_KAFKA_IPS"\${ aws_instance.ec2broker[$i].public_ip }:9094,"
        fi
    done

    echo "A.bootstrap.servers = $PUBLIC_KAFKA_IPS"                                                            >> ansibleconf.tf
    echo "B.bootstrap.servers = "                                                                             >> ansibleconf.tf
    echo "A->B.enabled = true"                                                                                >> ansibleconf.tf
    echo "A->B.topics = .*"                                                                                   >> ansibleconf.tf
    echo "A->B.groups = .*"                                                                                   >> ansibleconf.tf
    echo "#B->A.enabled = true"                                                                                >> ansibleconf.tf
    echo "#B->A.topics = .*"                                                                                   >> ansibleconf.tf
    echo "#B->A.groups = .*"                                                                                   >> ansibleconf.tf
    echo "# Setting replication factor of newly created remote topics"                                        >> ansibleconf.tf
    echo "replication.factor=2"                                                                               >> ansibleconf.tf
    echo "############################# Internal Topic Settings  #############################"               >> ansibleconf.tf
    echo "# The replication factor for mm2 internal topics \"heartbeats\", \"B.checkpoints.internal\" and"    >> ansibleconf.tf
    echo "# \"mm2-offset-syncs.B.internal\""                                                                  >> ansibleconf.tf
    echo "# For anything other than development testing, a value greater than 1 is recommended to ensure availability such as 3."   >> ansibleconf.tf
    echo "checkpoints.topic.replication.factor=1"                                                             >> ansibleconf.tf
    echo "heartbeats.topic.replication.factor=1"                                                              >> ansibleconf.tf
    echo "offset-syncs.topic.replication.factor=1"                                                            >> ansibleconf.tf
    echo "# The replication factor for connect internal topics \"mm2-configs.B.internal\", \"mm2-offsets.B.internal\" and"  >> ansibleconf.tf
    echo "# \"mm2-status.B.internal\""                                                                        >> ansibleconf.tf
    echo "# For anything other than development testing, a value greater than 1 is recommended to ensure availability such as 3."   >> ansibleconf.tf
    echo "offset.storage.replication.factor=1"                                                                >> ansibleconf.tf
    echo "status.storage.replication.factor=1"                                                                >> ansibleconf.tf
    echo "config.storage.replication.factor=1"                                                                >> ansibleconf.tf
    echo "# customize as needed"                                                                              >> ansibleconf.tf
    echo "# replication.policy.separator = _"                                                                 >> ansibleconf.tf
    echo "# sync.topic.acls.enabled = false"                                                                  >> ansibleconf.tf
    echo "emit.checkpoints.interval.seconds = 5"                                                              >> ansibleconf.tf
    echo "emit.heartbeats.enabled = true"                                                                     >> ansibleconf.tf
    echo "emit.heartbeats.interval.seconds = 5"                                                               >> ansibleconf.tf
    echo "  EOT"                                                                                              >> ansibleconf.tf
    echo "  filename = \"./ansible/connect-mirror-maker.properties\""                                         >> ansibleconf.tf
    echo "  depends_on = ["                                                                                   >> ansibleconf.tf
    echo "    aws_instance.ec2broker, aws_instance.ec2mm"                                                     >> ansibleconf.tf
    echo "  ]"                                                                                                >> ansibleconf.tf
    echo "}"                                                                                                  >> ansibleconf.tf    
fi

#########################################################################################################
#########                        CAPACITYJBOD JSON FILE                                         #########
#########################################################################################################

echo "{"                                                                                    > ansible/capacityJBOD.json
echo "  \"brokerCapacities\":["                                                             >> ansible/capacityJBOD.json
echo "    {"                                                                                >> ansible/capacityJBOD.json
echo "      \"brokerId\": \"-1\","                                                          >> ansible/capacityJBOD.json
echo "      \"capacity\": {"                                                                >> ansible/capacityJBOD.json
echo "        \"DISK\": {\"/opt/kafkadata/kafka-logs\": \"${DISK}000\"},"                        >> ansible/capacityJBOD.json
echo "        \"CPU\": \"2\","                                                              >> ansible/capacityJBOD.json
echo "        \"NW_IN\": \"5000\","                                                         >> ansible/capacityJBOD.json
echo "        \"NW_OUT\": \"5000\""                                                         >> ansible/capacityJBOD.json
echo "      },"                                                                             >> ansible/capacityJBOD.json
echo "      \"doc\": \"The default capacity for a broker with multiple logDirs each on a separate heterogeneous disk.\""    >> ansible/capacityJBOD.json
echo "    }"                                                                                >> ansible/capacityJBOD.json
echo "  ]"                                                                                  >> ansible/capacityJBOD.json
echo "}"                                                                                    >> ansible/capacityJBOD.json
