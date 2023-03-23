#!/bin/bash

# This script makes changes to files
# packages.yml, kafka.yml, zoo.yml, zookeeper.properties.j2, deployment.tf, ansibleconf.tf, 
# cruisecontrol.yml, schema-registry.yml, service-start.yml, capacityJBOD.json
#
# Also it changes the file extensions for kafka components terraform files
# ec2_connect.tf, ec2_mm.tf, ec2_cruise.tf, ec2_schema.tf

ZOO=$(cat dev.auto.tfvars | grep zoo_count | awk '{print substr($3, 1, length($3)-1)}')
KAFKA=$(cat dev.auto.tfvars | grep kafka_count | awk '{print substr($3, 1, length($3)-1)}')
MM=$(cat dev.auto.tfvars | grep mm_count | awk '{print substr($3, 1, length($3)-1)}')
CONN=$(cat dev.auto.tfvars | grep connect_count | awk '{print substr($3, 1, length($3)-1)}')
SCHEMA=$(cat dev.auto.tfvars | grep schema_count | awk '{print substr($3, 1, length($3)-1)}')
CRUISE=$(cat dev.auto.tfvars | grep cruise_count | awk '{print substr($3, 1, length($3)-1)}')

DISK=$(cat dev.auto.tfvars | grep disk | head -n 1 | awk -F= '{print substr($2,1,length($2)-1)}')

echo zoo=$ZOO kafka=$KAFKA mm=$MM connect=$CONN schema=$SCHEMA cruise=$CRUISE

ZOO_IPS=""
KAFKA_IPS=""
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

sed -i "s/kafka_ips: \"\"/kafka_ips: \"$KAFKA_IPS\"/g" ansible/cruisecontrol.yml
sed -i "s/kafka_ips: \"\"/kafka_ips: \"$KAFKA_IPS\"/g" ansible/schema-registry.yml
sed -i "s/zoo_ips: \"\"/zoo_ips: \"$ZOO_IPS\"/g" ansible/cruisecontrol.yml
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
#########                       PACKAGES YAML FILE                                           ############
#########################################################################################################


echo "---"                                                                                  > ansible/packages.yml
echo "- name: Packages required"                                                            >> ansible/packages.yml
echo "  hosts: all"                                                                         >> ansible/packages.yml
echo "  remote_user: ubuntu"                                                                >> ansible/packages.yml
echo "  tasks:"                                                                             >> ansible/packages.yml
echo "    - name: Update apt repo and cache"                                                >> ansible/packages.yml
echo "      become: true"                                                                   >> ansible/packages.yml
echo "      apt:"                                                                           >> ansible/packages.yml
echo "        update_cache: yes"                                                            >> ansible/packages.yml
echo "        force_apt_get: yes"                                                           >> ansible/packages.yml
echo "        cache_valid_time: 3600"                                                       >> ansible/packages.yml
echo "    - name: Upgrade all packages"                                                     >> ansible/packages.yml
echo "      become: true"                                                                   >> ansible/packages.yml
echo "      apt:"                                                                           >> ansible/packages.yml
echo "        upgrade: dist"                                                                >> ansible/packages.yml
echo "        force_apt_get: yes"                                                           >> ansible/packages.yml
echo "    - name: Install openjdk 11"                                                       >> ansible/packages.yml
echo "      become: true"                                                                   >> ansible/packages.yml
echo "      apt:"                                                                           >> ansible/packages.yml
echo "        name: openjdk-11-jdk"                                                         >> ansible/packages.yml
echo "        state: present"                                                               >> ansible/packages.yml
echo "        update_cache: yes"                                                            >> ansible/packages.yml
echo "    - name: Download Kafka"                                                           >> ansible/packages.yml
echo "      become: true"                                                                   >> ansible/packages.yml
echo "      get_url:"                                                                       >> ansible/packages.yml
if [ $CRUISE == 0 ]
then
    echo "        url: https://archive.apache.org/dist/kafka/3.3.1/kafka_2.13-3.3.1.tgz"    >> ansible/packages.yml
    echo "        dest: /opt/kafka_2.13-3.3.1.tgz"                                          >> ansible/packages.yml
    echo "        mode: 0440"                                                               >> ansible/packages.yml
    echo "    - name: Extract kafka_2.13-3.3.1.tgz"                                         >> ansible/packages.yml
    echo "      become: true"                                                               >> ansible/packages.yml
    echo "      unarchive:"                                                                 >> ansible/packages.yml
    echo "        src: /opt/kafka_2.13-3.3.1.tgz"                                           >> ansible/packages.yml
    echo "        dest: /opt/"                                                              >> ansible/packages.yml
    echo "        remote_src: yes"                                                          >> ansible/packages.yml
    echo "    - name: Rename kafka folder"                                                  >> ansible/packages.yml
    echo "      become: true"                                                               >> ansible/packages.yml
    echo "      command: \"mv /opt/kafka_2.13-3.3.1 /opt/kafka\""                           >> ansible/packages.yml
    echo "    - name: Remove kafka tar"                                                     >> ansible/packages.yml
    echo "      become: true"                                                               >> ansible/packages.yml
    echo "      file:"                                                                      >> ansible/packages.yml
    echo "        path: /opt/kafka_2.13-3.3.1.tgz"                                          >> ansible/packages.yml
    echo "        state: absent"                                                            >> ansible/packages.yml
else
    echo "        url: https://downloads.apache.org/kafka/3.1.2/kafka_2.13-3.1.2.tgz"       >> ansible/packages.yml
    echo "        dest: /opt/kafka_2.13-3.1.2.tgz"                                          >> ansible/packages.yml
    echo "        mode: 0440"                                                               >> ansible/packages.yml
    echo "    - name: Extract kafka_2.13-3.1.2.tgz"                                         >> ansible/packages.yml
    echo "      become: true"                                                               >> ansible/packages.yml
    echo "      unarchive:"                                                                 >> ansible/packages.yml
    echo "        src: /opt/kafka_2.13-3.1.2.tgz"                                           >> ansible/packages.yml
    echo "        dest: /opt/"                                                              >> ansible/packages.yml
    echo "        remote_src: yes"                                                          >> ansible/packages.yml
    echo "    - name: Rename kafka folder"                                                  >> ansible/packages.yml
    echo "      become: true"                                                               >> ansible/packages.yml
    echo "      command: \"mv /opt/kafka_2.13-3.1.2 /opt/kafka\""                           >> ansible/packages.yml
    echo "    - name: Remove kafka tar"                                                     >> ansible/packages.yml
    echo "      become: true"                                                               >> ansible/packages.yml
    echo "      file:"                                                                      >> ansible/packages.yml
    echo "        path: /opt/kafka_2.13-3.1.2.tgz"                                          >> ansible/packages.yml
    echo "        state: absent"                                                            >> ansible/packages.yml
fi
echo "    - name: Create monitoring directory"                                              >> ansible/packages.yml
echo "      become: true"                                                                   >> ansible/packages.yml
echo "      file:"                                                                          >> ansible/packages.yml
echo "        path: \"/opt/monitoring\""                                                    >> ansible/packages.yml
echo "        state: directory"                                                             >> ansible/packages.yml
echo "        mode: '0755'"                                                                 >> ansible/packages.yml
echo "    - name: Download JMX exporter"                                                    >> ansible/packages.yml
echo "      become: true"                                                                   >> ansible/packages.yml
echo "      get_url:"                                                                       >> ansible/packages.yml
echo "        url: https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.18.0/jmx_prometheus_javaagent-0.18.0.jar"    >> ansible/packages.yml
echo "        dest: /opt/monitoring/jmx_prometheus_javaagent-0.18.0.jar"                    >> ansible/packages.yml
echo "        mode: 0440"                                                                   >> ansible/packages.yml

#########################################################################################################
#########                   DEPLOYMENT TERRAFORM FILE                                           #########
#########################################################################################################

echo "resource \"aws_instance\" \"ansible\" {"                                                                > deployment.tf
echo "  ami                    = data.aws_ami.ubuntu.id"                                                      >> deployment.tf
echo "  instance_type          = \"t2.small\""                                                                >> deployment.tf
echo "  subnet_id              = aws_subnet.public_subnet[0].id"                                              >> deployment.tf
echo "  vpc_security_group_ids = [aws_security_group.sg.id]"                                                  >> deployment.tf
echo "  key_name               = var.keypair"                                                                 >> deployment.tf
echo "  depends_on             = [local_file.ansible_hosts, aws_instance.ec2broker, aws_instance.ec2zoo]"     >> deployment.tf
echo "  iam_instance_profile   = \"SSMforEC2\""                                                               >> deployment.tf
echo "  tags = {"                                                                                             >> deployment.tf
echo "    Name = \"ansible-node\""                                                                            >> deployment.tf
echo "  }"                                                                                                    >> deployment.tf
echo "  provisioner \"file\" {"                                                                               >> deployment.tf
echo "    source      = \"\${var.key_path}\${var.keypair}.pem\""                                                >> deployment.tf
echo "    destination = \"\${var.keypair}.pem\""                                                               >> deployment.tf
echo "  }"                                                                                                    >> deployment.tf
echo "  connection {"                                                                                         >> deployment.tf
echo "    type = \"ssh\""                                                                                     >> deployment.tf
echo "    user = var.userssh"                                                                                 >> deployment.tf
echo "    private_key = file(\"\${var.key_path}\\\\\${var.keypair}.pem\")"                                        >> deployment.tf
echo "    host = self.public_dns"                                                                             >> deployment.tf
echo "  }"                                                                                                    >> deployment.tf
echo "  provisioner \"local-exec\" {"                                                                         >> deployment.tf
echo "    command = \"scp -i \${var.key_path}\${var.keypair}.pem -o StrictHostKeyChecking=no ./ansible/* ubuntu@\${self.public_dns}:~/\"" >> deployment.tf
echo "  }"                                                                                                    >> deployment.tf
echo "  provisioner \"remote-exec\" {"                                                                        >> deployment.tf
echo "    inline = ["                                                                                         >> deployment.tf
echo "      \"sudo apt-get update && sudo apt-get upgrade -y\","                                              >> deployment.tf
echo "      \"sudo apt-get install software-properties-common -y\","                                          >> deployment.tf
echo "      \"sudo add-apt-repository --yes --update ppa:ansible/ansible\","                                  >> deployment.tf
echo "      \"sudo apt-get install ansible -y\","                                                             >> deployment.tf
echo "      \"sudo mv \${var.keypair}.pem /tmp/\${var.keypair}.pem\","                                          >> deployment.tf
echo "      \"sudo chmod 400 /tmp/\${var.keypair}.pem\","                                                      >> deployment.tf
echo "      \"sudo rm /etc/ansible/ansible.cfg && sudo mv ansible.cfg /etc/ansible/ansible.cfg\","            >> deployment.tf
echo "      \"sudo rm /etc/ansible/hosts && sudo mv hosts /etc/ansible/hosts\","                              >> deployment.tf
echo "      \"sudo mkdir /opt/ansible-files && sudo mv * /opt/ansible-files/\","                              >> deployment.tf
echo "      \"ansible-playbook /opt/ansible-files/packages.yml --private-key /tmp/\${var.keypair}.pem\","      >> deployment.tf
echo "      \"ansible-playbook /opt/ansible-files/zoo.yml --private-key /tmp/\${var.keypair}.pem\","           >> deployment.tf
echo "      \"ansible-playbook /opt/ansible-files/kafka.yml --private-key /tmp/\${var.keypair}.pem\","         >> deployment.tf
if [ $SCHEMA -gt 0 ]                                                                                            
then
    echo "      \"ansible-playbook /opt/ansible-files/schema-registry.yml --private-key /tmp/\${var.keypair}.pem\","  >> deployment.tf
fi

if [ $MM -gt 0 ]
then 
    echo "      \"ansible-playbook /opt/ansible-files/mm.yml --private-key /tmp/\${var.keypair}.pem\"," >> deployment.tf     
fi

if [ $CRUISE -gt 0 ]
then
    echo "      \"ansible-playbook /opt/ansible-files/cruisecontrol.yml --private-key /tmp/\${var.keypair}.pem\","  >> deployment.tf
fi

echo "      \"ansible-playbook /opt/ansible-files/service-start.yml --private-key /tmp/\${var.keypair}.pem\""  >> deployment.tf

echo "    ]"                                                                                                  >> deployment.tf
echo "  }"                                                                                                    >> deployment.tf
echo "}"                                                                                                      >> deployment.tf
echo "output \"ansible_public_ip\" {"                                                                         >> deployment.tf
echo "  value = aws_instance.ansible.public_ip"                                                               >> deployment.tf
echo "}"                                                                                                      >> deployment.tf

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

if [ $CRUISE -gt 0 ]
then
    echo "[cruise]"                                                                                           >> ansibleconf.tf
    echo "%{ for ip in aws_instance.ec2cruise.*.private_ip ~}"                                                >> ansibleconf.tf
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
#########                        SERVICE START YAML FILE                                        #########
#########################################################################################################

echo "---"                                                              > ansible/service-start.yml
echo "- name: Start Zookeeper Services"                                 >> ansible/service-start.yml
echo "  hosts: zoo"                                                     >> ansible/service-start.yml
echo "  remote_user: ubuntu"                                            >> ansible/service-start.yml
echo "  serial: 1"                                                      >> ansible/service-start.yml
echo "  tasks:"                                                         >> ansible/service-start.yml
echo "  - name: Start zookeeper service"                                >> ansible/service-start.yml
echo "    become: true"                                                 >> ansible/service-start.yml
echo "    systemd:"                                                     >> ansible/service-start.yml
echo "      name: zookeeper.service"                                    >> ansible/service-start.yml
echo "      state: started"                                             >> ansible/service-start.yml
echo "      enabled: true"                                              >> ansible/service-start.yml
echo "- name: Start Kafka Services"                                     >> ansible/service-start.yml
echo "  hosts: kafka"                                                   >> ansible/service-start.yml
echo "  remote_user: ubuntu"                                            >> ansible/service-start.yml
echo "  serial: 1"                                                      >> ansible/service-start.yml
echo "  tasks:"                                                         >> ansible/service-start.yml
echo "  - name: Start kafka service"                                    >> ansible/service-start.yml
echo "    become: true"                                                 >> ansible/service-start.yml
echo "    systemd:"                                                     >> ansible/service-start.yml
echo "      name: kafka.service"                                        >> ansible/service-start.yml
echo "      state: started"                                             >> ansible/service-start.yml
echo "      enabled: true"                                              >> ansible/service-start.yml

if [ $SCHEMA -gt 0 ]
then
    echo "- name: Start Schema Registry Services"                       >> ansible/service-start.yml
    echo "  hosts: schemareg"                                           >> ansible/service-start.yml
    echo "  remote_user: ubuntu"                                        >> ansible/service-start.yml
    echo "  serial: 1"                                                  >> ansible/service-start.yml
    echo "  tasks:"                                                     >> ansible/service-start.yml
    echo "  - name: Start schema registry service"                      >> ansible/service-start.yml
    echo "    become: true"                                             >> ansible/service-start.yml
    echo "    systemd:"                                                 >> ansible/service-start.yml
    echo "      name: schema-registry.service"                          >> ansible/service-start.yml
    echo "      state: started"                                         >> ansible/service-start.yml
    echo "      enabled: true"                                          >> ansible/service-start.yml
fi

if [ $CRUISE -gt 0 ]
then
    echo "- name: Start Cruise Control Services"                        >> ansible/service-start.yml
    echo "  hosts: cruise"                                              >> ansible/service-start.yml
    echo "  remote_user: ubuntu"                                        >> ansible/service-start.yml
    echo "  serial: 1"                                                  >> ansible/service-start.yml
    echo "  tasks:"                                                     >> ansible/service-start.yml
    echo "  - name: Start cruise control service"                       >> ansible/service-start.yml
    echo "    become: true"                                             >> ansible/service-start.yml
    echo "    systemd:"                                                 >> ansible/service-start.yml
    echo "      name: cruise.service"                                   >> ansible/service-start.yml
    echo "      state: started"                                         >> ansible/service-start.yml
    echo "      enabled: true"                                          >> ansible/service-start.yml
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