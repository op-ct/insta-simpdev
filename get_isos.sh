ARIA2_CONF="${PWD}/.aria2/aria2.conf"
DOWNLOADS_DIR=downloads

# This will need to be more robust for CentOS images that have been retired to
# vault
CENTOS_7_DVD="${CENTOS_7_DVD:-CentOS-7-x86_64-DVD-1708.iso}"
CENTOS_6_DVD_1="${CENTOS_6_DVD_1:-CentOS-6.9-x86_64-bin-DVD1.iso}"
CENTOS_6_DVD_2="${CENTOS_6_DVD_2:-CentOS-6.9-x86_64-bin-DVD2.iso}"

mkdir -p "${DOWNLOADS_DIR}"

links http://isoredirect.centos.org/centos/7/isos/x86_64/ -dump | grep x86_64 | awk '{print $2}' > ${DOWNLOADS_DIR}/servers.centos7
sed -e 's@/$@/${CENTOS_7_DVD}@' ${DOWNLOADS_DIR}/servers.centos7  > ${DOWNLOADS_DIR}/servers.centos7.${CENTOS_7_DVD}.urls
tr "\n" "\t" < ${DOWNLOADS_DIR}/servers.centos7.${CENTOS_7_DVD}.urls > x.$$
cat x.$$ > ${DOWNLOADS_DIR}/servers.centos7.${CENTOS_7_DVD}.urls

aria2c --conf-path=${ARIA2_CONF} \
       --input-file ${DOWNLOADS_DIR}/servers.centos7.${CENTOS_7_DVD}.urls


links http://isoredirect.centos.org/centos/6/isos/x86_64/ -dump | grep x86_64 | awk '{print $2}' > ${DOWNLOADS_DIR}/servers.centos6
sed -e 's@/$@/${CENTOS_6_DVD_1}@' \
        ${DOWNLOADS_DIR}/servers.centos6  > ${DOWNLOADS_DIR}/servers.centos6.${CENTOS_6_DVD_1}.urls

tr "\n" "\t" < ${DOWNLOADS_DIR}/servers.centos6.${CENTOS_6_DVD_1}.urls > x.$$
cat x.$$ > ${DOWNLOADS_DIR}/servers.centos6.${CENTOS_6_DVD_1}.urls
rm -f x.$$

aria2c --conf-path=${ARIA2_CONF} \
       --input-file ${DOWNLOADS_DIR}/servers.centos6.${CENTOS_6_DVD_1}.urls

sed -e 's@/$@/${CENTOS_6_DVD_2}@' \
tr "\n" "\t" < ${DOWNLOADS_DIR}/servers.centos6.${CENTOS_6_DVD_2}.urls > x.$$
cat x.$$ > ${DOWNLOADS_DIR}/servers.centos6.${CENTOS_6_DVD_2}.urls
        ${DOWNLOADS_DIR}/servers.centos6  > ${DOWNLOADS_DIR}/servers.centos6.${CENTOS_6_DVD_2}.urls
rm -f x.$$

aria2c --conf-path=${ARIA2_CONF} \
       --input-file ${DOWNLOADS_DIR}/servers.centos6.${CENTOS_6_DVD_2}.urls
