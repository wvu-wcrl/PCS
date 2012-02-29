#!/bin/sh

BIN_DIR=`dirname $0`

#
# Check Parameters
#
config=0
quick=0
silent=0
while getopts "qcs" options; do
  case $options in
    q) quick=1
       config=1
       ;;
    c) quick=0
       config=1
       ;;
    *) echo rapids.sh [-q] [-c]
       exit 1;;
  esac
done

#
# Handle Configuration

if [ $config -eq 1 ]; then
  if [ $quick -eq 1 ]; then
    $BIN_DIR/configure.sh -q -s
    exit 0
  else
    $BIN_DIR/configure.sh -c -s
    exit 0
  fi
fi

#
# Verify that we have been configured and configure if necessary
#
ENV_FILE=$HOME/FrontierRapids/RapidsSettings.sh
if [ ! -e "$ENV_FILE" ]; then
  echo "Frontier Rapids has not been configured for this user."
  echo
  read -e -p "Do you want to configure now? [y] : " ANS
  if [ "$ANS" == "y" -o "$ANS" == "Y" -o "$ANS" == "" ]; then
    read -e -p "Do you want to do the quick configuration (recommended)? [y] : " ANS 
    if [ "$ANS" == "y" -o "$ANS" == "Y" -o "$ANS" == "" ]; then
      $BIN_DIR/configure.sh -q -s
    else
      $BIN_DIR/configure.sh -c -s
    fi
  else
    exit 0
  fi

  echo
  echo "Your Rapids installation has been configured."
  echo
  echo "You can use Rapids -q to update these settings in the future."
  echo "You can use Rapids -c for advanced configuration."
  echo
fi

#
# Load Configuration
#
. "$ENV_FILE"

#
# Install sample templates if required
#
if [ ! -e "$TEMPLATE_DIR" ]; then
  echo "Creating sample templates..."
  cp -R "$INSTALL_DIR/templates" "$TEMPLATE_DIR" &> /dev/null
  echo "Templates created in $TEMPLATE_DIR"
  echo
  echo "Frontier Rapids is now ready for use. Type 'help' for help."
  echo
fi

#
# Verify credential files exist
#
if [ ! -f "$CLIENT_TRUSTSTORE" ] ; then 
  echo Client truststore file missing.
  exit 1
fi

echo "Welcome to Frontier Rapids!"
echo
echo "Using template directory: $TEMPLATE_DIR"

CLASSPATH=.:$FRONTIER_LIB/frontier-sdk.jar:$FRONTIER_LIB/jline-0.9.94.jar:$FRONTIER_LIB/jsr173_1.0_api.jar:$FRONTIER_LIB/jaxb-api.jar:$FRONTIER_LIB/jaxb-impl.jar:$FRONTIER_LIB/activation.jar:$FRONTIER_LIB/Rapids.jar:$FRONTIER_LIB/RapidsTask.jar

java \
    -Xmx1024M \
    -classpath $CLASSPATH \
    "-Dfrontier.configuration=$FRONTIER_CONF/frontier.properties" \
    "-Dcom.parabon.client.server=https://$SERVER_HOSTPORT/servlets/ClientServlet?na=na&na=na" \
    "-Dserver=https://$SERVER_HOSTPORT/servlets/ClientServlet?na=na&na=na" \
    "-Djavax.net.ssl.trustStore=$CLIENT_TRUSTSTORE" \
    "-Dcom.parabon.frontier.user.username=$USERNAME" \
    "-Dcom.parabon.frontier.user.password=$PASSWORD" \
    "-Dcom.parabon.platform.graph=$FRONTIER_CONF/platformGraph.xml" \
    "-DsettingsDir=$SETTINGS_DIR" \
    "-DinstallDir=$INSTALL_DIR" \
    "-DjobDir=$JOB_DIR" \
    "-DtemplateDir=$TEMPLATE_DIR" \
    "-DwaitFlag=$WAIT_FLAG" \
    "-Dmode=remote" \
    "-Ddebug.mode=$DEBUG_FLAG" \
    com.parabon.rapids.Rapids $* 
