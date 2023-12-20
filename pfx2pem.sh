#!/bin/bash

MAXWAIT=100 # wait up to n seconds before continuing, in case another server is connverting certificates right now
CERT_DIR="/mnt/tls/*"

# the random wait
sleep $((RANDOM % MAXWAIT))

# go thru all dirs (e.g. docker.core.foo.net) in $CERT_DIR (e.g. /mnt/tls) looking for an absence of pem files (e.g. just the .pfx and .new files)
for d in $CERT_DIR/ ; do
    num_of_pem_files=$(find $d -mindepth 1 -type f -name "*.pem" -not -path "*/.*" -printf x | wc -c)

    # find number of pem files in directory. is it nonzero? if so, proceed
    if [ $num_of_pem_files == 0 ]; then
        # do the conversion
        echo "Looks like $d is missing a pem file..."
        cd $d
        for i in *.pfx; do
            base_name=$(basename $i .pfx) # yields docker.core.foo.net from docker.core.foo.net.pfx
                #(note, cannot rely on dir name in case there are multiple pfx certs in one dir, hence this loop!)
            echo "I'm converting $i into a .pem equivalent"
            openssl pkcs12 -nodes -in "$d/$i" -passin pass:"" -out "$d/$base_name.pem"
        done
    fi
done
