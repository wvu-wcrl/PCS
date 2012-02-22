#
# Check Params
#
quick=0
silent=0
while getopts "qcs" options; do
  case $options in
    q) export export quick=1;;
    c) quick=0;;
    s) silent=1;;
    *) echo configure.sh [-q] [-c] [-s]
       exit 1;;
  esac
done
    
#
# Get install dir
#
pushd `dirname $0`/../ &> /dev/null
INSTALL_DIR=$PWD
popd &> /dev/null 

#
# Set defaults
#
PRODUCT_NAME="FrontierRapids"
SETTINGS_DIR="$HOME/$PRODUCT_NAME"
WORKING_DIR="$HOME/$PRODUCT_NAME"
JOB_DIR="$WORKING_DIR/jobs"
TEMPLATE_DIR="$WORKING_DIR/templates"
CLIENT_TRUSTSTORE="$INSTALL_DIR/certs/client.truststore"
SERVER_HOSTPORT="server.frontier.parabon.com:443"
ENV_FILE="$SETTINGS_DIR/RapidsSettings.sh"
FRONTIER_LIB="$INSTALL_DIR/lib"
FRONTIER_CONF="$INSTALL_DIR/conf"
DEBUG_FLAG="false"
CLASSPATH="$CLASSPATH:$FRONTIER_LIB"
USERNAME=""
PSSWORD=""

#
# Check for enterprise settings
#
if [ -f "$INSTALL_DIR/conf/server-settings.sh" ]; then
    . "$INSTALL_DIR/conf/server-settings.sh"

    SERVER_HOSTPORT="$FRONTIER_SERVER_HOST:$FRONTIER_SERVER_PORT"
fi

#
# Create setting directory if it doesn't already exist
#
if [ ! -e "$SETTINGS_DIR" ]; then
  mkdir -p "$SETTINGS_DIR"
fi

#
# If the user has an environment file, load it
#
if [ -e "$ENV_FILE" ]; then
  . "$ENV_FILE"
fi

#
# Get configuration values from user
#
echo
echo Configuring Rapids Installation
echo
echo Current settings are shown in square brackets.
echo
echo To edit setting, enter new value and press enter.
echo To keep existing setting, press enter.
echo

if [ $quick -eq 1 ]; then

  read -e -p "Frontier Username [$USERNAME] : " ANS
  if [ "$ANS" != "" ]; then
    USERNAME=$ANS;
  fi

  read -e -p "Frontier Password [$PASSWORD] : " ANS
  if [ "$ANS" != "" ]; then
    PASSWORD=$ANS;
  fi

else 

  read -e -p "Server URL [$SERVER_HOSTPORT] : " ANS
  if [ "$ANS" != "" ]; then
    SERVER_HOSTPORT=$ANS;
  fi

  while true; do
    read -e -p "Truststore Path [$CLIENT_TRUSTSTORE] : " ANS
    if [ "$ANS" != "" ]; then
      CLIENT_TRUSTSTORE=$ANS;
    fi

    if [ ! -e "$CLIENT_TRUSTSTORE" ]; then
      echo "Error: Truststore not found!"
      read -e -p "Try again? [y] : " ANS
      if [ "$ANS" != "y" -a "$ANS" != "Y" -a "$ANS" != "" ]; then
        break;
      fi
    else
      break
    fi
  done

  read -e -p "Frontier Username [$USERNAME] : " ANS
  if [ "$ANS" != "" ]; then
    USERNAME=$ANS;
  fi

  read -e -p "Frontier Password [$PASSWORD] : " ANS
  if [ "$ANS" != "" ]; then
    PASSWORD=$ANS;
  fi

  read -e -p "Job Directory [$JOB_DIR] : " ANS
  if [ "$ANS" != "" ]; then
    JOB_DIR=$ANS;
  fi

  read -e -p "Template Directory [$TEMPLATE_DIR] : " ANS
  if [ "$ANS" != "" ]; then
    TEMPLATE_DIR=$ANS;
  fi

  while true; do
    read -e -p "Debug (true or false) [$DEBUG_FLAG] : " ANS
    if [ "$ANS" != "" ]; then
      if [ "$ANS" = "true" -o "$ANS" = "false" ]; then
        DEBUG_FLAG=$ANS;
        break;
      fi
    else
      break
    fi
  done
fi

#
# Rebuild settings file
#
echo "SETTINGS_DIR=$SETTINGS_DIR"              > "$ENV_FILE"
echo "JOB_DIR=$JOB_DIR"                       >> "$ENV_FILE"
echo "TEMPLATE_DIR=$TEMPLATE_DIR"             >> "$ENV_FILE"
echo "CLIENT_TRUSTSTORE=$CLIENT_TRUSTSTORE"   >> "$ENV_FILE"
echo "USERNAME=$USERNAME"                     >> "$ENV_FILE"
echo "PASSWORD=$PASSWORD"                     >> "$ENV_FILE"
echo "FRONTIER_LIB=$FRONTIER_LIB"             >> "$ENV_FILE"
echo "FRONTIER_CONF=$FRONTIER_CONF"           >> "$ENV_FILE"
echo "DEBUG_FLAG=$DEBUG_FLAG"                 >> "$ENV_FILE"
echo "SERVER_HOSTPORT=$SERVER_HOSTPORT"       >> "$ENV_FILE"
echo "INSTALL_DIR=$INSTALL_DIR"               >> "$ENV_FILE"

#
# Copy templates (if required)
#
if [ ! -d "$TEMPLATE_DIR" ]; then
    mkdir -p "$TEMPLATE_DIR"
    cp -frp "$INSTALL_DIR/templates"/* "$TEMPLATE_DIR/" 
fi

if [ $silent -eq 0 ]; then 
  echo
  echo Configuration complete!
  echo
  read -e -p "Press enter to continue . . ." ANS
fi
