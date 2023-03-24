#!/bin/bash

sed -i "s/kafka_ips:.*/kafka_ips: \"\"/g" ansible/cruisecontrol.yml
sed -i "s/kafka_ips:.*/kafka_ips: \"\"/g" ansible/schema-registry.yml
sed -i "s/zoo_ips:.*/zoo_ips: \"\"/g" ansible/cruisecontrol.yml
sed -i "s/zoo_ips:.*/zoo_ips: \"\"/g" ansible/kafka.yml

sed -i "38,45s/^#//" ansible/kafka.yml
sed -i "27,28s/^#//" ansible/packages.yml
sed -i "24,45s/^#//" ansible/service-start.yml
sed -i "141s/^#//" ansible/server.properties.j2
sed -i "41s/^#//" deployment.tf
sed -i "39s/^#//" deployment.tf