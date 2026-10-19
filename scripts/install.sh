#!/usr/bin/env bash
# =============================================================================
# SSH Manager (sshm) - Installer Script
# Supports:
#   - Local install: ./scripts/install.sh
#   - Remote 1-line install:
#     curl -fsSL https://raw.githubusercontent.com/npons971/SSH_Manager/main/scripts/install.sh | bash
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${CYAN}${BOLD}"
cat << 'EOF'
   _____ _____ _    _ __  __ 
  / ____/ ____| |  | |  \/  |
 | (___| (___ | |__| | \  / |
  \___ \\___ \|  __  | |\/| |
  ____) |___) | |  | | |  | |
 |_____/_____/|_|  |_|_|  |_|
  SSH Manager - Installation
EOF
echo -e "${NC}"

# 1. Vérification de Python 3
if ! command -v python3 >/dev/null 2>&1; then
    echo -e "${RED}✖ Erreur : Python 3 est requis mais n'est pas installé.${NC}"
    exit 1
fi
echo -e "${GREEN}✔ Python 3 détecté : $(python3 --version)${NC}"

# 2. Vérification / Installation de la dépendance 'rich'
if ! python3 -c "import rich" >/dev/null 2>&1; then
    echo -e "${YELLOW}⚡ Installation de la bibliothèque 'rich'...${NC}"
    if command -v pip3 >/dev/null 2>&1; then
        pip3 install --user rich
    elif command -v pip >/dev/null 2>&1; then
        pip install --user rich
    else
        echo -e "${RED}✖ Erreur : pip est introuvable. Installez 'rich' manuellement avec : pip install rich${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}✔ Dépendance Python 'rich' prête.${NC}"

# 3. Création des répertoires cibles
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/sshm"
SSH_DIR="$HOME/.ssh"

mkdir -p "$BIN_DIR" "$CONFIG_DIR" "$SSH_DIR"
chmod 700 "$SSH_DIR"

# 4. Téléchargement ou copie des fichiers
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

if [ -f "$REPO_DIR/bin/sshm" ] && [ -f "$REPO_DIR/shell/sshm.sh" ]; then
    echo -e "${CYAN}• Installation depuis les sources locales...${NC}"
    cp "$REPO_DIR/bin/sshm" "$BIN_DIR/sshm"
    cp "$REPO_DIR/shell/sshm.sh" "$CONFIG_DIR/sshm.sh"
else
    echo -e "${CYAN}• Téléchargement depuis GitHub...${NC}"
    RAW_URL="https://raw.githubusercontent.com/npons971/SSH_Manager/main"
    curl -fsSL "$RAW_URL/bin/sshm" -o "$BIN_DIR/sshm"
    curl -fsSL "$RAW_URL/shell/sshm.sh" -o "$CONFIG_DIR/sshm.sh"
fi

chmod +x "$BIN_DIR/sshm"
chmod +r "$CONFIG_DIR/sshm.sh"

echo -e "${GREEN}✔ Binaire sshm installé dans : $BIN_DIR/sshm${NC}"
echo -e "${GREEN}✔ Script shell installé dans : $CONFIG_DIR/sshm.sh${NC}"

# 5. Configuration de l'environnement Shell (.zshrc / .bashrc)
SOURCE_LINE='[ -f "$HOME/.config/sshm/sshm.sh" ] && source "$HOME/.config/sshm/sshm.sh"'
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'

add_shell_integration() {
    local rc_file="$1"
    if [ -f "$rc_file" ]; then
        if ! grep -Fq "$SOURCE_LINE" "$rc_file"; then
            echo "" >> "$rc_file"
            echo "# --- SSH Manager (sshm) ---" >> "$rc_file"
            if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
                echo "$PATH_LINE" >> "$rc_file"
            fi
            echo "$SOURCE_LINE" >> "$rc_file"
            echo "# --- end SSH Manager ---" >> "$rc_file"
            echo -e "${GREEN}✔ Intégration ajoutée à : $rc_file${NC}"
        else
            echo -e "${CYAN}• Intégration déjà présente dans : $rc_file${NC}"
        fi
    fi
}

add_shell_integration "$HOME/.zshrc"
add_shell_integration "$HOME/.bashrc"

# 6. Initialisation de OpenSSH config
OPENSSH_CONFIG="$SSH_DIR/config"
SSHM_CONFIG="$SSH_DIR/sshm_config"
touch "$SSHM_CONFIG"
chmod 600 "$SSHM_CONFIG"

INCLUDE_LINE="Include ~/.ssh/sshm_config"
if [ -f "$OPENSSH_CONFIG" ]; then
    if ! grep -Fq "$INCLUDE_LINE" "$OPENSSH_CONFIG" && ! grep -Fq "Include $SSHM_CONFIG" "$OPENSSH_CONFIG"; then
        TMP_CONF=$(mktemp)
        echo -e "# Include SSH Manager\n$INCLUDE_LINE\n" > "$TMP_CONF"
        cat "$OPENSSH_CONFIG" >> "$TMP_CONF"
        mv "$TMP_CONF" "$OPENSSH_CONFIG"
        chmod 600 "$OPENSSH_CONFIG"
    fi
else
    echo -e "# OpenSSH Client Configuration\n# Managed by SSH Manager\n$INCLUDE_LINE\n" > "$OPENSSH_CONFIG"
    chmod 600 "$OPENSSH_CONFIG"
fi
echo -e "${GREEN}✔ Intégration OpenSSH configurée (~/.ssh/config)${NC}"

echo -e "\n${GREEN}${BOLD}✨ Installation terminée avec succès !${NC}"
echo -e "${CYAN}Pour activer immédiatement dans ce terminal :${NC}"
echo -e "  ${BOLD}source ~/.config/sshm/sshm.sh${NC}"
echo -e "\n${YELLOW}Commandes utiles :${NC}"
echo -e "  ${BOLD}ssh set <nom> <user@ip>${NC}   - Enregistrer un serveur"
echo -e "  ${BOLD}ssh list${NC}                  - Voir tous les serveurs et leur statut"
echo -e "  ${BOLD}ssh connect${NC}               - Menu interactif de sélection"
echo -e "  ${BOLD}ssh <nom>${NC}                 - Connexion directe"
echo ""
