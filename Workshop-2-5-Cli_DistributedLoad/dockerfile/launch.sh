#!/bin/bash

set -e
#freeMem=`awk '/MemFree/ { print int($2/1024) }' /proc/meminfo`
s=2
x=2
export JVM_ARGS="-Xms${s}g -Xmx${x}g -XX:MaxMetaspaceSize=512m"
echo "START Running Jmeter on `date`"
echo "JVM_ARGS=${JVM_ARGS}"
echo "jmeter args=$@"

jmeter $@
echo "END Running Jmeter on `date`"