#!/bin/bash
#
#
if [ -f /etc/redhat-release ]; then
    if ! rpm -qa | grep jq; then
        sudo yum install -y wget
        wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
        chmod +x ./jq
        sudo cp jq /usr/bin
        echo "jq installed at `which jq`"
fi

