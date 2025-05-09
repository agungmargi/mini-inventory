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

#mengupdate item
update_item() {
    clear
    echo -e "${YELLOW}${HEAD}${NOCOLOR}"
    echo -e "${BLUE}       Update Stock Barang${NOCOLOR}"
    echo -e "${YELLOW}${HEAD}${NOCOLOR}"

    read -p "Masukkan nama barang yang ingin diupdate: " nama

    # Cari data barang
    if ! grep -q "^$nama" "$FOLDER/$FILE"; then
        echo -e "${RED}Barang tidak ditemukan!${NOCOLOR}"
        read -p "Tekan enter untuk kembali..."
        return
    fi

    echo -e "${YELLOW}Pilih jenis update:${NOCOLOR}"
    echo "1. Barang Masuk"
    echo "2. Barang Keluar"
    echo "3. Kembali"
    read -p "Pilih opsi: " opsi

    case $opsi in
        1)
            read -p "Masukkan jumlah barang masuk: " tambah
            if ! [[ "$tambah" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}Jumlah harus angka!${NOCOLOR}"
                read -p "Tekan enter untuk kembali..."
                return
            fi
            # Update data
            awk -F'|' -v name="$nama" -v add="$tambah" -v OFS='|' '
            $1 ~ name {
                $2 += add
            } {print $1, $2}
            ' "$FOLDER/$FILE" > tmpfile && mv tmpfile "$FOLDER/$FILE"
            echo -e "${GREEN}Stok berhasil ditambahkan${NOCOLOR}"
            ;;
        2)
            read -p "Masukkan jumlah barang keluar: " kurang
            if ! [[ "$kurang" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}Jumlah harus angka!${NOCOLOR}"
                read -p "Tekan enter untuk kembali..."
                return
            fi
            # Kurangi jika cukup stok
            awk -F'|' -v name="$nama" -v min="$kurang" -v OFS='|' '
            $1 ~ name {
                if ($2 >= min) {
                    $2 -= min
                } else {
                    print "ERROR" > "/dev/stderr"
                    exit 1
                }
            } {print $1, $2}
            ' "$FOLDER/$FILE" > tmpfile
            if [[ $? -eq 0 ]]; then
                mv tmpfile "$FOLDER/$FILE"
                echo -e "${GREEN}Stok berhasil dikurangi${NOCOLOR}"
            else
                echo -e "${RED}Stok tidak cukup!${NOCOLOR}"
                rm -f tmpfile
            fi
            ;;
        3)
            return
            ;;
        *)
            echo -e "${RED}Opsi tidak valid!${NOCOLOR}"
            ;;
    esac

    read -p "Tekan enter untuk kembali..."
}

# menghapus item
delete_item() {
    clear
    echo -e "${YELLOW}${HEAD}${NOCOLOR}"
    echo -e "${BLUE}         Hapus Barang${NOCOLOR}"
    echo -e "${YELLOW}${HEAD}${NOCOLOR}"

    read -p "Masukkan nama barang yang ingin dihapus: " nama

    # Cek apakah barang ada
    if ! grep -q "^$nama" "$FOLDER/$FILE"; then
        echo -e "${RED}Barang tidak ditemukan!${NOCOLOR}"
        read -p "Tekan enter untuk kembali..."
        return
    fi

    # Konfirmasi sebelum menghapus
    read -p "Apakah Anda yakin ingin menghapus '$nama'? (y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        # Filter dan simpan ulang tanpa barang yang dihapus
        grep -v "^$nama" "$FOLDER/$FILE" > tmpfile && mv tmpfile "$FOLDER/$FILE"
        echo -e "${GREEN}Barang '$nama' berhasil dihapus.${NOCOLOR}"
    else
        echo -e "${YELLOW}Penghapusan dibatalkan.${NOCOLOR}"
    fi

    read -p "Tekan enter untuk kembali..."
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


