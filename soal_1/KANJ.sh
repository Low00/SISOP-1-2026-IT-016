#!/bin/bash

echo "Pilih soal (a/b/c/d/e):"
read opsi

case $opsi in

a)
awk -F',' 'NR>1 {count++}
END{
print "Jumlah seluruh penumpang KANJ adalah",count,"orang"
}' passenger.csv
;;

b)
awk -F',' 'NR>1 {car[$4]=1}
END{
print "Jumlah gerbong penumpang KANJ adalah",length(car)
}' passenger.csv
;;

c)
awk -F',' 'NR>1{
if($2>max){
max=$2
name=$1
}
}
END{
print name,"adalah penumpang kereta tertua dengan usia",max,"tahun"
}' passenger.csv
;;

d)
awk -F',' 'NR>1{
sum+=$2
count++
}
END{
avg=sum/count
printf "Rata-rata usia penumpang adalah %.0f tahun\n",avg
}' passenger.csv
;;

e)
awk -F',' 'NR>1 && $3=="Business"{count++}
END{
print "Jumlah penumpang business class ada",count,"orang"
}' passenger.csv
;;

*)
echo "Soal tidak dikenali. Gunakan a/b/c/d/e"
;;

esac

