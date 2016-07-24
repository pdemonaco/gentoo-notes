#!/bin/bash
# Quick and dirty script to connect to other monitors at work

# Determine location
SCRIPT_DIR=$(dirname $0)

# Constants
SOURCE="${SCRIPT_DIR}/display_directives"
DOCK_FILE="/tmp/dock_mons"
CMD_FILE="/tmp/dock_cmds"

# Parameters
MODE=$1

# Retrieve monitor names & outputs
MONITORS=$(xrandr --verbose | awk '
/connected/ {
    monitor = $1
}
/[:.]/ && hex {
    sub(/.*000000fc00/, "", hex)
    hex = substr(hex, 0, 26) "0a"
    sub(/0a.*/, "0a", hex)
    printf "%s:%s\n", monitor, hex
    hex=""
}
hex {
    gsub(/[ \t]+/, "")
    hex = hex $0
}
/EDID.*:/ {
    hex=" "
}' | sed 's/ //g' )

if [ -f "${DOCK_FILE}" ]; then
    rm "${DOCK_FILE}"
fi

for ENTRY in ${MONITORS}
do
    NAME=$(echo "${ENTRY}" | awk 'BEGIN { FS=":" } { printf "%s", $2 }' | xxd -r -p | sed 's/ //g')
    OUTPUT=$(echo "${ENTRY}" | awk 'BEGIN { FS=":" } { printf "%s", $1 }')

    if [[ ${OUTPUT} =~ 'eDP1' ]]; then
        NAME="integrated"
    fi

    printf "%s\t%s\n" "${NAME}" "${OUTPUT}" >> "${DOCK_FILE}"
done

KEY=$(sort "${DOCK_FILE}" | awk '
{ 
    mon[NR]=$1 
} 

END { 
    for ( m in mon ) 
    { 
        printf "%s", mon[m]; 
    } 
    printf "\n"; 
}')

# Attempt to find a matching line to process
LINE=$(grep "${KEY}" "${SOURCE}" | awk -v FS='|' '{ print $2 }')

echo "#!/bin/bash" > "${CMD_FILE}"
chmod 700 "${CMD_FILE}"

IFS=$'\t'
for ENTRY in $LINE; do
    NAME=$(echo "${ENTRY}" | awk 'BEGIN { FS=":" } { print $1 }')
    OUTPUT=$(echo "${ENTRY}" | awk 'BEGIN { FS=":" } { print $2 }')
    PARAMS=$(echo "${ENTRY}" | awk -v model="${NAME}" -v FS=':' \
        '$1 ~ model { print $3 }')
    
    IFS=';' read -ra PARM_SET <<< "${PARAMS}"

    grep "${NAME}	${OUTPUT}" "${DOCK_FILE}" > /dev/null
    if [[ $? -ne 0 ]]; then
        continue
    fi

    if [[ $MODE == "start" ]]; then
        echo "xrandr --output ${OUTPUT} ${PARM_SET[0]}" >> "${CMD_FILE}"
    elif [[ $MODE == "stop" ]]; then
        echo "xrandr --output ${OUTPUT} ${PARM_SET[1]}" >> "${CMD_FILE}"
    fi
done
unset IFS

${CMD_FILE}

rm "${DOCK_FILE}"
