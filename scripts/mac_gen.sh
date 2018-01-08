#!/bin/bash
RAW_MAC=$(xxd -p -l 6 /dev/urandom \
| awk '
{
    and_num = strtonum("0xfeffffffffff");
    or_num = strtonum("0x020000000000");
    numstr = "0x"$1;
    num = strtonum(numstr);
    mod_num = and( or( num, or_num ), and_num );
    printf "%0x\n", mod_num;
}')

SEP_MAC=$(echo "${RAW_MAC}" | sed 's/.\{2\}/&:/g')
SEP_MAC="${SEP_MAC%?}"

MAC_CISCO=$(echo "${RAW_MAC}" | sed 's/.\{4\}/&./g')
MAC_CISCO="${MAC_CISCO%?}"

echo $RAW_MAC
echo $SEP_MAC
echo $MAC_CISCO
