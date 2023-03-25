#!/bin/bash

sed -i "s/kafka_ips:.*/kafka_ips: \"\"/g" ansible/cruisecontrol.yml
sed -i "s/kafka_ips:.*/kafka_ips: \"\"/g" ansible/schema-registry.yml
sed -i "s/kafka_ips:.*/kafka_ips: \"\"/g" ansible/connect.yml
sed -i "s/bucket_region:.*/bucket_region: \"\"/g" ansible/connect.yml
sed -i "s/bucket_name:.*/bucket_name: \"\"/g" ansible/connect.yml
sed -i "s/zoo_ips:.*/zoo_ips: \"\"/g" ansible/cruisecontrol.yml
sed -i "s/zoo_ips:.*/zoo_ips: \"\"/g" ansible/kafka.yml

sed -i "38,45s/^#//" ansible/kafka.yml
sed -i "57,58s/^#//" ansible/packages.yml
sed -i "4,9s/^#//" ansible/packages.yml
sed -i "24,56s/^#//" ansible/service-start.yml
sed -i "141s/^#//" ansible/server.properties.j2
sed -i "39,43s/^#//" deployment.tf