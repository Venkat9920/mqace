#!/bin/bash
# set -x
rm oc.dat
buildConfigurationCR () {
crtype=$1
crname=$2
crfile=$3
echo "apiVersion: appconnect.ibm.com/v1beta1" >> oc.dat
echo "kind: Configuration" >> oc.dat
echo "metadata:" >> oc.dat
echo "  name: ${crname}" >> oc.dat
echo "spec:" >> oc.dat
(echo -n "  data: "; base64 ${crfile}) >> oc.dat
echo "  type: ${crtype}" >> oc.dat
echo "---" >> oc.dat 
}
# create configurations
# types - type of each configuration to create
# files - name of the local file or directory to use when creating configuration
# names - names to use to reference the configuration by
types=("policyproject"         "keystore"        "keystore"        "serverconf")
files=("mqtest"                "application.kdb" "application.sth" "server.conf.yaml")
names=("mqtest-policyproject"  "application.kdb" "application.sth" "mqtest-server.conf.yaml")
for i in ${!names[@]}; do
  file=${files[$i]}
  if [[ -d ${files[$i]} ]]
  then
    zip -r ${file} ${file}
    file=${file}.zip 
  fi
  buildConfigurationCR ${types[$i]} ${names[$i]} ${file}
done
oc apply -f oc.dat
rm oc.dat