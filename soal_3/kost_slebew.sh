#!/bin/bash

DATA="data/penghuni.csv"
LOG="log/tagihan.log"
REKAP="rekap/laporan_bulanan.txt"
SAMPAH="sampah/history_hapus.csv"

log_activity(){
    waktu=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$waktu] [INFO] $1" >> $LOG
}

tambah_penghuni(){

    echo "=== TAMBAH PENGHUNI ==="

    read -p "Masukkan Nama: " nama
    read -p "Masukkan Nomor Kamar: " kamar
    read -p "Masukkan Harga Sewa: " harga
    read -p "Masukkan Tanggal Masuk (YYYY-MM-DD): " tanggal
    read -p "Status (Aktif/Menunggak): " status

    echo "$nama,$kamar,$harga,$tanggal,$status" >> $DATA

    echo "Penghuni berhasil ditambahkan."
    log_activity "Menambahkan penghuni $nama kamar $kamar"
}

hapus_penghuni(){

    echo "=== HAPUS PENGHUNI ==="
    read -p "Masukkan nama penghuni: " nama

    grep "$nama" $DATA >> $SAMPAH
    sed -i "/$nama/d" $DATA

    tanggal=$(date "+%Y-%m-%d")
    sed -i "\$s/$/,$tanggal/" $SAMPAH

    echo "Penghuni $nama dihapus."
    log_activity "Menghapus penghuni $nama"
}

tampilkan_penghuni(){

echo "===== DAFTAR PENGHUNI ====="

awk -F',' '
BEGIN{
print "No | Nama | Kamar | Harga | Status"
}
{
printf "%d | %s | %s | %s | %s\n", NR,$1,$2,$3,$5
}
END{
print "---------------------------"
print "Total penghuni:",NR
}
' $DATA

read -p "Tekan enter untuk kembali"
}

update_status(){

read -p "Masukkan nama penghuni: " nama
read -p "Status baru (Aktif/Menunggak): " status

awk -F',' -v n="$nama" -v s="$status" '
BEGIN{OFS=","}
{
if($1==n){
$5=s
}
print
}
' $DATA > temp.csv

mv temp.csv $DATA

log_activity "Update status $nama menjadi $status"

echo "Status berhasil diperbarui"
}

laporan_keuangan(){

echo "=== LAPORAN KEUANGAN ==="

awk -F',' '
BEGIN{
total=0
nunggak=0
aktif=0
}
{
if($5=="Aktif"){
total+=$3
aktif++
}
if($5=="Menunggak"){
nunggak+=$3
}
}
END{
print "Total pemasukan (aktif): Rp",total
print "Total tunggakan: Rp",nunggak
print "Jumlah kamar aktif:",aktif
}
' $DATA | tee $REKAP

echo "Laporan disimpan di $REKAP"
}

menu_cron(){

while true
do

echo "===== MENU CRON ====="
echo "1. Lihat Cron Aktif"
echo "2. Tambah Cron Reminder"
echo "3. Hapus Cron"
echo "4. Kembali"

read -p "Pilih: " pilih

case $pilih in

1)
crontab -l
;;

2)

read -p "Jam (0-23): " jam
read -p "Menit (0-59): " menit

echo "$menit $jam * * * echo 'Reminder cek tagihan' >> log/tagihan.log" | crontab -

echo "Cron berhasil ditambahkan"
;;

3)

crontab -r
echo "Cron dihapus"
;;

4)
break
;;

*)
echo "Pilihan tidak ada"
;;

esac

done

}

while true
do

echo "=============================="
echo "SISTEM MANAJEMEN KOST"
echo "1. Tambah Penghuni"
echo "2. Hapus Penghuni"
echo "3. Tampilkan Daftar Penghuni"
echo "4. Update Status Penghuni"
echo "5. Laporan Keuangan"
echo "6. Kelola Cron"
echo "7. Exit"
echo "=============================="

read -p "Pilih menu: " menu

case $menu in

1)
tambah_penghuni
;;

2)
hapus_penghuni
;;

3)
tampilkan_penghuni
;;

4)
update_status
;;

5)
laporan_keuangan
;;

6)
menu_cron
;;

7)
echo "Keluar..."
exit
;;

*)
echo "Menu tidak tersedia"
;;

esac

done
