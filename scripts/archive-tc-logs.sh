#!/bin/bash
#set -x
# v01 by JSv
# odsouva zagzipovane logy do archivniho adresare

TC=`ls /srv/tc`
ARCHIVE="logs.ARCHIVE"
SUFFIX="gz"


function archiveme
{
if [ -e $CESTA/$ARCHIVE ];
        then
                mv $CESTA/*.$SUFFIX $CESTA/$ARCHIVE/
        else
                mkdir $CESTA/$ARCHIVE
                chown tc$i:tc$i $CESTA/$ARCHIVE
                archiveme
fi
}

for i in $TC;
        do
                CESTA="/srv/tc/$i/logs"
                archiveme
        done

