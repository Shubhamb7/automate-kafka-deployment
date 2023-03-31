#!/bin/bash

sed -i "s/bucket_region:.*/bucket_region: \"\"/g" ansible/connect.yml
sed -i "s/bucket_name:.*/bucket_name: \"\"/g" ansible/connect.yml


sed -i "39,46s/^#//" ansible/kafka.yml
sed -i "63,64s/^#//" ansible/packages.yml
sed -i "4,15s/^#//" ansible/packages.yml
sed -i "24,56s/^#//" ansible/service-start.yml
sed -i "141s/^#//" ansible/server.properties.j2
sed -i "39,45s/^#//" deployment.tf
sed -i "14,16s/^#//" ansible/provectus-app.yml.j2
sed -i "8s/^#//" ansible/provectus.yml
sed -i "34,39s/^#//" ansible/prometheus-config.yml.j2
