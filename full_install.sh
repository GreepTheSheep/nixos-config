#!/bin/bash

set -euo pipefail  # Arrêter en cas d'erreur

trap 'echo ""; echo "/!\\ Erreur ligne ${LINENO} : ${BASH_COMMAND}" >&2' ERR

# Global variables
GIT_REPO_URL="git.greep.fr/greep/nixos-config"
FLAKE_CONFIG=""
DISK=""
IS_NEW_HOST=false
ALONGSIDE_ESP=""            # Chemin de l'ESP à utiliser (/dev/sdaX ou /dev/nvme...)
ALONGSIDE_BTRFS=""          # Chemin de la nouvelle partition btrfs (ou /dev/mapper/cryptroot si LUKS)
GIT_CRED_FILE=""            # Fichier de credentials git temporaire
USE_LUKS=false
USE_TPM2=false
LUKS_PASSWORD_FILE=""
ALONGSIDE_LUKS_PART=""      # Partition LUKS brute (alongside)

abort() {
    echo ""
    echo "Installation interrompue par l'utilisateur"
    cleanup_git_auth
    cleanup_luks_password
    exit 1
}
trap abort INT TERM

cleanup_git_auth() {
    if [[ -n "${GIT_CRED_FILE:-}" ]]; then
        rm -f "$GIT_CRED_FILE"
        GIT_CRED_FILE=""
    fi
    git config --global --unset credential.helper 2>/dev/null || true
}

cleanup_luks_password() {
    if [[ -n "${LUKS_PASSWORD_FILE:-}" ]]; then
        shred -u "$LUKS_PASSWORD_FILE" 2>/dev/null || rm -f "$LUKS_PASSWORD_FILE"
        LUKS_PASSWORD_FILE=""
    fi
}

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

setup_git_auth() {
    GIT_CRED_FILE=$(mktemp /tmp/.git-creds-XXXXXX)
    chmod 600 "$GIT_CRED_FILE"
    # Stocker les credentials dans un fichier temporaire (non visible dans ps)
    printf 'https://%s:%s@%s\n' "$gitusername" "$gitpassword" "${GIT_REPO_URL%%/*}" > "$GIT_CRED_FILE"
    git config --global credential.helper "store --file ${GIT_CRED_FILE}"
    # Effacer le mot de passe de la mémoire
    unset gitpassword
}

get_git_credentials() {
    clear_screen

    echo "Etape 1 : Identifiants Git"
    echo ""

    echo "La repo git utilisé est: https://${GIT_REPO_URL}"
    read -p "Entrer votre identifiant git: " gitusername
    read -sp "Entrer votre mot de passe git: " gitpassword
    echo ""
    setup_git_auth
}

# ------ Host selection from flake ------
get_hosts_from_flake() {
    local tmpfile="/tmp/nix_flake.txt"

    if ! nix flake show "git+https://${GIT_REPO_URL}.git" \
        --extra-experimental-features "nix-command flakes" \
        --no-write-lock-file \
        --accept-flake-config > "$tmpfile" 2>&1; then
        echo ""
        echo "/!\\ Erreur lors de la récupération du flake :"
        echo ""
        cat "$tmpfile"
        rm -f "$tmpfile"
        return 1
    fi

    local hosts
    hosts=$(sed 's/\x1b\[[0-9;]*m//g' "$tmpfile" \
        | grep ": NixOS configuration" \
        | sed 's/^[^A-Za-z]*//' \
        | cut -d':' -f1 \
        | sort -u || true)

    rm -f "$tmpfile"

    # Remove liveIso from hosts as it is not a real host
    hosts=$(echo "$hosts" | grep -v "liveIso" || true)

    echo "$hosts"
}

get_new_host_name() {
    clear_screen

    echo "Etape 2b : Nom du nouvel hôte"
    echo ""

    while true; do
        read -p "Entrez le nom du nouvel hôte (ex: desktop-greep): " new_host_name

        if [[ -z "$new_host_name" ]]; then
            echo "/!\\ Le nom ne peut pas être vide"
            continue
        fi

        if [[ ! "$new_host_name" =~ ^[a-zA-Z0-9-]+$ ]]; then
            echo "/!\\ Le nom ne peut contenir que des lettres, chiffres et tirets"
            continue
        fi

        break
    done

    FLAKE_CONFIG="$new_host_name"
}

select_host() {
    clear_screen

    echo "Etape 2 : Sélection de l'hôte"
    echo ""
    echo "Chargement en cours..."

    local hosts_raw
    if ! hosts_raw=$(get_hosts_from_flake); then
        exit 1
    fi

    clear_screen
    echo "Etape 2 : Sélection de l'hôte"
    echo ""

    if [[ -z "$hosts_raw" ]]; then
        echo ""
        echo "/!\\ Aucun hôte trouvé dans le fichier flake"
        echo ""
        exit 1
    fi

    local -a host_options
    while IFS= read -r line; do
        host_options+=("$line")
    done <<< "$hosts_raw"
    host_options+=("[ Créer un nouvel hôte ]")

    echo "Sélectionnez l'hôte à installer:"
    select choice in "${host_options[@]}"; do
        if [ -n "$choice" ]; then
            if [ "$choice" = "[ Créer un nouvel hôte ]" ]; then
                get_new_host_name
                IS_NEW_HOST=true
            else
                FLAKE_CONFIG="$choice"
            fi
            break
        fi
        echo ""
        echo "/!\\ Veuillez entrer un hôte valide"
        echo ""
    done

    echo ""
    echo "Hôte sélectionné: $FLAKE_CONFIG"

    sleep 2
}

select_disk() {
    clear_screen

    echo "Etape 4 : Sélection du disque"
    echo ""

    local disks
    disks=$(lsblk -d -o NAME,TYPE | grep disk | awk '{print $1}')

    if [[ -z "$disks" ]]; then
        echo "/!\\ Aucun disque trouvé"
        exit 1
    fi

    echo "Disques disponibles:"
    echo ""

    local num=1
    for disk in $disks; do
        local size=$(lsblk -dn -o SIZE "/dev/${disk}")
        local model=$(lsblk -dn -o MODEL "/dev/${disk}" 2>/dev/null | xargs || echo "Unknown")
        local rota=$(lsblk -dn -o ROTA "/dev/${disk}")
        local nvme=$(lsblk -dn -o NAME "/dev/${disk}" | grep -q "nvme" && echo true || echo false)

        echo -e "  [${num}] ${disk}"
        echo -e "      Size: ${size}"
        echo -e "      Model: ${model}"
        if [ "$rota" -eq 0 ]; then
            if [ "$nvme" = true ]; then
                echo "      Interface: NVMe SSD"
            else
                echo "      Interface: SATA SSD ou SSHD"
            fi
        else
            echo "      Interface: HDD"
        fi
        echo ""
        num=$((num+1))
    done

    while true; do
        select disk in $disks; do
            if [ -n "$disk" ]; then
                DISK="/dev/$disk"
                break 2
            fi
            echo ""
            echo "/!\\ Veuillez entrer un disque valide"
            echo ""
            break
        done
    done

    echo ""
    echo "Disque sélectionné: $DISK"

    sleep 2
}

select_luks() {
    clear_screen

    echo "Etape 5 : Chiffrement LUKS"
    echo ""
    echo "LUKS (Linux Unified Key Setup) permet de chiffrer intégralement la partition"
    echo "NixOS. Les données seront illisibles sans le mot de passe au démarrage."
    echo ""
    read -p "Activer le chiffrement LUKS ? [o/N] : " luks_choice

    case "${luks_choice,,}" in
        o|oui|y|yes)
            ;;
        *)
            echo ""
            echo "Chiffrement LUKS désactivé."
            sleep 1
            return
            ;;
    esac

    local pass1 pass2
    while true; do
        read -sp "Mot de passe LUKS : " pass1
        echo ""
        read -sp "Confirmer le mot de passe LUKS : " pass2
        echo ""
        if [[ "$pass1" != "$pass2" ]]; then
            echo "/!\\ Les mots de passe ne correspondent pas. Réessayez."
            continue
        fi
        if [[ -z "$pass1" ]]; then
            echo "/!\\ Le mot de passe ne peut pas être vide."
            continue
        fi
        break
    done

    LUKS_PASSWORD_FILE=$(mktemp /tmp/.luks-XXXXXX)
    chmod 600 "$LUKS_PASSWORD_FILE"
    printf '%s' "$pass1" > "$LUKS_PASSWORD_FILE"
    unset pass1 pass2

    # Copie dans /tmp/luks-password pour disko
    cp "$LUKS_PASSWORD_FILE" /tmp/luks-password
    chmod 600 /tmp/luks-password

    USE_LUKS=true
    echo ""
    echo "Chiffrement LUKS activé."

    # Proposer TPM2 si disponible
    if [[ -e /dev/tpm0 ]] || [[ -e /dev/tpmrm0 ]]; then
        echo ""
        echo "Puce TPM2 détectée."
        echo "Le TPM2 permet de déverrouiller LUKS automatiquement au démarrage,"
        echo "lié à l'état du firmware (PCR 0+7 / Secure Boot)."
        echo ""
        read -p "Enrôler le TPM2 pour déverrouillage automatique ? [o/N] : " tpm_choice
        case "${tpm_choice,,}" in
            o|oui|y|yes)
                USE_TPM2=true
                echo "TPM2 sera enrôlé après le partitionnement."
                ;;
            *)
                echo "TPM2 désactivé — déverrouillage par mot de passe uniquement."
                ;;
        esac
    fi

    sleep 1
}

enroll_tpm2() {
    local luks_part="$1"
    echo "  Enrôlement TPM2 sur $luks_part (PCR 0+7)..."
    systemd-cryptenroll \
        --tpm2-device=auto \
        --tpm2-pcrs=0+7 \
        --unlock-key-file="$LUKS_PASSWORD_FILE" \
        "$luks_part"
    echo "  TPM2 enrôlé avec succès."
}

update_mount_uuids() {
    local mount_nix="/tmp/nixos-config/hosts/${FLAKE_CONFIG}/mount.nix"

    [[ ! -f "$mount_nix" ]] && return

    echo "  Mise à jour des UUIDs dans mount.nix..."

    local new_btrfs_uuid new_esp_uuid
    new_btrfs_uuid=$(blkid -s UUID -o value "$(findmnt -n -o SOURCE /mnt | sed 's/\[.*//')" 2>/dev/null || true)
    new_esp_uuid=$(blkid -s UUID -o value "$(findmnt -n -o SOURCE /mnt/boot | sed 's/\[.*//')" 2>/dev/null || true)

    if [[ -z "$new_btrfs_uuid" ]] || [[ -z "$new_esp_uuid" ]]; then
        echo "  /!\\ Impossible de lire les UUIDs depuis /mnt"
        return
    fi

    # UUID btrfs : format lowercase xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    local old_btrfs_uuid
    old_btrfs_uuid=$(grep -oP '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' "$mount_nix" | head -1 || true)
    if [[ -n "$old_btrfs_uuid" ]] && [[ "$old_btrfs_uuid" != "$new_btrfs_uuid" ]]; then
        sed -i "s/${old_btrfs_uuid}/${new_btrfs_uuid}/g" "$mount_nix"
        echo "  UUID btrfs : $old_btrfs_uuid → $new_btrfs_uuid"
    fi

    # UUID ESP : format uppercase XXXX-XXXX
    local old_esp_uuid
    old_esp_uuid=$(grep -oP '[0-9A-F]{4}-[0-9A-F]{4}' "$mount_nix" | head -1 || true)
    if [[ -n "$old_esp_uuid" ]] && [[ "$old_esp_uuid" != "$new_esp_uuid" ]]; then
        sed -i "s/${old_esp_uuid}/${new_esp_uuid}/g" "$mount_nix"
        echo "  UUID ESP : $old_esp_uuid → $new_esp_uuid"
    fi

    # UUID LUKS (si activé)
    if [[ "$USE_LUKS" = true ]]; then
        local luks_device new_luks_uuid
        luks_device=$(cryptsetup status cryptroot 2>/dev/null | awk '/device:/{print $2}' || true)
        if [[ -n "$luks_device" ]]; then
            new_luks_uuid=$(blkid -s UUID -o value "$luks_device" || true)
            if [[ -n "$new_luks_uuid" ]]; then
                if grep -q 'boot.initrd.luks.devices' "$mount_nix"; then
                    # Remplacer l'ancien UUID LUKS
                    local old_luks_uuid
                    old_luks_uuid=$(grep -A2 'boot.initrd.luks.devices' "$mount_nix" \
                        | grep -oP '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' \
                        | head -1 || true)
                    if [[ -n "$old_luks_uuid" ]] && [[ "$old_luks_uuid" != "$new_luks_uuid" ]]; then
                        sed -i "s/${old_luks_uuid}/${new_luks_uuid}/g" "$mount_nix"
                        echo "  UUID LUKS : $old_luks_uuid → $new_luks_uuid"
                    fi
                else
                    # Insérer le bloc LUKS avant la dernière }
                    awk -v uuid="$new_luks_uuid" '
                        /^}$/ && !inserted {
                            print ""
                            print "  boot.initrd.luks.devices.\"cryptroot\" = {"
                            print "    device = \"/dev/disk/by-uuid/" uuid "\";"
                            print "    allowDiscards = true;"
                            print "  };"
                            inserted = 1
                        }
                        { print }
                    ' "$mount_nix" > "${mount_nix}.tmp" && mv "${mount_nix}.tmp" "$mount_nix"
                    echo "  Bloc LUKS inséré dans mount.nix (UUID: $new_luks_uuid)"
                fi

                # boot.initrd.systemd.enable requis pour systemd-cryptenroll/TPM2
                if [[ "$USE_TPM2" = true ]]; then
                    if ! grep -q 'boot.initrd.systemd.enable' "$mount_nix"; then
                        awk '/^}$/ && !inserted {
                            print "  boot.initrd.systemd.enable = true;"
                            inserted = 1
                        }
                        { print }
                        ' "$mount_nix" > "${mount_nix}.tmp" && mv "${mount_nix}.tmp" "$mount_nix"
                        echo "  boot.initrd.systemd.enable ajouté dans mount.nix"
                    fi
                fi
            fi
        fi
    fi
}

detect_existing_os() {
    echo "  Détection des systèmes d'exploitation existants..."
    echo ""

    local found=false

    if command -v os-prober &>/dev/null; then
        local prober_out
        prober_out=$(os-prober 2>/dev/null || true)
        if [[ -n "$prober_out" ]]; then
            echo "  Systèmes détectés (os-prober) :"
            while IFS='|' read -r part label short type; do
                [[ -z "$part" ]] && continue
                echo "    - ${short:-$label} sur $part (type : ${type:-inconnu})"
                found=true
            done <<< "$prober_out"
        fi
    fi

    if [[ "$found" = false ]]; then
        echo "  Systèmes détectés (lsblk) :"
        local disk_name
        disk_name=$(basename "$DISK")
        while IFS= read -r line; do
            local name fstype
            name=$(echo "$line" | awk '{print $1}')
            fstype=$(echo "$line" | awk '{print $2}')
            case "$fstype" in
                ntfs|ntfs-3g)        echo "    - Windows probable sur /dev/$name (NTFS)" ; found=true ;;
                ext4|ext3|btrfs|xfs) echo "    - Linux probable sur /dev/$name ($fstype)" ; found=true ;;
            esac
        done < <(lsblk -lno NAME,FSTYPE "$DISK" 2>/dev/null | grep -v "^${disk_name} " || true)

        if [[ "$found" = false ]]; then
            echo "    Aucun système d'exploitation détecté"
        fi
    fi
}

detect_existing_esp() {
    local esp_part=""

    # Méthode 1 : via PARTTYPE GUID EFI
    esp_part=$(lsblk -o NAME,PARTTYPE "$DISK" -ln 2>/dev/null \
        | grep -i "c12a7328-f81f-11d2-ba4b-00a0c93ec93b" \
        | awk '{print "/dev/" $1}' | head -1 || true)

    # Méthode 2 : via fdisk
    if [[ -z "$esp_part" ]]; then
        esp_part=$(fdisk -l "$DISK" 2>/dev/null \
            | grep -i "EFI System" \
            | awk '{print $1}' | head -1 || true)
    fi

    if [[ -n "$esp_part" ]]; then
        ALONGSIDE_ESP="$esp_part"
        echo "  ESP existante trouvée : $ALONGSIDE_ESP"
    else
        echo "  Aucune ESP existante. Une partition EFI de 1 GiB sera créée."
        ALONGSIDE_ESP="CREATE"
    fi
}

create_alongside_partition() {
    local start="$1"
    local end="$2"

    echo ""
    echo "  Création de la partition NixOS sur $DISK (${start}GiB → ${end}GiB)..."
    parted -s "$DISK" mkpart nixos btrfs "${start}GiB" "${end}GiB"
    partprobe "$DISK"
    sleep 2

    ALONGSIDE_BTRFS="/dev/$(lsblk -lno NAME "$DISK" | tail -1)"
    echo "  Nouvelle partition btrfs : $ALONGSIDE_BTRFS"
}

mount_alongside() {
    local opts="compress-force=zstd:2,noatime,space_cache=v2"

    echo ""
    echo "  Montage des sous-volumes btrfs..."
    mount -o "${opts},subvol=@" "$ALONGSIDE_BTRFS" /mnt
    mkdir -p /mnt/home /mnt/boot
    mount -o "${opts},subvol=@home" "$ALONGSIDE_BTRFS" /mnt/home
    mount "$ALONGSIDE_ESP" /mnt/boot
    echo "  /mnt est prêt."
}

install_alongside() {
    clear_screen

    echo "Etape 6b : Installation à côté d'un OS existant"
    echo ""

    # 1. Détecter l'ESP existante
    detect_existing_esp
    echo ""

    # 2. Afficher l'espace libre
    echo "  Espace libre sur $DISK :"
    local free_output
    free_output=$(LC_ALL=C parted -s "$DISK" unit GiB print free 2>/dev/null \
        | grep "Free Space" || true)

    if [[ -z "$free_output" ]]; then
        echo ""
        echo "  /!\\ Aucun espace libre disponible sur $DISK."
        echo "  Libérez de l'espace avant de continuer."
        echo ""
        read -sp "Appuyez sur Entrée pour revenir au menu"
        detect_existing_system
        return
    fi

    local max_size_int=0
    local best_start=""
    local region_num=0
    while IFS= read -r line; do
        region_num=$((region_num + 1))
        local start size
        start=$(echo "$line" | awk '{v=$1; gsub(/GiB/,"",v); print v}')
        local end_r
        end_r=$(echo "$line" | awk '{v=$2; gsub(/GiB/,"",v); print v}')
        size=$(echo "$line" | awk '{v=$3; gsub(/GiB/,"",v); print v}')
        local size_int
        size_int=$(awk "BEGIN{printf \"%d\", $size}")
        echo "    Région $region_num : ${start} GiB → ${end_r} GiB (environ ${size_int} GiB libres)"
        if [[ "$size_int" -gt "$max_size_int" ]]; then
            max_size_int="$size_int"
            best_start="$start"
        fi
    done <<< "$free_output"

    echo ""

    # Réserver 1 GiB pour ESP si besoin
    local esp_reserve=0
    if [[ "$ALONGSIDE_ESP" = "CREATE" ]]; then
        esp_reserve=1
        echo "  Note : 1 GiB réservé pour la nouvelle ESP."
        echo ""
    fi

    local available=$((max_size_int - esp_reserve))
    if [[ "$available" -lt 1 ]]; then
        echo "  /!\\ Espace disponible insuffisant (${available} GiB)."
        echo ""
        read -sp "Appuyez sur Entrée pour revenir au menu"
        detect_existing_system
        return
    fi

    # 3. Demander la taille
    local size_gib
    while true; do
        read -p "  Taille pour NixOS en GiB (max ~${available} GiB) : " size_gib
        if [[ ! "$size_gib" =~ ^[0-9]+$ ]] || [[ "$size_gib" -lt 1 ]]; then
            echo "  /!\\ Entrez un entier positif."
            continue
        fi
        if [[ "$size_gib" -gt "$available" ]]; then
            echo "  /!\\ Dépasse l'espace disponible (${available} GiB)."
            continue
        fi
        break
    done

    # 3b. Demander la taille du swap
    local swap_mib
    while true; do
        read -p "  Taille du swap en MiB (0 pour désactiver) : " swap_mib
        if [[ ! "$swap_mib" =~ ^[0-9]+$ ]]; then
            echo "  /!\\ Entrez un entier positif ou 0."
            continue
        fi
        break
    done

    # 4. Créer ESP si nécessaire
    local part_start="$best_start"
    if [[ "$ALONGSIDE_ESP" = "CREATE" ]]; then
        local esp_end
        esp_end=$(awk "BEGIN{printf \"%.2f\", $part_start + 1}")
        echo ""
        echo "  Création de la partition EFI (${part_start}GiB → ${esp_end}GiB)..."
        parted -s "$DISK" mkpart esp fat32 "${part_start}GiB" "${esp_end}GiB"
        local esp_num
        esp_num=$(parted -s "$DISK" print 2>/dev/null | awk '/^ *[0-9]/{last=$1} END{print last}')
        parted -s "$DISK" set "$esp_num" esp on
        partprobe "$DISK"
        sleep 1
        local esp_dev
        esp_dev="/dev/$(lsblk -lno NAME "$DISK" | tail -1)"
        mkfs.fat -F32 -n ESP "$esp_dev"
        ALONGSIDE_ESP="$esp_dev"
        echo "  ESP créée : $ALONGSIDE_ESP"
        part_start="$esp_end"
    fi

    # 5. Créer la partition btrfs
    local part_end
    part_end=$(awk "BEGIN{printf \"%.2f\", $part_start + $size_gib}")
    create_alongside_partition "$part_start" "$part_end"

    # 6. Formater btrfs + sous-volumes (avec ou sans LUKS)
    echo ""
    if [[ "$USE_LUKS" = true ]]; then
        echo "  Chiffrement LUKS de $ALONGSIDE_BTRFS..."
        cryptsetup luksFormat --batch-mode "$ALONGSIDE_BTRFS" --key-file "$LUKS_PASSWORD_FILE"
        echo "  Ouverture du container LUKS..."
        cryptsetup luksOpen "$ALONGSIDE_BTRFS" cryptroot --key-file "$LUKS_PASSWORD_FILE"
        ALONGSIDE_LUKS_PART="$ALONGSIDE_BTRFS"
        ALONGSIDE_BTRFS="/dev/mapper/cryptroot"
        echo "  Container LUKS ouvert : $ALONGSIDE_BTRFS"
    fi

    echo "  Formatage de $ALONGSIDE_BTRFS en btrfs..."
    mkfs.btrfs -L nixos -f "$ALONGSIDE_BTRFS"

    echo "  Création des sous-volumes..."
    mount "$ALONGSIDE_BTRFS" /mnt
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    umount /mnt

    # 7. Monter
    mount_alongside

    # 8. Mettre à jour mount.nix avec les vrais UUIDs
    if [[ "$IS_NEW_HOST" = true ]]; then
        local btrfs_uuid esp_uuid
        btrfs_uuid=$(blkid -s UUID -o value "$ALONGSIDE_BTRFS")
        esp_uuid=$(blkid -s UUID -o value "$ALONGSIDE_ESP")

        local swap_block=""
        if [[ "$swap_mib" -gt 0 ]]; then
            swap_block="  swapDevices = [
    {
      device = \"/swapfile\";
      size = ${swap_mib};
      priority = 10;
    }
  ];

  # Hibernation — après install, récupérer l'offset avec:
  # sudo btrfs inspect-internal map-swapfile -r /swapfile
  boot.resumeDevice = \"/dev/disk/by-uuid/${btrfs_uuid}\";
  boot.kernelParams = [ \"resume_offset=XXXXXXXX\" ];"
        else
            swap_block="  swapDevices = [];"
        fi

        local luks_block=""
        if [[ "$USE_LUKS" = true ]]; then
            local luks_uuid
            luks_uuid=$(blkid -s UUID -o value "$ALONGSIDE_LUKS_PART")
            luks_block="
  boot.initrd.luks.devices.\"cryptroot\" = {
    device = \"/dev/disk/by-uuid/${luks_uuid}\";
    allowDiscards = true;
  };"
            if [[ "$USE_TPM2" = true ]]; then
                luks_block="${luks_block}

  boot.initrd.systemd.enable = true;"
            fi
        fi

        cat > "/tmp/nixos-config/hosts/${FLAKE_CONFIG}/mount.nix" << EOF
_:

{
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/${btrfs_uuid}";
      fsType = "btrfs";
      options = [ "subvol=@" "compress-force=zstd:2" "noatime" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/${btrfs_uuid}";
      fsType = "btrfs";
      options = [ "subvol=@home" "compress-force=zstd:2" "noatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/${esp_uuid}";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

${swap_block}
${luks_block}

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };
}
EOF
        echo "  mount.nix généré avec les UUIDs réels."
    else
        update_mount_uuids
    fi

    # Enrôlement TPM2 pendant que le container est encore ouvert et le mot de passe disponible
    if [[ "$USE_LUKS" = true ]] && [[ "$USE_TPM2" = true ]] && [[ -n "$ALONGSIDE_LUKS_PART" ]]; then
        enroll_tpm2 "$ALONGSIDE_LUKS_PART"
    fi
    cleanup_luks_password

    echo ""
    echo "  Installation à côté configurée."
    sleep 2
}

detect_existing_system() {
    clear_screen

    echo "Etape 6 : Détection des partitions existantes"
    echo ""

    local disk_name partitions

    while true; do
        disk_name=$(basename "$DISK")
        partitions=$(lsblk -ln -o NAME,FSTYPE,LABEL,SIZE "$DISK" | grep -v "^${disk_name} " || true)

        if [[ -z "$partitions" ]]; then
            echo "Aucune partition existante détectée sur $DISK."
            echo ""
            read -sp "Appuyez sur Entrée pour continuer"
            run_disko
            return
        fi

        echo "Partitions existantes détectées :"
        echo "$partitions" | while read -r name fstype label size; do
            echo "  - /dev/$name ($size) [FS: ${fstype:-Inconnu}] [Label: ${label:-Aucun}]"
        done

        echo ""
        detect_existing_os
        echo ""
        echo "(Note : Les entrées bootloader pour l'autre OS devront être ajoutées manuellement dans bootloader.nix)"
        echo ""
        echo "Que souhaitez-vous faire ?"
        echo "  1) Tout effacer et installer NixOS"
        echo "  2) Choisir une autre partition pour installer à côté"
        echo "  3) Recharger les partitions du disque"
        read -p "Votre choix [1/2/3] : " choice

        case "$choice" in
            1) select_erase_method ; return ;;
            2) install_alongside   ; return ;;
            3) select_disk ;;
            *)
                echo ""
                echo "/!\\ Veuillez entrer un choix valide"
                echo ""
                sleep 2
                ;;
        esac
    done
}

select_erase_method() {
    while true; do
        clear_screen

        echo "Etape 6c : Méthode d'effacement du disque"
        echo ""

        echo "Sélectionnez la méthode d'effacement du disque $DISK:"
        echo "  1) Formater complètement le disque avec shred (lent, plus sécurisé)"
        echo "  2) Effacer les signatures des partitions avec wipefs (rapide, moins sécurisé)"
        echo "  3) Revenir au menu précédent"
        read -p "Votre choix [1/2/3] : " choice

        case "$choice" in
            1) erase_disk_shred  ; return ;;
            2) erase_disk_wipefs ; return ;;
            3) detect_existing_system ; return ;;
            *)
                echo ""
                echo "/!\\ Veuillez entrer un choix valide"
                echo ""
                sleep 2
                ;;
        esac
    done
}

erase_disk_shred() {
    clear_screen

    echo "Etape 7 : Effacement du disque (shred)"
    echo ""

    echo "/!\\ ATTENTION /!\\  "
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
    run_disko
}

erase_disk_wipefs() {
    clear_screen
    echo "Etape 7 : Effacement du disque (wipefs)"
    echo ""
    echo "Effacement des signatures des partitions du disque $DISK avec wipefs..."
    wipefs -a "$DISK"
    sleep 2
    run_disko
}


partition_and_setup_luks() {
    # Partitionnement entièrement manuel quand LUKS est actif :
    # nix run disko télécharge cryptsetup dont tpm2-tss est une dépendance
    # dans nixpkgs (même sans TPM matériel), ce qui plante les VMs à faible RAM.
    echo "  Partitionnement manuel de $DISK..."
    wipefs -a "$DISK"
    parted -s "$DISK" mklabel gpt
    parted -s "$DISK" mkpart ESP fat32 1MiB 1GiB
    parted -s "$DISK" set 1 esp on
    parted -s "$DISK" mkpart root 1GiB 100%
    partprobe "$DISK"
    sleep 2

    local esp_part root_part
    esp_part="/dev/$(lsblk -lno NAME "$DISK" | grep -v "^$(basename "$DISK")$" | head -1 || true)"
    root_part="/dev/$(lsblk -lno NAME "$DISK" | grep -v "^$(basename "$DISK")$" | tail -1 || true)"

    echo "  Formatage ESP : $esp_part"
    mkfs.fat -F32 -n ESP "$esp_part"

    echo "  Chiffrement LUKS de $root_part..."
    cryptsetup luksFormat --batch-mode "$root_part" --key-file "$LUKS_PASSWORD_FILE"
    echo "  Ouverture du container LUKS..."
    cryptsetup luksOpen "$root_part" cryptroot --key-file "$LUKS_PASSWORD_FILE"

    echo "  Formatage btrfs..."
    mkfs.btrfs -L nixos -f /dev/mapper/cryptroot

    echo "  Création des sous-volumes..."
    mount /dev/mapper/cryptroot /mnt
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    umount /mnt

    echo "  Montage..."
    local opts="compress-force=zstd:2,noatime,space_cache=v2"
    mount -o "${opts},subvol=@" /dev/mapper/cryptroot /mnt
    mkdir -p /mnt/home /mnt/boot
    mount -o "${opts},subvol=@home" /dev/mapper/cryptroot /mnt/home
    mount "$esp_part" /mnt/boot

    if [[ "$USE_TPM2" = true ]]; then
        enroll_tpm2 "$root_part"
    fi
}

run_disko() {
    clear_screen

    echo "Etape 8 : Partitionnement avec Disko"
    echo ""

    # Quand LUKS est actif, on court-circuite disko entièrement :
    # disko télécharge cryptsetup dont tpm2-tss est une dépendance
    # dans nixpkgs même sans TPM, ce qui plante les VMs à faible RAM.
    if [[ "$USE_LUKS" = true ]]; then
        partition_and_setup_luks
        cleanup_luks_password
        echo ""
        echo "Partitionnement et montage terminés."
        update_mount_uuids
        sleep 2
        return
    fi

    local disko_config="/tmp/nixos-config/hosts/${FLAKE_CONFIG}/disko.nix"

    if [[ ! -f "$disko_config" ]]; then
        echo "/!\\ Fichier disko.nix introuvable pour l'hôte ${FLAKE_CONFIG}"
        echo "    Chemin attendu: $disko_config"
        exit 1
    fi

    export NIX_CONFIG="experimental-features = nix-command flakes"
    nix run github:nix-community/disko -- \
        --mode disko \
        --argstr disk "${DISK}" \
        "$disko_config"

    echo ""
    echo "Partitionnement et montage terminés."
    update_mount_uuids
    sleep 2
}

fetch_config_tmp() {
    clear_screen

    echo "Etape 3 : Récupération de la configuration NixOS"
    echo ""

    echo "Clonage du dépôt dans /tmp/nixos-config..."
    rm -rf /tmp/nixos-config
    git clone -q "https://${GIT_REPO_URL}" /tmp/nixos-config
    rm -rf /tmp/nixos-config/.git

    echo "Configuration récupérée."
    sleep 1
}

copy_config_to_mnt() {
    clear_screen

    echo "Etape 9 : Copie de la configuration vers /mnt"
    echo ""

    mkdir -p /mnt/etc/nixos
    # Copie tout le contenu (fichiers visibles et cachés) sans inclure . ni ..
    cp -r /tmp/nixos-config/. /mnt/etc/nixos/
}

install_nix() {
    clear_screen

    echo "Etape 10 : Installation de NixOS"
    echo ""

    nixos-generate-config --root /mnt

    export NIX_CONFIG="experimental-features = nix-command flakes"
    nixos-install --root /mnt \
        --flake "/mnt/etc/nixos#${FLAKE_CONFIG}" \
        --no-write-lock-file \
        --no-root-passwd \
        --impure \
        --keep-going \
        --option eval-cache false
}

postinstall() {
    clear_screen

    echo "Etape 11 : Finalisation de l'installation"
    echo ""

    # Config du mot de passe root
    read -sp "Entrer le mot de passe root: " rootpasswd
    echo ""
    printf '%s\n%s\n' "$rootpasswd" "$rootpasswd" | nixos-enter --silent -c passwd > /dev/null 2>&1
    unset rootpasswd

    # Configuration git
    nixos-enter --silent -c "git config --global credential.helper store" > /dev/null 2>&1

    # Sauvegarde Hardware configuration
    nixos-enter --silent -c "cp /etc/nixos/hardware-configuration.nix /root/"

    # Supprime la configuration NixOS
    nixos-enter --silent -c "rm -drf /etc/nixos"

    # Copier les credentials dans le chroot pour le clone greep
    local home_git_creds="/mnt/home/greep/.git-credentials"
    cp "$GIT_CRED_FILE" "$home_git_creds"
    nixos-enter --silent -c \
        "chown greep:users /home/greep/.git-credentials 2>/dev/null || chown greep /home/greep/.git-credentials; chmod 600 /home/greep/.git-credentials"

    # Cloner proprement la configuration depuis la repo git
    nixos-enter --silent -c \
        "su -c 'git config --global credential.helper store && git clone -q https://${GIT_REPO_URL} /home/greep/nixos-config' greep" \
        > /dev/null 2>&1

    # Nettoyer les credentials du chroot
    nixos-enter --silent -c "rm -f /home/greep/.git-credentials"
    nixos-enter --silent -c "su -c 'git config --global --unset credential.helper || true' greep" > /dev/null 2>&1
    rm -f "$home_git_creds"

    # Lien symbolique de la config
    nixos-enter --silent -c "ln -s /home/greep/nixos-config /etc/nixos"

    # On replace le Hardware configuration sauvegardé dans le dossier de la config
    nixos-enter --silent -c "mv /root/hardware-configuration.nix /home/greep/nixos-config/hosts/${FLAKE_CONFIG}/hardware-configuration.nix"
}

finished() {
    clear_screen
    echo "/!\\ Installation terminée !"
    echo "Vous pouvez maintenant redémarrer votre poste pour accéder a votre configuration NixOS"
    echo "ou sinon passer en mode chroot avec la commande 'nixos-enter'"
    echo ""
    cleanup_git_auth
    cleanup_luks_password
    exit 0
}

create_host_files() {
    clear_screen

    echo "Etape 3b : Création du répertoire du nouvel hôte"
    echo ""

    local -a template_hosts
    for dir in /tmp/nixos-config/hosts/*/; do
        local dname
        dname=$(basename "$dir")
        if [ -d "$dir" ] && [[ "$dname" != *.nix ]]; then
            template_hosts+=("$dname")
        fi
    done

    if [ ${#template_hosts[@]} -eq 0 ]; then
        echo "/!\\ Aucun hôte existant trouvé pour servir de modèle"
        exit 1
    fi

    echo "Choisissez un hôte existant comme modèle:"
    select template in "${template_hosts[@]}"; do
        if [ -n "$template" ]; then
            break
        fi
        echo "/!\\ Veuillez entrer un choix valide"
    done

    echo ""
    echo "Création du répertoire hosts/${FLAKE_CONFIG}/..."
    cp -r "/tmp/nixos-config/hosts/${template}" "/tmp/nixos-config/hosts/${FLAKE_CONFIG}"
    rm -f "/tmp/nixos-config/hosts/${FLAKE_CONFIG}/hardware-configuration.nix"

    echo "Ajout de '${FLAKE_CONFIG}' dans flake.nix..."
    # Insère le nouvel hôte avant "liveIso" (plus robuste que sed avec \n)
    awk -v host="$FLAKE_CONFIG" '
        !done && /^\s*"liveIso"\s*$/ {
            line = $0
            sub(/"liveIso"/, "\"" host "\"", line)
            print line
            done = 1
        }
        { print }
    ' /tmp/nixos-config/flake.nix > /tmp/nixos-config/flake.nix.tmp \
        && mv /tmp/nixos-config/flake.nix.tmp /tmp/nixos-config/flake.nix

    echo ""
    echo "Hôte '${FLAKE_CONFIG}' créé depuis le modèle '${template}'."
    echo "Pensez à adapter les fichiers dans /tmp/nixos-config/hosts/${FLAKE_CONFIG}/ avant l'installation."
    echo "(Ce dossier sera copié vers /mnt/etc/nixos/ après le partitionnement)"
    echo ""
    read -sp "Appuyez sur Entrée pour continuer"
}

main() {
    require_root
    get_git_credentials
    select_host
    fetch_config_tmp
    if [ "$IS_NEW_HOST" = true ]; then
        create_host_files
    fi
    select_disk
    select_luks             # ← choix LUKS optionnel
    detect_existing_system  # → erase (optionnel) → run_disko → /mnt monté
    copy_config_to_mnt
    install_nix
    postinstall
    finished
}

main
