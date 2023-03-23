#!/bin/bash

sed -i "s/kafka_ips:.*/kafka_ips: \"\"/g" ansible/cruisecontrol.yml
sed -i "s/kafka_ips:.*/kafka_ips: \"\"/g" ansible/schema-registry.yml
sed -i "s/zoo_ips:.*/zoo_ips: \"\"/g" ansible/cruisecontrol.yml
sed -i "s/zoo_ips:.*/zoo_ips: \"\"/g" ansible/kafka.yml
