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
avg=sum/count
printf "Rata-rata usia penumpang adalah %.0f tahun\n",avg
}' passenger.csv
```
Logika:
sum += $2 → jumlahkan semua usia \
count++ → hitung jumlah penumpang \
avg = sum/count → rata-rata \
%.0f → dibulatkan tanpa desimal 

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
Rata-rata usia penumpang adalah 38 tahun
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
