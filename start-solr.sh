#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export CATALINA_HOME=${DIR}/tomcat

echo "Make sure no other Tomcat instance is running on port 9080..."
echo
echo "------------------------------------------------------------------"
${CATALINA_HOME}/bin/startup.sh
echo "------------------------------------------------------------------"
echo
echo "SOLR instance running at http://localhost:9080/vlo-solr-3.1"
