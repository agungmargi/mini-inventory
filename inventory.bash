#!/bin/bash

#deklarasi warna
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
NOCOLOR="\e[0m"

HEAD="================================"

#insialisasi folder

FOLDER="data"
FILE="data1.txt"

#membuat folder
mkdir -p $FOLDER
#membuat file
touch $FOLDER/$FILE


# valdidasi input tidak boleh kosong
validate_not_empty() {
    local input="$1"
    local field_name="$2"
    if [[ -z "$input" ]]; then
        echo -e "${RED}${field_name} tidak boleh kosong!${NOCOLOR}"
        return 1
    fi
    return 0
}

#validasi input harus angka
validate_number() {
    local input="$1"
    if ! [[ "$input" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Input harus berupa angka!${NOCOLOR}"
        return 1
    fi
        return 0
}


#menampilkan item
load_items() {
    clear
    item=()
    echo -e "${BLUE}Daftar Barang:${NOCOLOR}"
    echo "$HEAD"
    while IFS="|" read -r nama jumlah; do
        nama=$(echo "$nama" | xargs)
        jumlah=$(echo "$jumlah" | xargs)
        item+=("$nama | $jumlah")
        echo "- $nama: $jumlah"
    done < "$FOLDER/$FILE"
    echo "$HEAD"
    read -p "Tekan enter untuk kembali ke menu"

}

#menambahkan item
add_item() {
    clear
    echo $HEAD
    echo -e "${BLUE}          Tambah Barang${NOCOLOR}"
    echo "$HEAD"

    read -p "Masukkan nama barang: " nama
    validate_not_empty "$nama" "Nama barang" || { read -p "Tekan enter untuk kembali"; return; }
    
    read -p "Masukkan jumlah barang: " jumlah
    validate_not_empty "$jumlah" "Jumlah barang" || { read -p "Tekan enter untuk kembali"; return; }
    
    echo "$nama | $jumlah" >> "$FOLDER/$FILE"
    echo "$HEAD"
    echo -e "${GREEN}Barang berhasil ditambahkan${NOCOLOR}"
    echo "$HEAD"
    read -p "Tekan enter untuk kembali ke menu"
}

#menu utama
while true; do
    clear
    echo $HEAD
    echo "Selamat datang di mini inventory"
    echo "$HEAD"
    echo "1. Tambah Barang"
    echo "2. Lihat Barang"
    echo "3. Update Stock Barang"
    echo "4. Hapus Barang"
    echo "5. Keluar"
    echo "$HEAD"
    read -p "Pilih menu: " menu
    case $menu in
        1)
        add_item
        ;;
        2)
        load_items
        ;;
        3)
        update_item
        ;;
        4)
        delete_item
        ;;
        5)
        echo "Terima kasih telah menggunakan mini inventory"
        exit 0
        ;;
        *)
        echo "Menu tidak valid"
        ;;

    esac
done


