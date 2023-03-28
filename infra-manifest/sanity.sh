#!/bin/bash

# This script makes changes to files
# kafka.yml, zoo.yml, zookeeper.properties.j2, deployment.tf, ansibleconf.tf, cruisecontrol.yml, packages.yml,
# schema-registry.yml, service-start.yml, capacityJBOD.json
#
# Also it changes the file extensions for kafka components terraform files
# ec2_connect.tf, ec2_mm.tf, ec2_cruise.tf, ec2_schema.tf

ZOO=$(cat dev.auto.tfvars | grep zoo_count | awk '{print substr($3, 1, length($3)-1)}')
KAFKA=$(cat dev.auto.tfvars | grep kafka_count | awk '{print substr($3, 1, length($3)-1)}')
MM=$(cat dev.auto.tfvars | grep mm_count | awk '{print substr($3, 1, length($3)-1)}')
CONN=$(cat dev.auto.tfvars | grep connect_count | awk '{print substr($3, 1, length($3)-1)}')
SCHEMA=$(cat dev.auto.tfvars | grep schema_count | awk '{print substr($3, 1, length($3)-1)}')
CRUISE=$(cat dev.auto.tfvars | grep cruise_deploy | awk '{print substr($3, 2, length($3)-3)}')
PROVECTUS=$(cat dev.auto.tfvars | grep provectus_deploy | awk '{print substr($3, 2, length($3)-3)}')

DISK=$(cat dev.auto.tfvars | grep disk | head -n 1 | awk -F= '{print substr($2,1,length($2)-1)}')

echo zoo=$ZOO kafka=$KAFKA mm=$MM connect=$CONN schema=$SCHEMA cruise=$CRUISE provectus-kafka-ui=$PROVECTUS

ZOO_IPS=""
KAFKA_IPS=""
CONN_IPS=""
PUBLIC_KAFKA_IPS=""

for((i=0;i<$ZOO;i++))
do
    if [ "$ZOO" == "$((i+1))" ]
    then
        ZOO_IPS=$ZOO_IPS"{{hostvars[groups['zoo'][$i]]['inventory_hostname']}}:2181"
    else
        ZOO_IPS=$ZOO_IPS"{{hostvars[groups['zoo'][$i]]['inventory_hostname']}}:2181,"
    fi
done

for((i=0;i<$KAFKA;i++))
do
    if [ "$KAFKA" == "$((i+1))" ]
    then
        KAFKA_IPS=$KAFKA_IPS"{{hostvars[groups['kafka'][$i]]['inventory_hostname']}}:9092"
    else
        KAFKA_IPS=$KAFKA_IPS"{{hostvars[groups['kafka'][$i]]['inventory_hostname']}}:9092,"
    fi
done

if [ $CRUISE == "false" ]
then
    sed -i "9s/^/#/" ansible/packages.yml
    sed -i "38,45s/^/#/" ansible/kafka.yml
    sed -i "141s/^/#/" ansible/server.properties.j2
    sed -i "41s/^/#/" deployment.tf
    sed -i "35,45s/^/#/" ansible/service-start.yml
else
    sed -i "s/zoo_ips: \"\"/zoo_ips: \"$ZOO_IPS\"/g" ansible/cruisecontrol.yml
    sed -i "s/kafka_ips: \"\"/kafka_ips: \"$KAFKA_IPS\"/g" ansible/cruisecontrol.yml
fi

if [ $PROVECTUS == "false" ]
then
    sed -i "43s/^/#/" deployment.tf
else
    if [ $CONN -gt 0 ]
    then
        for((i=0;i<$CONN;i++))
        do
            if [ "$CONN" == "$((i+1))" ]
            then
                CONN_IPS=$CONN_IPS"http:\/\/{{hostvars[groups['connect'][$i]]['inventory_hostname']}}:8083"
            else
                CONN_IPS=$CONN_IPS"http:\/\/{{hostvars[groups['connect'][$i]]['inventory_hostname']}}:8083,"
            fi
        done

        sed -i "s/connect_ips: \"\"/connect_ips: \"$CONN_IPS\"/g" ansible/provectus.yml
    fi
    sed -i "s/zoo_ips: \"\"/zoo_ips: \"$ZOO_IPS\"/g" ansible/provectus.yml
    sed -i "s/kafka_ips: \"\"/kafka_ips: \"$KAFKA_IPS\"/g" ansible/provectus.yml
fi

if [ $SCHEMA -gt 0 ]
then
    sed -i "s/kafka_ips: \"\"/kafka_ips: \"$KAFKA_IPS\"/g" ansible/schema-registry.yml
else
    sed -i "8s/^/#/" ansible/packages.yml
    sed -i "39s/^/#/" deployment.tf
    sed -i "24,34s/^/#/" ansible/service-start.yml
fi

if [ $CONN -gt 0 ]
then
    REGION=$(cat dev.auto.tfvars | grep aws_region | awk '{print substr($3, 2, length($3)-2)}')
    S3NAME=$(cat dev.auto.tfvars | grep s3bucket_name | awk '{print substr($3, 2, length($3)-2)}')
    sed -i "s/kafka_ips: \"\"/kafka_ips: \"$KAFKA_IPS\"/g" ansible/connect.yml
    sed -i "s/bucket_region: \"\"/bucket_region: \"$REGION\"/g" ansible/connect.yml
    sed -i "s/bucket_name: \"\"/bucket_name: \"$S3NAME\"/g" ansible/connect.yml
else
    sed -i "46,56s/^/#/" ansible/service-start.yml
    sed -i "58s/^/#/" ansible/packages.yml
    sed -i "7s/^/#/" ansible/packages.yml
    sed -i "42s/^/#/" deployment.tf
    sed -i "14,16s/^/#/" ansible/provectus-app.yml.j2
fi

if [ $MM == 0 ]
then
    sed -i "57s/^/#/" ansible/packages.yml
    sed -i "6s/^/#/" ansible/packages.yml
    sed -i "40s/^/#/" deployment.tf
fi

sed -i "s/zoo_ips: \"\"/zoo_ips: \"$ZOO_IPS\"/g" ansible/kafka.yml

#########################################################################################################
#########                      ZOOKEEPER PROPERTIES FILE                                     ############
#########################################################################################################


echo "# Licensed to the Apache Software Foundation (ASF) under one or more"                             > ansible/zookeeper.properties.j2
echo "# contributor license agreements.  See the NOTICE file distributed with"                          >> ansible/zookeeper.properties.j2
echo "# this work for additional information regarding copyright ownership."                            >> ansible/zookeeper.properties.j2
echo "# The ASF licenses this file to You under the Apache License, Version 2.0"                        >> ansible/zookeeper.properties.j2
echo "# (the "License"); you may not use this file except in compliance with"                           >> ansible/zookeeper.properties.j2
echo "# the License.  You may obtain a copy of the License at"                                          >> ansible/zookeeper.properties.j2
echo "#"                                                                                                >> ansible/zookeeper.properties.j2  
echo "#    http://www.apache.org/licenses/LICENSE-2.0"                                                  >> ansible/zookeeper.properties.j2
echo "#"                                                                                                >> ansible/zookeeper.properties.j2
echo "# Unless required by applicable law or agreed to in writing, software"                            >> ansible/zookeeper.properties.j2
echo "# distributed under the License is distributed on an "AS IS" BASIS,"                              >> ansible/zookeeper.properties.j2
echo "# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied."                       >> ansible/zookeeper.properties.j2
echo "# See the License for the specific language governing permissions and"                            >> ansible/zookeeper.properties.j2
echo "# limitations under the License."                                                                 >> ansible/zookeeper.properties.j2
echo "# the directory where the snapshot is stored."                                                    >> ansible/zookeeper.properties.j2
echo "dataDir={{ data_dir }}"                                                                           >> ansible/zookeeper.properties.j2
echo "# the port at which the clients will connect"                                                     >> ansible/zookeeper.properties.j2
echo "clientPort=2181"                                                                                  >> ansible/zookeeper.properties.j2
echo "# disable the per-ip limit on the number of connections since this is a non-production config"    >> ansible/zookeeper.properties.j2
echo "maxClientCnxns=60"                                                                                >> ansible/zookeeper.properties.j2
echo "# Disable the adminserver by default to avoid port conflicts."                                    >> ansible/zookeeper.properties.j2
echo "# Set the port to something non-conflicting if choosing to enable this"                           >> ansible/zookeeper.properties.j2
echo "admin.enableServer=false"                                                                         >> ansible/zookeeper.properties.j2
echo "# admin.serverPort=8080"                                                                          >> ansible/zookeeper.properties.j2
echo "4lw.commands.whitelist=*"                                                                         >> ansible/zookeeper.properties.j2
echo "tickTime=2000"                                                                                    >> ansible/zookeeper.properties.j2
echo "initLimit=5"                                                                                      >> ansible/zookeeper.properties.j2
echo "syncLimit=2"                                                                                      >> ansible/zookeeper.properties.j2

for (( i=0; i<$ZOO; i++ ))
do
  var_value="server.$((i+1))={{ zookeeper$((i+1))_ip }}:2888:3888"
  echo "$var_value"                                                                                     >> ansible/zookeeper.properties.j2
done


#########################################################################################################
#########                      ZOOKEEPER YAML FILE                                           ############
#########################################################################################################

echo "---"                                                                              > ansible/zoo.yml
echo "- name: Zookeeper configuration"                                                  >> ansible/zoo.yml
echo "  hosts: zoo"                                                                     >> ansible/zoo.yml
echo "  remote_user: ubuntu"                                                            >> ansible/zoo.yml
echo "  vars:"                                                                          >> ansible/zoo.yml
echo "    data_dir: /opt/zookeeperdata/"                                                >> ansible/zoo.yml
for (( i=0; i<$ZOO; i++ ))
do
  var_name="zookeeper$((i+1))_ip"
  var_value="\"{{ hostvars[groups['zoo'][$i]]['inventory_hostname'] }}\""
  echo "    $var_name:  $var_value"                                                     >> ansible/zoo.yml
done
echo "  tasks:"                                                                         >> ansible/zoo.yml
echo "  - name: Create data directory"                                                  >> ansible/zoo.yml
echo "    become: true"                                                                 >> ansible/zoo.yml
echo "    file:"                                                                        >> ansible/zoo.yml
echo "      path: \"{{ data_dir }}\""                                                   >> ansible/zoo.yml
echo "      state: directory"                                                           >> ansible/zoo.yml
echo "      mode: '0755'"                                                               >> ansible/zoo.yml
echo "  - name: Create sys log directory"                                               >> ansible/zoo.yml
echo "    become: true"                                                                 >> ansible/zoo.yml
echo "    file:"                                                                        >> ansible/zoo.yml
echo "      path: \"{{ data_dir }}/systemlogs\""                                        >> ansible/zoo.yml
echo "      state: directory"                                                           >> ansible/zoo.yml
echo "      mode: '0755'"                                                               >> ansible/zoo.yml
echo "  - name: Remove existing zookeeper properties file"                              >> ansible/zoo.yml
echo "    become: true"                                                                 >> ansible/zoo.yml
echo "    file:"                                                                        >> ansible/zoo.yml
echo "      path: /opt/kafka/config/zookeeper.properties"                               >> ansible/zoo.yml
echo "      state: absent"                                                              >> ansible/zoo.yml
echo "  - name: Generate zookeeper.properties from template"                            >> ansible/zoo.yml
echo "    become: true"                                                                 >> ansible/zoo.yml
echo "    template:"                                                                    >> ansible/zoo.yml
echo "      src: /opt/ansible-files/zookeeper.properties.j2"                            >> ansible/zoo.yml
echo "      dest: /opt/kafka/config/zookeeper.properties"                               >> ansible/zoo.yml
echo "  - name: Upload local zookeeper service file to the servers"                     >> ansible/zoo.yml
echo "    become: true"                                                                 >> ansible/zoo.yml
echo "    copy:"                                                                        >> ansible/zoo.yml
echo "      src: /opt/ansible-files/zookeeper.service"                                  >> ansible/zoo.yml
echo "      dest: /etc/systemd/system/"                                                 >> ansible/zoo.yml
echo "      owner: root"                                                                >> ansible/zoo.yml
echo "      group: root"                                                                >> ansible/zoo.yml
echo "      mode: 0644"                                                                 >> ansible/zoo.yml
echo "  - name: Download JMX exporter zookeeper metrics yml file"                       >> ansible/zoo.yml
echo "    become: true"                                                                 >> ansible/zoo.yml
echo "    get_url:"                                                                     >> ansible/zoo.yml
echo "      url: https://raw.githubusercontent.com/prometheus/jmx_exporter/main/example_configs/zookeeper.yaml" >> ansible/zoo.yml
echo "      dest: /opt/monitoring/zookeeper.yaml"                                       >> ansible/zoo.yml
echo "      mode: 0440"                                                                 >> ansible/zoo.yml
echo "  - name: just force systemd to reread configs"                                   >> ansible/zoo.yml
echo "    become: true"                                                                 >> ansible/zoo.yml
echo "    systemd:"                                                                     >> ansible/zoo.yml
echo "      daemon_reload: yes"                                                         >> ansible/zoo.yml
echo "  - name: Write myid to myid file"                                                >> ansible/zoo.yml
echo "    become: true"                                                                 >> ansible/zoo.yml
echo "    shell: \"hostname | rev | cut -c1 > {{ data_dir }}myid\""                     >> ansible/zoo.yml
echo "  - name: Enable zookeeper service"                                               >> ansible/zoo.yml
echo "    become: true"                                                                 >> ansible/zoo.yml
echo "    systemd:"                                                                     >> ansible/zoo.yml
echo "      name: zookeeper.service"                                                    >> ansible/zoo.yml
echo "      enabled: true"                                                              >> ansible/zoo.yml
echo "      masked: no"                                                                 >> ansible/zoo.yml
echo "  # - name: Start zookeeper service"                                              >> ansible/zoo.yml
echo "  #   become: true"                                                               >> ansible/zoo.yml
echo "  #   systemd:"                                                                   >> ansible/zoo.yml
echo "  #     name: zookeeper.service"                                                  >> ansible/zoo.yml
echo "  #     state: started"                                                           >> ansible/zoo.yml
echo "  #     enabled: true"                                                            >> ansible/zoo.yml

#########################################################################################################
#########                        ANSIBLE CONFIG TERRAFORM FILE                                  #########
#########################################################################################################

echo "resource \"local_file\" \"ansible_hosts\" {"                                                        > ansibleconf.tf
echo "  content  = <<EOT"                                                                                 >> ansibleconf.tf
echo "[kafka]"                                                                                            >> ansibleconf.tf
echo "%{ for ip in aws_instance.ec2broker.*.private_ip ~}"                                                >> ansibleconf.tf
echo "\${ip}"                                                                                             >> ansibleconf.tf
echo "%{ endfor ~}"                                                                                       >> ansibleconf.tf
echo " "                                                                                                  >> ansibleconf.tf
echo "[zoo]"                                                                                              >> ansibleconf.tf
echo "%{ for ip in aws_instance.ec2zoo.*.private_ip ~}"                                                   >> ansibleconf.tf
echo "\${ip}"                                                                                             >> ansibleconf.tf
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
fi

if [ $PROVECTUS == "true" ]
then
    echo "[provectus]"                                                                                           >> ansibleconf.tf
    echo "%{ for ip in aws_instance.ec2provectus.*.private_ip ~}"                                                >> ansibleconf.tf
    echo "\${ip}"                                                                                             >> ansibleconf.tf
    echo "%{ endfor ~}"                                                                                       >> ansibleconf.tf
fi

echo "  EOT"                                                                                              >> ansibleconf.tf
echo "  filename = \"./ansible/hosts\""                                                                   >> ansibleconf.tf
echo "}"                                                                                                  >> ansibleconf.tf

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
    echo "B->A.enabled = true"                                                                                >> ansibleconf.tf
    echo "B->A.topics = .*"                                                                                   >> ansibleconf.tf
    echo "B->A.groups = .*"                                                                                   >> ansibleconf.tf
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
