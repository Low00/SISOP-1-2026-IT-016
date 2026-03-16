#!/bin/bash

awk -F',' '
NR==1 {
    lat1=$3
    lon1=$4
}

NR==3 {
    lat3=$3
    lon3=$4
}

END {
    mid_lat=(lat1+lat3)/2
    mid_lon=(lon1+lon3)/2

    printf "Pusat Pusaka: %.6f, %.6f\n", mid_lat, mid_lon
}
' titik-penting.txt > posisi-pusaka.txt
