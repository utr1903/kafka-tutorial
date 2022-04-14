#!/bin/bash

echo "Sts name : $STS_NAME"
echo "Pod name : $POD_NAME"

instanceNumber=$(echo $POD_NAME | sed s/"$STS_NAME-"/""/g)
echo "Stateful set instance number: $instanceNumber"

sed s/"broker.id=###BROKER_ID###"/"broker.id=${instanceNumber}"/g /etc/config/server.properties

bash /kafka/bin/kafka-server-start.sh /etc/config/server.properties
