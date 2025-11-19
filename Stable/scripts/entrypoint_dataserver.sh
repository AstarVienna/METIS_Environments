#!/usr/bin/env bash

export DATADIR=/root/space/dataserver
echo "Create ${DATADIR}"
mkdir -p "${DATADIR}"
mkdir -p "${DATADIR}/cdata"  # Cache from other data servers, unused
mkdir -p "${DATADIR}/idata"  # 'Ingested data', unused
mkdir -p "${DATADIR}/sdata"  # Stored data, default, can be overwritten
mkdir -p "${DATADIR}/pdata"  # Permanent data, cannot be overwritten
mkdir -p "${DATADIR}/xdata"  # Direct read, unused
mkdir -p "${DATADIR}/ydata"  # Direct write, unused
mkdir -p "${DATADIR}/ddata"  # Deleted data
mkdir -p "${DATADIR}/tdata"  # Temporary data, unused

echo "Generate self-signed certificate"
cd "${DATADIR}" || exit 1
# Create key.
openssl genrsa -out mylocalhost.key 2048
# Create certificate signing request.
openssl req -key mylocalhost.key -new -out mylocalhost.csr -subj "/CN=localhost"
# Sign certificate.
openssl x509 -signkey mylocalhost.key -in mylocalhost.csr -req -days 365 -out mylocalhost.crt
# Combine key and certificate in single pem file.
cat mylocalhost.key mylocalhost.crt > mylocalhost.pem

echo "Starting dataserver"
python -u -m dataserver.main --config /root/scripts/ds.cfg

#echo "Sleeping so the script won't quit"
#while true ; do sleep 60 ; done
