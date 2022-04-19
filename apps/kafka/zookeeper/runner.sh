#!/bin/bash

echo "Sts name : $STS_NAME"
echo "Pod name : $POD_NAME"

instanceNumber=$(echo $POD_NAME | sed s/"$STS_NAME-"/""/g)
echo "Stateful set instance number: $instanceNumber"

bash /kafka/bin/zookeeper-server-start.sh /runner/zookeeper.properties
