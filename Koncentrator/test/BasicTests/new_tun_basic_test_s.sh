#!/bin/bash

set -ex 
set -o pipefail

#CERT createCa 
curl -v -X PUT "http://digitalocean.ivantichy.cz:10001/createca" --data '{"subvpn_name" : "tap-advanced-12345", "subvpn_type" : "tap-advanced", "domain" : "tap-advanced-12345.tap-advanced.koncentrator.cz", "ca_valid_days" : 3650}' -o ca.json

#CERT generateServer
wget "http://digitalocean.ivantichy.cz:10001/generateserver/?subvpn_name=tap-advanced-12345&subvpn_type=tap-advanced&common_name=tap-advanced-12345&domain=koncentrator.cz&server_valid_days=3650" -O server.json

#CERT generateProfile
wget "http://digitalocean.ivantichy.cz:10001/generateprofile/?subvpn_name=tap-advanced-12345&subvpn_type=tap-advanced&common_name=test1&domain=koncentrator.cz&profile_valid_days=90" -O profile.json -T 10

chmod 666 *.json

java -classpath "Koncentrator/*:Koncentrator/lib/*" cz.ivantichy.support.JSON.test.JSONAddParameter ca.json ip_range 123.123.123.123/16
java -classpath "Koncentrator/*:Koncentrator/lib/*" cz.ivantichy.support.JSON.test.JSONAddParameter ca.json node 1
java -classpath "Koncentrator/*:Koncentrator/lib/*" cz.ivantichy.support.JSON.test.JSONAddParameter ca.json server_device tun1
java -classpath "Koncentrator/*:Koncentrator/lib/*" cz.ivantichy.support.JSON.test.JSONAddParameter ca.json server_management_port 20001
java -classpath "Koncentrator/*:Koncentrator/lib/*" cz.ivantichy.support.JSON.test.JSONAddParameter ca.json server_port 15001
java -classpath "Koncentrator/*:Koncentrator/lib/*" cz.ivantichy.support.JSON.test.JSONAddParameter ca.json server_protocol udp
java -classpath "Koncentrator/*:Koncentrator/lib/*" cz.ivantichy.support.JSON.test.JSONAddParameter ca.json server_domain_name tun-advanced.koncentrator.cz

java -classpath "Koncentrator/*:Koncentrator/lib/*" cz.ivantichy.support.JSON.test.JSONAddParameter server.json server_commands ""

java -classpath "Koncentrator/*:Koncentrator/lib/*" cz.ivantichy.support.JSON.test.JSONAddParameter profile.json ip_remote 10.10.10.10
java -classpath "Koncentrator/*:Koncentrator/lib/*" cz.ivantichy.support.JSON.test.JSONAddParameter profile.json ip_local 10.10.10.11
java -classpath "Koncentrator/*:Koncentrator/lib/*" cz.ivantichy.support.JSON.test.JSONAddParameter profile.json profile_commands ""



#VPN createSUBVPN
curl -v -X PUT "http://digitalocean.ivantichy.cz:10002/createsubvpn" -d @ca.json

#VPN createServer
curl -v -X PUT "http://digitalocean.ivantichy.cz:10002/createserver" -d @server.json
#VPN createServer
curl -v -X PUT "http://digitalocean.ivantichy.cz:10002/createserver" -d @server.json

#VPN createProfile
curl -v -X PUT "http://digitalocean.ivantichy.cz:10002/createprofile" -d @profile.json
#VPN createProfile
curl -v -X PUT "http://digitalocean.ivantichy.cz:10002/createprofile" -d @profile.json



#CERT deleteCa
curl -v -X DELETE "http://digitalocean.ivantichy.cz:10001/deleteca?subvpn_name=tap-advanced-12345&subvpn_type=tap-advanced"
