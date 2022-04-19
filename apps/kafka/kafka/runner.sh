#!/bin/bash

echo "Sts name : $STS_NAME"
echo "Pod name : $POD_NAME"

instanceNumber=$(echo $POD_NAME | sed s/"$STS_NAME-"/""/g)
echo "Stateful set instance number: $instanceNumber"

sed -i s/"broker.id=###BROKER_ID###"/"broker.id=${instanceNumber}"/g \
    /runner/server.properties

cat /runner/server.properties

bash /kafka/bin/kafka-server-start.sh /runner/server.properties
