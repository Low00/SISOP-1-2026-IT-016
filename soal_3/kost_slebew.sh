#!/bin/bash

DATA="data/penghuni.csv"
LOG="log/tagihan.log"
REKAP="rekap/laporan_bulanan.txt"
SAMPAH="sampah/history_hapus.csv"

# buat folder kalau belum ada
mkdir -p data log rekap sampah
touch $DATA $LOG $REKAP $SAMPAH

# ===== FUNCTION =====

cek_tagihan(){
waktu=$(date "+%Y-%m-%d %H:%M:%S")

awk -F',' -v w="$waktu" '
{
if($5=="Menunggak"){
printf "[%s] TAGIHAN: %s (Kamar: %s) - Menunggak Rp%s\n", w, $1, $2, $3
}
}
' $DATA >> $LOG
}

# jalankan dari cron
if [[ "$1" == "--check-tagihan" ]]; then
    cek_tagihan
    exit 0
fi

log_activity(){
    waktu=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$waktu] [INFO] $1" >> $LOG
}

tambah_penghuni(){

echo "=== TAMBAH PENGHUNI ==="

read -p "Masukkan Nama: " nama

# kamar
while true
do
    read -p "Masukkan Nomor Kamar: " kamar

    if ! [[ "$kamar" =~ ^[0-9]+$ ]]; then
        echo "Kamar harus angka!"
        continue
    fi

    if grep -q ",$kamar," "$DATA"; then
        echo "Kamar sudah terisi!"
        continue
    fi

    break
done

# harga
while true
do
    read -p "Masukkan Harga Sewa: " harga

    if [[ "$harga" =~ ^[0-9]+$ ]]; then
        break
    else
        echo "Harga harus angka!"
    fi
done

# tanggal
while true
do
    read -p "Masukkan Tanggal Masuk (YYYY-MM-DD): " tanggal

    if ! [[ "$tanggal" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "Format harus YYYY-MM-DD!"
        continue
    fi

    if ! date -d "$tanggal" >/dev/null 2>&1; then
        echo "Tanggal tidak valid!"
        continue
    fi

    today=$(date +%Y-%m-%d)
    if [[ "$tanggal" > "$today" ]]; then
        echo "Tanggal tidak boleh melebihi hari ini!"
        continue
    fi

    break
done

# status
while true
do
    read -p "Status (Aktif/Menunggak): " status

    if [[ "$status" == "Aktif" || "$status" == "Menunggak" ]]; then
        break
    else
        echo "Harus isi: Aktif atau Menunggak!"
    fi
done

# baru simpan setelah semua valid
echo "$nama,$kamar,$harga,$tanggal,$status" >> $DATA

echo "Penghuni berhasil ditambahkan."
log_activity "Menambahkan penghuni $nama kamar $kamar"
}

hapus_penghuni(){

echo "=== HAPUS PENGHUNI ==="
read -p "Masukkan nama penghuni: " nama

if ! grep -q "^$nama," "$DATA"; then
    echo "Penghuni tidak ditemukan!"
    return
fi

tanggal=$(date "+%Y-%m-%d")

grep "$nama" $DATA | awk -v t="$tanggal" 'BEGIN{FS=OFS=","}{print $0,t}' >> $SAMPAH
sed -i "/$nama/d" $DATA

echo "Penghuni $nama dihapus."
log_activity "Menghapus penghuni $nama"
}

tampilkan_penghuni(){

echo "===== DAFTAR PENGHUNI ====="

awk -F',' '
BEGIN{
print "No | Nama | Kamar | Harga | Status"
print "-----------------------------------"
}
{
printf "%d | %s | %s | Rp%s | %s\n", NR,$1,$2,$3,$5
}
END{
print "-----------------------------------"
print "Total:",NR,"penghuni"
}
' $DATA

read -p "Tekan enter untuk kembali"
}

update_status(){

read -p "Masukkan nama penghuni: " nama

if ! grep -q "^$nama," "$DATA"; then
    echo "Penghuni tidak ditemukan!"
    return
fi

while true
do
    read -p "Status baru (Aktif/Menunggak): " status

    if [[ "$status" == "Aktif" || "$status" == "Menunggak" ]]; then
        break
    else
        echo "Harus isi: Aktif atau Menunggak!"
    fi
done

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
print "Total pemasukan (Aktif): Rp"total
print "Total tunggakan: Rp"nunggak
print "Jumlah kamar terisi:",aktif
}
' $DATA | tee $REKAP

echo "[✓] Laporan disimpan di $REKAP"
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

1) crontab -l ;;

2)
read -p "Jam (0-23): " jam
read -p "Menit (0-59): " menit

path_script=$(pwd)/$0
(crontab -l 2>/dev/null; echo "$menit $jam * * * bash $path_script --check-tagihan") | crontab -

echo "Cron berhasil ditambahkan"
;;

3)
crontab -r
echo "Cron dihapus"
;;

4) break ;;

*) echo "Pilihan tidak ada" ;;

esac
done
}

# ===== MAIN MENU =====

while true
do


cat << "EOF"
.-. .-')                 .-')    .-') _           .-')                ('-. .-. .-')    ('-.    (`\ .-') /`
\  ( OO )               ( OO ). (  OO) )         ( OO ).            _(  OO)\  ( OO ) _(  OO)    `.( OO ),
,--. ,--.  .-'),-----. (_)---\_)/     '._       (_)---\_) ,--.     (,------.;-----.\(,------.,--./  .--.  
|  .'   / ( OO'  .-.  '/    _ | |'--...__)      /    _ |  |  |.-')  |  .---'| .-.  | |  .---'|      |  |  
|      /, /   |  | |  |\  :` `. '--.  .--'      \  :` `.  |  | OO ) |  |    | '-' /_)|  |    |  |   |  |, 
|     ' _)\_) |  |\|  | '..`''.)   |  |          '..`''.) |  |`-' |(|  '--. | .-. `.(|  '--. |  |.'.|  |_)
|  .   \    \ |  | |  |.-._)   \   |  |         .-._)   \(|  '---.' |  .--' | |  \  ||  .--' |         |  
|  |\   \    `'  '-'  '\       /   |  |         \       / |      |  |  `---.| '--'  /|  `---.|   ,'.   |  
`--' '--'      `-----'  `-----'    `--'          `-----'  `------'  `------'`------' `------''--'   '--'  
EOF

echo "=============================="
echo "SISTEM MANAJEMEN KOST"
echo "1. Tambah Penghuni"
echo "2. Hapus Penghuni"
echo "3. Tampilkan Daftar Penghuni"
echo "4. Update Status Penghuni"
echo "5. Cetak Laporan Keuangan"
echo "6. Kelola Cron"
echo "7. Exit"
echo "=============================="

read -p "Pilih menu: " menu

case $menu in

1) tambah_penghuni ;;
2) hapus_penghuni ;;
3) tampilkan_penghuni ;;
4) update_status ;;
5) laporan_keuangan ;;
6) menu_cron ;;
7) echo "Keluar..."; exit ;;
*) echo "Menu tidak tersedia" ;;

esac

done
