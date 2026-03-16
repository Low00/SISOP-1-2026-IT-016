#!/bin/bash

awk -F: '
/"id"/ {
    gsub(/[", ]/, "", $2)
    id=$2
}

/site_name/ {
    gsub(/[",]/, "", $2)
    site=$2
}

/latitude/ {
    gsub(/[", ]/, "", $2)
    lat=$2
}

/longitude/ {
    gsub(/[", ]/, "", $2)
    lon=$2
    printf "%s,%s,%s,%s\n", id, site, lat, lon
}
' gsxtrack.json > titik-penting.txt
