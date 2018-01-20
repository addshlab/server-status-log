#!/bin/sh

YEAR=`date '+%Y'`
MONTH=`date '+%m'`
DATE=`date '+%d'`

LOG_DIR=logs
LOG_FILE=${DATE}.log

_log() {
  # ログディレクトリが存在する場合
  if [ ! -e ${LOG_DIR} ]; then
    mkdir ${LOG_DIR}
  fi

  # 今年のログディレクトリが無ければ作る
  if [ ! -e ${LOG_DIR}/${YEAR}/${MONTH} ]; then
    mkdir -p ${LOG_DIR}/${YEAR}/${MONTH}
  fi

  echo -e "$1" >> ${LOG_DIR}/${YEAR}/${MONTH}/${LOG_FILE}
}

_log "==================== `date '+%Y-%m-%d %T'` ===================="

_log ''

_log "-------------------- uptime --------------------"

_log "`uptime`"

_log ''

_log "-------------------- System info --------------------"

_log "`uname -a`"

_log ''

_log "-------------------- Storage usage --------------------"

_log "`df -h`"

_log ''

_log "-------------------- System load --------------------"

_log "`sar -f /var/log/sa/sa${DATE} -i 3600`"

_log ''

_log "-------------------- Logged in user --------------------"

while read line; do
  HEADLESS_USERNAME=`echo ${line} | sed -e "s/^\(.\)\(.*\) pts\(.*\)/\2/g"`
  USER_HOSTNAME=`echo ${line} | sed -e "s/^\(.\)\(.*\) (\(.*\))/\3/g"`
  HEADLESS_USERNAME_LENGTH=`expr length "${HEADLESS_USERNAME}"`
  MAKERAND=`md5sum ${LOG_DIR}/${YEAR}/${MONTH}/${LOG_FILE} | fold -w ${HEADLESS_USERNAME_LENGTH} | head -n 1`
  LOGGED_IN_USER=`echo ${line} | sed -e "s/^\(.\)\(.*\) pts\/[0-9]\{1,\} \(.*\) (\(.*\))/\1${MAKERAND} \3/g"`
  _log "${LOGGED_IN_USER}"
done <<END
`who`
END

_log ""
