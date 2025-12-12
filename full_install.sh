#!/bin/sh

set -e  # Arrêter en cas d'erreur

GIT_REPO_URL="git.greep.fr/greep/nixos-config"
FLAKE_CONFIG="pc-matt-nix-vm"

# Vérifier si le script est exécuté en tant que root
if [ "$EUID" -ne 0 ]; then
    echo "Ce script doit être exécuté en tant que root (sudo)"
    exit 1
fi

finished() {
    echo ""
    echo "/!\ Installation terminée !"
    echo "Vous pouvez maintenant redémarrer votre poste pour accéder a votre configuration NixOS"
    echo "ou sinon passer en mode chroot avec la commande 'nixos-enter'"
    echo ""

    exit 0
}

postinstall() {
    # Chroot
    echo ""
    echo "/!\ Finalisation de l'installation"

    # Config du mot de passe root
    read -sp "Entrer le mot de passe root: " rootpasswd
    echo ""
    (echo $rootpasswd; echo $rootpasswd) | nixos-enter --silent -c passwd > /dev/null 2>&1

    # Configuration git
    nixos-enter --silent -c "git config --global credential.helper store" > /dev/null 2>&1
    nixos-enter --silent -c "su -c 'git config --global credential.helper store' greep" > /dev/null 2>&1
    nixos-enter --silent -c "su -c 'git config --global user.email greep@greep.fr' greep" > /dev/null 2>&1
    nixos-enter --silent -c "su -c 'git config --global user.name Matthieu' greep" > /dev/null 2>&1

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
    nixos-enter --silent -c "mv /root/hardware-configuration.nix /home/greep/nixos-config"

    finished
}

install_nix() {
    echo ""
    echo "/!\ Lancement de l'installation NixOS"
    sleep 2
    export NIX_CONFIG="experimental-features = nix-command flakes"
    nixos-install --root /mnt \
        --flake "/mnt/etc/nixos#${FLAKE_CONFIG}" \
        --no-write-lock-file \
        --no-root-passwd \
        --option eval-cache false

    postinstall
}

fetch_config() {
    # Récupère la config sur le git + génère la config hardware
    mkdir -p /home/nixos
    cd /home/nixos
    nixos-generate-config --root /mnt > /dev/null 2>&1

    read -p "Entrer votre identifiant git: " gitusername
    read -sp "Entrer votre mot de passe git: " gitpassword
    echo ""
    git clone -q "https://${gitusername}:${gitpassword}@${GIT_REPO_URL}" /home/nixos/nixos-config

    rm -drf /home/nixos/nixos-config/.git
    cp -r /home/nixos/nixos-config/* /mnt/etc/nixos/
    cp -r /home/nixos/nixos-config/.* /mnt/etc/nixos/

    nixos-generate-config --root /mnt > /dev/null 2>&1

    install_nix
}

mount_partitions() {
    # Monte les partitions nixos et efi boot
    mount $PART_NIXOS /mnt
    mkdir /mnt/boot
    mount $PART_BOOT /mnt/boot

    fetch_config
}

partition_disk() {
    # Détecter le type de disque
    if [ -b "/dev/nvme0n1" ]; then
        DISK="/dev/nvme0n1"
        PART_PREFIX="p"
        echo "Disque NVMe détecté: $DISK"
    elif [ -b "/dev/sda" ]; then
        DISK="/dev/sda"
        PART_PREFIX=""
        echo "Disque SATA détecté: $DISK"
    else
        echo "Erreur: Aucun disque sda ou nvme0n1 trouvé"
        exit 1
    fi

    # Définir les noms des partitions
    PART_BOOT="${DISK}${PART_PREFIX}1"
    PART_SWAP="${DISK}${PART_PREFIX}2"
    PART_NIXOS="${DISK}${PART_PREFIX}3"

    echo ""
    echo "/!\ ATTENTION /!\\"
    echo "Ce script va EFFACER TOUTES LES DONNÉES sur $DISK"
    echo "Les partitions suivantes seront créées:"
    echo "  1. $PART_BOOT  - 300 Mo  - FAT32 (boot)"
    echo "  2. $PART_SWAP  - 4 Go    - Swap"
    echo "  3. $PART_NIXOS - Reste   - Btrfs (nixos)"
    echo ""
    read -p "Voulez-vous continuer? (tapez 'OUI' en majuscules): " confirmation

    if [ "$confirmation" != "OUI" ]; then
        echo "Opération annulée"
        exit 0
    fi
    echo ""

    # Unmount toutes les partitions si montées
    umount ${DISK}* 2>/dev/null || true
    swapoff ${DISK}* 2>/dev/null || true

    # Effacer les signatures existantes
    wipefs -a "$DISK" > /dev/null
    sleep 1

    # Création de la table de partition GPT
    parted -s "$DISK" mklabel gpt

    # Partition 1: Boot (300 Mo, FAT32)
    parted -s "$DISK" mkpart boot fat32 1MiB 301MiB
    parted -s "$DISK" set 1 esp on

    # Partition 2: Swap (4 Go)
    parted -s "$DISK" mkpart swap linux-swap 301MiB 4397MiB

    # Partition 3: NixOS (tout l'espace restant)
    parted -s "$DISK" mkpart nixos btrfs 4397MiB 100%

    # Recharger la table de partitions
    partprobe "$DISK"
    sleep 2

    # Formater la partition boot en FAT32
    mkfs.vfat -F32 -n BOOT "$PART_BOOT" > /dev/null

    # Créer le swap
    mkswap -qL swap "$PART_SWAP" > /dev/null

    # Formater la partition NixOS en Btrfs
    mkfs.btrfs -f -L nixos "$PART_NIXOS" > /dev/null

    mount_partitions
}

partition_disk