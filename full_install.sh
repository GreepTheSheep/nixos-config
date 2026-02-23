#!/bin/sh

set -euo pipefail  # Arrêter en cas d'erreur

# Global variables
GIT_REPO_URL="git.greep.fr/greep/nixos-config"
FLAKE_CONFIG=""
DISK=""
PART_BOOT=""
PART_BTRFS=""
SWAP_SIZE=4
ENCRYPT_DISK=false
IS_DISK_SSD=false

abort() {
    echo ""
    echo "Installation interrompue par l'utilisateur"
    exit 1
}
trap abort INT TERM

clear_screen() {
    clear
    print_banner
}

print_banner() {
    cat << 'EOF'
    ███╗   ██╗██╗██╗  ██╗ ██████╗ ███████╗
    ████╗  ██║██║╚██╗██╔╝██╔═══██╗██╔════╝
    ██╔██╗ ██║██║ ╚███╔╝ ██║   ██║███████╗
    ██║╚██╗██║██║ ██╔██╗ ██║   ██║╚════██║
    ██║ ╚████║██║██╔╝ ██╗╚██████╔╝███████║
    ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝
EOF
    echo "Script d'installation NixOS pour Greep, par Greep"
    echo ""
}

require_root() {
    clear_screen

    if [ "$EUID" -ne 0 ]; then
        echo "Ce script doit être exécuté en tant que root (sudo)"
        exit 1
    fi
}

get_git_credentials() {
    clear_screen

    echo "Etape 1 : Identifiants Git"
    echo ""

    echo "La repo git utilisé est: https://${GIT_REPO_URL}"
    read -p "Entrer votre identifiant git: " gitusername
    read -sp "Entrer votre mot de passe git: " gitpassword
}

# ------ Host selection from flake ------
get_hosts_from_flake() {
    local tmpfile="/tmp/nix_flake.txt"

    nix flake show git+https://${gitusername}:${gitpassword}@${GIT_REPO_URL}.git \
        --extra-experimental-features "nix-command flakes" \
        --no-write-lock-file \
        --accept-flake-config > "$tmpfile" 2>&1

    local hosts
    hosts=$(sed 's/\x1b\[[0-9;]*m//g' "$tmpfile" \
        | grep ": NixOS configuration" \
        | sed 's/^[^A-Za-z]*//' \
        | cut -d':' -f1 \
        | sort -u)
    
    rm -f "$tmpfile"

    # Remove liveIso from hosts as it is not a real host
    hosts=$(echo "$hosts" | grep -v "liveIso")

    echo "$hosts"
}

select_host() {
    clear_screen

    echo "Etape 2 : Sélection de l'hôte"
    echo ""
    echo "Chargement en cours..."

    local hosts
    hosts=$(get_hosts_from_flake)

    clear_screen
    echo "Etape 2 : Sélection de l'hôte"
    echo ""

    if [[ -z "$hosts" ]]; then
        echo ""
        echo "/!\ Aucun hôte trouvé dans le fichier flake"
        echo ""
        exit 1
    fi
    
    echo "Sélectionnez l'hôte à installer:"
    select host in $hosts; do
        if [ -n "$host" ]; then
            FLAKE_CONFIG="$host"
            break
        fi
        if [ -z "$host" ]; then
            echo ""
            echo "/!\ Veuillez entrer un hôte valide"
            echo ""
            select_host
            return
        fi
    done

    echo ""
    echo "Hôte sélectionné: $FLAKE_CONFIG"

    sleep 2
}

select_disk() {
    clear_screen

    echo "Etape 3 : Sélection du disque"
    echo ""

    local disks
    disks=$(lsblk -d -o NAME,TYPE | grep disk | awk '{print $1}')

    if [[ -z "$disks" ]]; then
        echo "/!\ Aucun disque trouvé"
        exit 1
    fi

    echo "Disques disponibles:"
    echo ""

    local num=1
    for disk in $disks; do
        local size=$(lsblk -dn -o SIZE "/dev/${disk}")
        local model=$(lsblk -dn -o MODEL "/dev/${disk}" 2>/dev/null | xargs || echo "Unknown")
        
        echo -e "  [${num}] ${disk}"
        echo -e "      Size: ${size}"
        echo -e "      Model: ${model}"
        echo ""
        num=$((num+1))
    done

    select disk in $disks; do
        if [ -n "$disk" ]; then
            DISK="/dev/$disk"
            break
        fi
        if [ -z "$disk" ]; then
            echo ""
            echo "/!\ Veuillez entrer un disque valide"
            echo ""
            select_disk
            return
        fi
    done

    echo ""
    echo "Disque sélectionné: $DISK"

    sleep 2
}

detect_existing_system() {
    clear_screen

    echo "Etape 4 : Détection des partitions existantes"
    echo ""

    # Récupérer les partitions (exclure le disque lui-même)
    local disk_name=$(basename "$DISK")
    local partitions=$(lsblk -ln -o NAME,FSTYPE,LABEL,SIZE "$DISK" | grep -v "^${disk_name} ")

    if [[ -z "$partitions" ]]; then
        echo "Aucune partition existante détectée sur $DISK."
        echo ""
        read -sp "Appuyez sur Entrée pour continuer"
        select_erase_method
        return
    else
        echo "Partitions existantes détectées :"
        echo "$partitions" | while read -r name fstype label size; do
            echo "  - /dev/$name ($size) [FS: ${fstype:-Inconnu}] [Label: ${label:-Aucun}]"
        done

        echo ""
        echo "Que souhaitez-vous faire ?"
        echo "  1) Tout effacer et installer NixOS"
        echo "  2) Choisir une autre partition pour installer à côté"
        echo "  3) Recharger les partitions du disque"
        read -p "Votre choix [1/2/3] : " choice

        if [ "$choice" = "1" ]; then
            select_erase_method
            return
        fi

        if [ "$choice" = "2" ]; then
            echo ""
            echo "/!\ Cette option n'est pas encore implémentée"
            echo ""
            exit 0
        fi

        if [ "$choice" = "3" ]; then
            select_disk
            detect_existing_system
            return
        fi

        if [ "$choice" != "1" ] || [ "$choice" != "2" ] || [ "$choice" != "3" ]; then
            echo ""
            echo "/!\ Veuillez entrer un choix valide"
            echo ""
            sleep 2
            detect_existing_system
            return
        fi
    fi
}

select_erase_method() {
    clear_screen

    echo "Etape 5 : Méthode d'effacement du disque"
    echo ""

    echo "Sélectionnez la méthode d'effacement du disque $DISK:"
    echo "  1) Formater complètement le disque avec shred (lent, plus sécurisé)"
    echo "  2) Effacer les signatures des partitions avec wipefs (rapide, moins sécurisé)"
    echo "  3) Revenir au menu précédent"
    read -p "Votre choix [1/2/3] : " choice

    if [ "$choice" = "1" ]; then
        erase_disk_shred
        return
    fi

    if [ "$choice" = "2" ]; then
        erase_disk_wipefs
        return
    fi

    if [ "$choice" = "3" ]; then
        detect_existing_system
        return
    fi

    if [ "$choice" != "1" ] || [ "$choice" != "2" ] || [ "$choice" != "3" ]; then
        echo ""
        echo "/!\ Veuillez entrer un choix valide"
        echo ""
        sleep 2
        select_erase_method
        return
    fi
}

erase_disk_shred() {
    clear_screen

    echo "Etape 6 : Effacement du disque (shred)"
    echo ""

    echo "/!\ ATTENTION /!\  "
    echo "Cela peut prendre beaucoup de temps"
    echo ""
    read -p "Voulez-vous continuer? (tapez 'OUI' en majuscules): " confirmation
    if [ "$confirmation" != "OUI" ]; then
        echo "Opération annulée"
        select_erase_method
        return
    fi

    clear_screen
    echo "Formatage du disque $DISK avec shred..."
    shred -v -n 3 -z "$DISK"
    sleep 2
    full_partition_disk
}

erase_disk_wipefs() {
    clear_screen
    echo "Etape 6 : Effacement du disque (wipefs)"
    echo ""
    echo "Effacement des signatures des partitions du disque $DISK avec wipefs..."
    wipefs -a "$DISK"
    sleep 2
    full_partition_disk
}


# Partition disk
full_partition_disk() {
    clear_screen

    echo "Etape 7 : Partitionnement du disque"
    echo ""

    # Détecter le type de disque (nvme ou sda)
    if [[ "$DISK" == "/dev/nvme"* ]]; then
        PART_PREFIX="p"
        IS_DISK_SSD=true
    else
        PART_PREFIX=""
        IS_DISK_SSD=false
    fi

    # Définir les noms des partitions
    PART_BOOT="${DISK}${PART_PREFIX}1"
    PART_BTRFS="${DISK}${PART_PREFIX}2"

    # Chiffrement LUKS2 (Désactivé, a configurer plus tard)
    #read -p "Voulez-vous chiffrer le disque en utilisant LUKS2 ? (o/n): " confirmation
    #if [ "$confirmation" == "o" ]; then
    #    ENCRYPT_DISK=true
    #fi
    #if [ "$confirmation" != "o" ] || [ "$confirmation" != "n" ]; then
    #    echo ""
    #    echo "/!\ Veuillez entrer un choix valide"
    #    echo ""
    #    sleep 2
    #    full_partition_disk
    #    return
    #fi

    if [ "$ENCRYPT_DISK" == true ] && [ "$IS_DISK_SSD" == false ]; then
        echo "Le disque dur est détecté comme étant sur l'interface SATA"
        echo ""
        read -p "Est-ce que votre disque est un SSD? (o/n): " confirmation
        if [ "$confirmation" == "o" ]; then
            IS_DISK_SSD=true
        fi
        if [ "$confirmation" != "o" ] || [ "$confirmation" != "n" ]; then
            echo ""
            echo "/!\ Veuillez entrer un choix valide"
            echo ""
            sleep 2
            full_partition_disk
            return
        fi
    fi

    read -p "Donnez la taille du fichier swap en Go: " SWAP_SIZE

    if [ -z "${SWAP_SIZE}" ] || [ "${SWAP_SIZE}" -lt 1 ] || [ "${SWAP_SIZE}" -gt 128 ] || ! [[ "${SWAP_SIZE}" =~ ^[0-9]+$ ]]; then
        echo ""
        echo "/!\ Veuillez entrer une taille de swap valide"
        echo ""
        full_partition_disk
        return
    fi

    echo ""
    echo "Les partitions suivantes seront créées:"
    echo "  1. ${PART_BOOT} - 1024 Mo - FAT32 (boot/EFI)"
    echo "  2. ${PART_BTRFS} - Reste - Btrfs (système)"
    echo ""
    echo "Un fichier swap de ${SWAP_SIZE} Go sera créé dans le système de fichiers Btrfs."
    echo ""
    read -p "Voulez-vous continuer? (tapez 'OUI' en majuscules pour confirmer, autre chose pour revenir en arrière): " confirmation

    if [ "$confirmation" != "OUI" ]; then
        full_partition_disk
        return
    fi
    echo ""

    # Création de la table de partition GPT
    echo "Création de la table de partition GPT..."
    parted -s "$DISK" mklabel gpt

    # Partition 1: Boot (1024 Mo, FAT32)
    echo "Création de la partition boot (1024 Mo)..."
    parted -s "$DISK" mkpart boot fat32 1MiB 1025MiB
    parted -s "$DISK" set 1 esp on

    # Partition 2: Btrfs (tout l'espace restant)
    echo "Création de la partition Btrfs (reste du disque)..."
    parted -s "$DISK" mkpart nixos 1025MiB 100%

    # Recharger la table de partitions
    partprobe "$DISK"
    sleep 2

    # Formater la partition boot en FAT32
    echo "Formatage de la partition boot en FAT32..."
    mkfs.vfat -F32 -n BOOT "${PART_BOOT}" > /dev/null

    local temp_pass="test"
    if [ "$ENCRYPT_DISK" == true ]; then
        # Chiffrement LUKS2
        echo "Configuration du chiffrement LUKS2 sur ${PART_BTRFS} avec un mot de passe temporaire..."
        echo $temp_pass | cryptsetup luksFormat -c aes-xts-plain64 -h sha512 -S 1 -s 512 -i 5000 --use-random --type luks2 --pbkdf argon2id "${PART_BTRFS}" > /dev/null 2>&1

        echo "Ouverture du volume LUKS..."
        if [ "$IS_DISK_SSD" == true ]; then
            echo $temp_pass | cryptsetup open --allow-discards "${PART_BTRFS}" nixos_crypt > /dev/null 2>&1
        fi
        if [ "$IS_DISK_SSD" == false ]; then
            echo $temp_pass | cryptsetup open "${PART_BTRFS}" nixos_crypt > /dev/null 2>&1
        fi

        # Création d'une partition LVM
        echo "Création d'une partition LVM et du groupe de volumes..."
        pvcreate "/dev/mapper/nixos_crypt"
        vgcreate nixos_vg "/dev/mapper/nixos_crypt"

        # Création du swap
        echo "Création des partitions dans le volume LVM..."
        lvcreate -L "${SWAP_SIZE}G" nixos_vg -n swapfile
        lvcreate -l 100%FREE nixos_vg -n root
    fi

    # Création du système de fichiers Btrfs
    echo "Formatage du système de fichiers Btrfs..."
    if [ "$ENCRYPT_DISK" == true ]; then
        mkfs.btrfs -f -L nixos /dev/nixos_vg/root
    else
        mkfs.btrfs -f -L nixos "${PART_BTRFS}" > /dev/null 2>&1
    fi

    if [ "$ENCRYPT_DISK" == true ]; then
        # Création du système de fichiers swap
        echo "Formatage du système de fichiers swap..."
        mkswap /dev/nixos_vg/swapfile
    fi

    echo ""
    echo "Partitionnement terminé avec succès."
    sleep 2
    mount_partitions
}

mount_partitions() {
    clear_screen

    echo "Etape 8 : Montage des partitions"
    echo ""

    if [ "$ENCRYPT_DISK" == true ]; then
        # Monter la partition système (Btrfs dans LUKS)
        local btrfs_options
        if [ "$IS_DISK_SSD" == true ]; then
            btrfs_options="rw,noatime,ssd,compress-force=zstd:2,space_cache=v2,discard=async"
        else
            btrfs_options="rw,noatime,compress-force=zstd:2,space_cache=v2,autodefrag"
        fi

        mount -o $btrfs_options,subvolid=5 /dev/nixos_vg/root /mnt

        # Création des sous-volumes
        btrfs subvolume create /mnt/@
        btrfs subvolume create /mnt/@home

        # Démontage de la partition système
        umount /mnt

        # Montage des sous-volumes
        mount -o $btrfs_options,subvol=@ /dev/nixos_vg/root /mnt
        mkdir -p /mnt/{home,btrfs_pool,boot}
        mount -o $btrfs_options,subvol=@home /dev/nixos_vg/root /mnt/home
        mount -o $btrfs_options,subvolid=5 /dev/nixos_vg/root /mnt/btrfs_pool
        chmod 700 /mnt/btrfs_pool
    else
        # Monter la partition système (Btrfs)
        mount "${PART_BTRFS}" /mnt
        mkdir -p /mnt/{home,boot}

        # Creer le fichier swap
        fallocate -l ${SWAP_SIZE}G /mnt/swapfile
        chmod 600 /mnt/swapfile
        mkswap /mnt/swapfile
    fi

    # Monter la partition boot
    mount "${PART_BOOT}" /mnt/boot

    if [ "$ENCRYPT_DISK" == true ]; then
        # Activer le swap
        swapon /dev/nixos_vg/swapfile
    fi
}

fetch_config() {
    clear_screen

    echo "Etape 9 : Récupération de la configuration NixOS"
    echo ""

    # Récupère la config sur le git + génère la config hardware
    mkdir -p /home/nixos
    cd /home/nixos
    nixos-generate-config --root /mnt > /dev/null 2>&1

    git clone -q "https://${gitusername}:${gitpassword}@${GIT_REPO_URL}" /home/nixos/nixos-config

    rm -drf /home/nixos/nixos-config/.git
    mkdir -p /mnt/etc/nixos
    cp -r /home/nixos/nixos-config/* /mnt/etc/nixos/
    cp -r /home/nixos/nixos-config/.* /mnt/etc/nixos/

    nixos-generate-config --root /mnt > /dev/null 2>&1

    install_nix
}

install_nix() {
    clear_screen

    echo "Etape 10 : Installation de NixOS"
    echo ""

    export NIX_CONFIG="experimental-features = nix-command flakes"
    nixos-install --root /mnt \
        --flake "/mnt/etc/nixos#${FLAKE_CONFIG}" \
        --no-write-lock-file \
        --no-root-passwd \
        --option eval-cache false

    postinstall
}

postinstall() {
    clear_screen

    echo "Etape 11 : Finalisation de l'installation"
    echo ""

    # Config du mot de passe root
    read -sp "Entrer le mot de passe root: " rootpasswd
    echo ""
    { echo $rootpasswd; echo $rootpasswd; } | nixos-enter --silent -c passwd > /dev/null 2>&1

    # Configuration git
    nixos-enter --silent -c "git config --global credential.helper store" > /dev/null 2>&1

    # Sauvegarde Hardware configuration
    nixos-enter --silent -c "cp /etc/nixos/hardware-configuration.nix /root/"

    # Supprime la configuration NixOS
    nixos-enter --silent -c "rm -drf /etc/nixos"

    # Cloner proprement la configuration depuis la repo git
    command="git clone -q https://${gitusername}:${gitpassword}@${GIT_REPO_URL} /home/greep/nixos-config"
    nixos-enter --silent -c "su -c '${command}' greep" > /dev/null 2>&1

    # Lien symbolique de la config
    nixos-enter --silent -c "ln -s /home/greep/nixos-config /etc/nixos"

    # On replace le Hardware configuration sauvegardé dans le dossier de la config
    nixos-enter --silent -c "mv /root/hardware-configuration.nix /home/greep/nixos-config/hosts/${FLAKE_CONFIG}/hardware-configuration.nix"
}

finished() {
    echo ""
    echo "/!\ Installation terminée !"
    echo "Vous pouvez maintenant redémarrer votre poste pour accéder a votre configuration NixOS"
    echo "ou sinon passer en mode chroot avec la commande 'nixos-enter'"
    echo ""

    exit 0
}

main() {
    require_root
    get_git_credentials
    select_host
    select_disk
    detect_existing_system

    fetch_config
    install_nix
    postinstall
    finished
}

main