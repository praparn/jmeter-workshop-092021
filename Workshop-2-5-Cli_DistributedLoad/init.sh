#!/bin/bash
echo "Step 1: Define IP Address, Timestamp Volume of JMeter Server and JMeter Client"
CLIENT_IP=192.168.100.20
declare -a SERVER_IPS=("192.168.100.10" "192.168.100.11" "192.168.100.12")
timestamp=$(date +%Y%m%d_%H%M%S)
script_path=~/jmeter-workshop-072021/Workshop-2-5-Cli_DistributedLoad/jmeter
result_path=~/jmeter-workshop-072021/Workshop-2-5-Cli_DistributedLoad/result
jmeter_scriptpath=/mnt/jmeter
jmeter_resultpath=/mnt/result

echo "Step 2: Create JMeter server"
for IPADDR in "${SERVER_IPS[@]}"
do
	docker run --name $IPADDR \
	-dit --net jmeternet --ip $IPADDR \
  --mount type=bind,source=${result_path},target=${jmeter_resultpath} \
	--rm labdocker/jmeter:lab -n -s \
	-Jclient.rmi.localport=7000 -Jserver.rmi.localport=60000 -Jserver.rmi.ssl.disable=true \
	-j ${jmeter_resultpath}/server/slave_${timestamp}_${IPADDR}.log 
done

echo "Step 3: Create JMeter client"
docker run --name $CLIENT_IP \
  --net jmeternet --ip $CLIENT_IP \
  --mount type=bind,source=${result_path},target=${jmeter_resultpath} \
  --mount type=bind,source=${script_path},target=${jmeter_scriptpath} \
  -v "${volume_path}":${jmeter_path} \
  --rm labdocker/jmeter:lab -n -X \
  -Jclient.rmi.localport=7000 -Jserver.rmi.ssl.disable=true \
  -R $(echo $(printf ",%s" "${SERVER_IPS[@]}") | cut -c 2-) \
  -t ${jmeter_scriptpath}/Template_Workshop_2_5_FirstPage.jmx \
  -l ${jmeter_resultpath}/client/result_${timestamp}.jtl \
  -j ${jmeter_resultpath}/client/jmeter_${timestamp}.log 
 