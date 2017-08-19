#!/bin/zsh

# Lists of kernel parameters to check
DOMU_FLAG_FILE="./xen_domu_flags"
DOM0_FLAG_FILE="./xen_dom0_flags"
AWK_CMD_FILE="./check_config.awk"

CONFIG_FILE=$1

# Check domu settings
echo "domu settings... ${DOMU_FLAG_FILE}"
while read LINE
do 
    awk -v config_flag="${LINE}" -f "${AWK_CMD_FILE}" "${CONFIG_FILE}"
done <$DOMU_FLAG_FILE

# Check dom0 settings
echo "\ndom0 settings... ${DOM0_FLAG_FILE}"
while read LINE
do 
    awk -v config_flag="${LINE}" -f "${AWK_CMD_FILE}" "${CONFIG_FILE}"
done <$DOM0_FLAG_FILE
