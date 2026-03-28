# SISOP-1-2026-IT-016
*Practicum Report*
## Soal 1 - ARGO NGAWI JESGEJES
*Author : SCRA / flotch / Oscar*

Tujuan -> Membuat sebuah script KANJ.sh menggunakan awk untuk mengolah data pada file passenger.csv berdasarkan opsi yang diberikan user.

### Step by Step 
(Sebelumnya, kita membuat mkdir soal_1 lalu membuat program dengan nano KANJ.sh dan mendownload wget passenger.csv dalam dir)

#### *Input User*
Program meminta user memilih soal :
```BASH
echo "Pilih soal (a/b/c/d/e):"
read opsi
```
Kemudian menggunakan case untuk menentukan proses berdasarkan input.

#### *a. Menghitung Jumlah Penumpang*
```BASH
awk -F',' 'NR>1 {count++}
END{
print "Jumlah seluruh penumpang KANJ adalah",count,"orang"
}' passenger.csv
```
Logika:
-F',' → delimiter file adalah koma (CSV) \
NR>1 → skip header (baris pertama) \
count++ → hitung jumlah baris (penumpang) \
END → tampilkan hasil

Artinya -> setiap baris data dianggap 1 penumpang.

#### *b. Menghitung Jumlah Gerbong*
```BASH
awk -F',' 'NR>1 {car[$4]=1}
END{
print "Jumlah gerbong penumpang KANJ adalah",length(car)
}' passenger.csv
```
Logika:
$4 → kolom ke-4 (nomor gerbong) \
car[$4]=1 → simpan gerbong unik sebagai key array \
length(car) → jumlah key unik

Jadi tidak menghitung semua data, tapi hanya gerbong yang berbeda.

#### *c. Mencari Penumpang Tertua*
```BASH
awk -F',' 'NR>1{
if($2>max){
max=$2
name=$1
}
}
END{
print name,"adalah penumpang kereta tertua dengan usia",max,"tahun"
}' passenger.csv
```
Logika:
$2 → kolom usia \
Bandingkan dengan max \
Jika lebih besar → update: \
max = usia \
name = nama penumpang

#### *d. Menghitung Rata-rata Usia*
```BASH
awk -F',' 'NR>1{
sum+=$2
count++
}
END{
avg=int(sum/count)
printf "Rata-rata usia penumpang adalah %d tahun\n",avg
}' passenger.csv
```
Logika:
sum += $2 → jumlahkan semua usia \
count++ → hitung jumlah penumpang \
avg = sum/count → rata-rata \
%d → dibulatkan ke bawah

#### *e. Menghitung Penumpang Business Class*
```BASH
awk -F',' 'NR>1 && $3=="Business"{count++}
END{
print "Jumlah penumpang business class ada",count,"orang"
}' passenger.csv
```
Logika:
$3=="Business" → filter hanya kelas Business \
count++ → hitung jumlahnya

#### *Error Handling*
```BASH
*)
echo "Soal tidak dikenali. Gunakan a/b/c/d/e"
```
Jika user memasukkan input selain a–e, program akan menampilkan pesan error.

### Output
Execute file dengan "chmod +x KANJ.sh"

Soal a
```BASH
└─$ ./KANJ.sh
Pilih soal (a/b/c/d/e):
a
Jumlah seluruh penumpang KANJ adalah 208 orang
```

Soal b
```BASH
└─$ ./KANJ.sh
Pilih soal (a/b/c/d/e):
b
Jumlah gerbong penumpang KANJ adalah 4
```

Soal c
```BASH
└─$ ./KANJ.sh
Pilih soal (a/b/c/d/e):
c
Jaja Mihardja adalah penumpang kereta tertua dengan usia 85 tahun
```

Soal d
```BASH
└─$ ./KANJ.sh
Pilih soal (a/b/c/d/e):
d
Rata-rata usia penumpang adalah 37 tahun
```

Soal e
```BASH
└─$ ./KANJ.sh
Pilih soal (a/b/c/d/e):
e
Jumlah penumpang business class ada 74 orang
```

Error Handling
```BASH
└─$ ./KANJ.sh
Pilih soal (a/b/c/d/e):
x
Soal tidak dikenali. Gunakan a/b/c/d/e
```

### Kendala
Tidak ada kendala

## Soal 2 - EKSPEDISI PESUGIHAN GUNUNG KAWI - MAS AMBA
*Author : asisten_kalkuluz*

Tujuan -> Melakukan serangkaian proses pengolahan data menggunakan Bash Script. Proses dimulai dari pengunduhan file, ekstraksi data dari JSON, hingga perhitungan koordinat untuk menentukan lokasi pusat pesugihan.
### Step by Step
(Sebelumnya, kita membuat mkdir soal_2 lalu download pkg tools gdown dalam sh dengan sudo apt install gdown)

#### *1. Download dan Persiapan Data*
Mengunduh file dengan :
```BASH
gdown https://drive.google.com/uc?id=1q10pHSC3KFfvEiCN3V6PTroPR7YGHF6Q
```
Lalu simpan pdf ke dalam folder baru "ekspedisi" :
```BASH
mkdir ekspedisi
mv peta-ekspedisi-amba.pdf ekspedisi/
```
Dan masuk dir ekspedisi.

#### *2. Extract Pdf*
Menggunakan cat kita extract teks dari pdf-nya :
```BASH 
cat peta-ekspedisi-amba.pdf
```
Kita menemukan link git clone di akhir text : https://github.com/pocongcyber77/peta-gunung-kawi.git
```BASH
git clone https://github.com/pocongcyber77/peta-gunung-kawi.git
```
Disini kita masuk ke folder peta-gunung-kawi dan mendapatkan file gsxtrack.json

#### *3. Merapikan Data Koordinat dalam File json*
Sekarang kita membuat sh script dengan nama parserkoordinat.sh yang menggunakan regex untuk mengambil data site_name, latitude(x), longitude(y), dll.
-> Program menggunakan awk dengan delimiter : untuk membaca file JSON baris per baris.

##### 1. Mengambil ID
```BASH
/"id"/ {
    gsub(/[", ]/, "", $2)
    id=$2
}
```
Logika:
Mencari baris yang mengandung "id" \
Menghapus tanda kutip, koma, dan spasi \
Menyimpan ke variabel id

##### 2. Mengambil Nama Lokasi
```BASH
/site_name/ {
    gsub(/[",]/, "", $2)
    site=$2
}
```
Logika:
Mengambil nilai site_name \
Membersihkan karakter tidak perlu \
Disimpan ke variabel site

##### 3. Mengambil Latitude
```BASH
/latitude/ {
    gsub(/[", ]/, "", $2)
    lat=$2
}
```
Logika:
Mengambil nilai latitude \
Disimpan ke variabel lat 

##### 4. Mengambil Longitude & Output
```BASH
/longitude/ {
    gsub(/[", ]/, "", $2)
    lon=$2
    printf "%s,%s,%s,%s\n", id, site, lat, lon
}
' gsxtrack.json > titik-penting.txt
```
Logika:
Mengambil nilai longitude \
Disimpan ke variabel lon \
Cetak id, site, lat, lon \
Hasil output dibuat dan dimasukkan dalam file titik-penting.txt

-> Kita coba "cat titik-penting.txt"
```BASH
└─$ cat titik-penting.txt
node_001, Titik Berak Paman Mas Mba,-7.920000,112.450000
node_002, Basecamp Mas Fuad,-7.920000,112.468100
node_003, Gerbang Dimensi Keputih,-7.937960,112.468100
node_004, Tembok Ratapan Keputih,-7.937960,112.450000
```
Kita bisa melihat map dengan keempat titik koordinat lokasi dalam file gsxtrack.json

#### *4. Mencari Titik Tengah Koordinat*
Lokasi pusaka dicari dengan menemukan titik pusat menggunakan metode titik simetri diagonal (Menggunakan rumus yang diberikan di soal).
Kita membuat code rumus-nya dalam file nemupusaka.txt :
```BASH
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
```
### Output
Execute file dengan "chmod +x nemupusaka.sh" \
Hasil output koordinat akan masuk dalam file posisi-pusaka.txt :
```BASH
└─$ cat posisi-pusaka.txt
Pusat Pusaka: -7.928980, 112.459050
```
### Kendala
Tidak ada kendala

## Soal 3 - KOST SLEBEW AMBATUKAM
*Author : Kenz*

Tujuan -> Membuat sistem manajemen kost berbasis Bash Script yang dapat mengelola data penghuni, status pembayaran, laporan keuangan, serta otomatisasi pengecekan tagihan menggunakan cron.

### Step by Step
(Sebelumnya, kita membuat mkdir soal_3 lalu membuat program dengan nano kost_slebew.sh)

#### *1. Inisialisasi File dan Folder*
Membuat struktur folder otomatis jika belum ada:
```BASH
mkdir -p data log rekap sampah
touch data/penghuni.csv log/tagihan.log rekap/laporan_bulanan.txt sampah/history_hapus.csv
```

#### *2. Tambah Penghuni (Opsi 1)*
```BASH
echo "$nama,$kamar,$harga,$tanggal,$status" >> $DATA
```
Logika:
- Input:
  Nama
  Nomor kamar (harus angka & tidak boleh duplikat)
  Harga sewa (angka)
  Tanggal masuk (format YYYY-MM-DD & valid)
  Status (Aktif/Menunggak)
- Data disimpan dalam format CSV

#### *3. Hapus Penghuni (Opsi 2)*
```BASH
grep "$nama" $DATA | awk -v t="$tanggal" 'BEGIN{FS=OFS=","}{print $0,t}' >> $SAMPAH
sed -i "/$nama/d" $DATA
```
Logika:
- Cari penghuni berdasarkan nama
- Data dipindahkan ke:
  sampah/history_hapus.csv
- Ditambahkan tanggal penghapusan
- Data dihapus dari database utama

#### *4. Tampilkan Penghuni (Opsi 3)*
```BASH
awk -F',' '
{
printf "%d | %s | %s | Rp%s | %s\n", NR,$1,$2,$3,$5
}
' $DATA
```
Logika:
- Menampilkan semua data penghuni dalam bentuk tabel
- Menampilkan:
  Nomor, Nama, Kamar, Harga, Status
- Menghitung total penghuni

#### *5. Update Status & Laporan Keuangan (Opsi 4 & 5)*
```BASH
if($1==n){
$5=s
}
```
Logika:
- Cari penghuni berdasarkan nama
- Ubah status menjadi Aktif atau Menunggak
- File diperbarui menggunakan file sementara

```BASH
if($5=="Aktif"){
total+=$3
}
if($5=="Menunggak"){
nunggak+=$3
}
```
Logika:
- Menghitung:
  Total pemasukan (Aktif)
  Total tunggakan
  Jumlah kamar aktif
- Disimpan ke:
  rekap/laporan_bulanan.txt

#### *6. Sistem Cron Tagihan (Opsi 6)*
```BASH
(crontab -l 2>/dev/null; echo "$menit $jam * * * bash $path_script --check-tagihan") | crontab -
```
Logika:
- Menambahkan cron job untuk menjalankan:
  --check-tagihan
- Program akan:
  Mengecek penghuni Menunggak
  Mencatat ke log/tagihan.log

#### *7. Cek Tagihan (Mode Cron)*
```BASH
if($5=="Menunggak"){
print "[!] Penghuni",$1,"kamar",$2,"menunggak"
}
```
Logika:
- Membaca penghuni.csv
- Jika status Menunggak → dicatat ke log
- Digunakan otomatis oleh cron

#### *8. Exit Program (Opsi 7)*
```BASH
7) echo "Keluar..."; exit ;;
```
Logika:
- Program berhenti dari menu interaktif

### Output

Tambah Penghuni:
```BASH
Masukkan Nama: Budi
Masukkan Nomor Kamar: 2
Masukkan Harga Sewa: 500000
Masukkan Tanggal Masuk: 2026-03-01
Status: Aktif
Penghuni berhasil ditambahkan.
```
Tampilkan Penghuni:
```BASH
No | Nama | Kamar | Harga | Status
1 | Budi | 2 | Rp500000 | Aktif
Total: 1 penghuni
```
Laporan Keuangan:
```BASH
Total pemasukan (Aktif): Rp500000
Total tunggakan: Rp0
Jumlah kamar terisi: 1
```
### Kendala
Tidak ada kendala
