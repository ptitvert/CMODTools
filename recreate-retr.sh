#!/bin/bash

# Author: Alessandro Perucchi



# Please Change this path to the installation directory of your CMOD binaries.
ODINSTALL="/home/cmod/ibm/ondemand/V9.5"

# After this point the magic is done!
# Continue with care :-D
ODINSTANCE="$1"

if [[ -z "$ODINSTANCE" ]]; then
  echo "Usage: ${0} ODINSTANCE"
  exit 1
fi

ARSINI="$ODINSTALL/config/ars.ini"

if [[ ! -f ${ARSINI} ]]; then
  echo "Could not find the file '${ARSINI}' please check the path, and 
  exit 1
fi

ARSCACHE=$(awk -F= '/^\[@SRV@_'${ODINSTANCE}'\]/ {PRINT=1} PRINT==1 && /^SRVR_SM_CFG=/ {print $2;exit}' "$ARSINI")
if [[ ! -f $ARSCACHE ]]; then
  echo "file '$ARSCACHE' not found, please check if the instance '$ODINSTANCE' is correctly spelled"
  exit 1
fi
DBNAME=$(awk -F= '/^\[@SRV@_'${ODINSTANCE}'\]/ {PRINT=1} PRINT==1 && /^SRVR_INSTANCE=/ {print $2;exit}' "$ARSINI")
ODINSTANCE=$(awk -F= '/^\[@SRV@_'${ODINSTANCE}'\]/ {PRINT=1} PRINT==1 && /^SRVR_INSTANCE_OWNER=/ {print $2;exit}' "$ARSINI")

if [[ $ODINSTANCE != $(whoami) ]]; then
  echo "You are not the OD instance owner ($ODINSTANCE), please switch user"
  exit 1
fi

MAINDIR=$(grep ^/ "${ARSCACHE}" |sed -n 1p)
RETRDIR="${MAINDIR}/${DBNAME}/retr"

if [[ ! -d "${MAINDIR}/${DBNAME}" ]]; then
  echo "Cache directory '${MAINDIR}/${DBNAME}' not found"
  exit 1
fi
if [[ -d "$RETRDIR" ]]; then
  echo "Removing the retr directory"
  rm -rf "$RETRDIR"
fi
echo "Recreating the retr directory"
mkdir -m 0700 "$RETRDIR"
umask 077
grep ^/ "${ARSCACHE}" | while read cachedir
do
  BASEDIR="$cachedir/$DBNAME"
  cd "${BASEDIR}"
  find . -type f 2> /dev/null | while read cachefile
  do
    cachefile=$(echo "$cachefile" | sed 's!^./!!')
    FIRSTPART=$(echo "$cachefile" | awk -F'/' '{print $1}' | sed 's/[0-9]//g')
    if [[ ! -z "${FIRSTPART}" ]]; then
      echo "Skipping directory '${BASEDIR}/${FIRSTPART}'"
      continue
    fi
    echo "$BASEDIR -> $cachefile"
    MINDIR=$(echo "$cachefile" | awk -F'/' '{print $2"/"$3}')
    STEMFILE=$(echo "$cachefile" | awk -F'/' '{print $2"/"$3"/"$4}')
    mkdir -p -m 0700 "${RETRDIR}/${MINDIR}"
    ln -s "${BASEDIR}/${cachefile}" "${RETRDIR}/${STEMFILE}"
  done
done
