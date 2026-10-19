#!/usr/bin/env bash
# =============================================================================
# SSH Manager (sshm) - Uninstaller Script
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${YELLOW}${BOLD}Désinstallation de SSH Manager (sshm)...${NC}"

# 1. Suppression du binaire
if [ -f "$HOME/.local/bin/sshm" ]; then
    rm -f "$HOME/.local/bin/sshm"
    echo -e "${GREEN}✔ Binaire ~/.local/bin/sshm supprimé.${NC}"
fi

# 2. Suppression du script shell
if [ -f "$HOME/.config/sshm/sshm.sh" ]; then
    rm -f "$HOME/.config/sshm/sshm.sh"
    echo -e "${GREEN}✔ Script shell ~/.config/sshm/sshm.sh supprimé.${NC}"
fi

# 3. Demande pour les données
if [ -f "$HOME/.config/sshm/servers.json" ]; then
    read -p "Voulez-vous aussi supprimer la base de serveurs (~/.config/sshm/servers.json) ? [o/N] " -r resp
    if [[ "$resp" =~ ^[oOyY]$ ]]; then
        rm -rf "$HOME/.config/sshm"
        rm -f "$HOME/.ssh/sshm_config"
        echo -e "${GREEN}✔ Configuration et base de serveurs supprimées.${NC}"
    else
        echo -e "${CYAN}• Données conservées dans ~/.config/sshm/servers.json.${NC}"
    fi
fi

# 4. Nettoyage des fichiers RC
clean_rc() {
    local rc="$1"
    if [ -f "$rc" ]; then
        sed -i '/# --- SSH Manager (sshm) ---/,/# --- end SSH Manager ---/d' "$rc"
        echo -e "${GREEN}✔ Entrées supprimées de $rc${NC}"
    fi
}

clean_rc "$HOME/.zshrc"
clean_rc "$HOME/.bashrc"

echo -e "\n${GREEN}${BOLD}✔ Désinstallation terminée.${NC}"
