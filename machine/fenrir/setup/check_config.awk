#!/usr/bin/awk
BEGIN { FS="=" } 

$0 ~ "\\<" config_flag "\\>" { 
    value=$2 
} 

END { 

    if ( length(value) == 0 )
        output="unset"
    else
        output=value

    #print value, length(value), output

    print config_flag, output 
}
