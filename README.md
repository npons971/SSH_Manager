# 🚀 SSH Manager (`sshm`)

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macos-lightgrey.svg)](https://github.com/npons971/SSH_Manager)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/npons971/SSH_Manager/pulls)

**Un gestionnaire de connexions SSH moderne, rapide et élégant pour votre terminal.**  
*Gérez vos serveurs avec des alias conviviaux, un sélecteur interactif TUI, et une synchronisation OpenSSH native.*

[Fonctionnalités](#-fonctionnalités) • [Installation](#-installation-rapide) • [Utilisation](#-guide-dutilisation) • [Compatibilité OpenSSH](#-compatibilité-native-openssh)

</div>

---

```text
🚀 Serveurs SSH Enregistrés
╭───┬──────────┬──────────────────────┬────────────┬──────────┬───────────────────┬────────────┬─────────────────────────────╮
│ # │ Alias    │ Cible (User@Host)    │ Clé SSH    │  Statut  │ Dernière Connex.  │ Tags       │ Description                 │
├───┼──────────┼──────────────────────┼────────────┼──────────┼───────────────────┼────────────┼─────────────────────────────┤
│ 1 │ prod-web │ ubuntu@198.51.100.20 │ id_ed25519 │ 🟢 18 ms │ Il y a 10 min     │ #prod #aws │ Web cluster frontend        │
│ 2 │ vps-cloud│ root@198.51.100.42   │ id_ed25519 │ 🟢 47 ms │ À l'instant       │ #vps #prod │ Cloud VPS Ubuntu 24.04      │
│ 3 │ staging  │ debian@192.168.1.150 │ id_rsa     │ 🟡 85 ms │ Hier              │ #dev       │ Pre-production API server   │
╰───┴──────────┴──────────────────────┴────────────┴──────────┴───────────────────┴────────────┴─────────────────────────────╯
```

---

## ✨ Fonctionnalités

- ⚡ **Remplacement transparent de `ssh`** : Utilisez directement `ssh list`, `ssh connect` ou `ssh set` sans modifier vos habitudes. Toutes vos commandes `ssh` natives habituelles (`ssh root@ip`, `ssh -i ...`) continuent de fonctionner à 100%.
- 🎨 **Tableau de bord haute fidélité** : Affichage coloré et responsive avec test de latence TCP en direct (`🟢 18 ms`).
- 🧭 **Sélecteur interactif TUI** : Naviguez au clavier (`↑`/`↓`), filtrez en direct avec la recherche instantanée ou tapez directement le numéro (`1-9`).
- 🔑 **Détection automatique des clés SSH** : Lors de l'ajout d'un serveur, `sshm` teste et détecte automatiquement quelle clé de votre `~/.ssh/` est acceptée sans mot de passe.
- 🔄 **Synchronisation OpenSSH native** : Vos alias sont générés dans `~/.ssh/sshm_config` et automatiquement inclus dans `~/.ssh/config`. **VS Code Remote-SSH**, **Cursor**, `scp` et `rsync` reconnaissent vos serveurs immédiatement !
- 📊 **Statistiques d'accès** : Suivi de la dernière connexion et du nombre d'accès par serveur.
- 🏷️ **Tags & Descriptions** : Catégorisez vos serveurs (`#prod`, `#staging`, `#cloud`, `#vps`).

---

## 📦 Installation rapide

### En une seule ligne (recommandé)

```bash
curl -fsSL https://raw.githubusercontent.com/npons971/SSH_Manager/main/scripts/install.sh | bash
```

### Depuis les sources

```bash
git clone https://github.com/npons971/SSH_Manager.git
cd SSH_Manager
chmod +x scripts/install.sh
./scripts/install.sh
```

Puis rechargez votre terminal ou exécutez :
```bash
source ~/.config/sshm/sshm.sh
```

---

## 🛠️ Guide d'utilisation

### 1. Ajouter un serveur (`ssh set`)

**Mode rapide en ligne de commande :**
```bash
ssh set vps-cloud root@198.51.100.42
# ou avec des options :
ssh set web-prod ubuntu@198.51.100.20 -p 2222 -i ~/.ssh/id_ed25519 -t "prod,aws" -d "Serveur Web Principal"
```

**Mode formulaire interactif guidé :**
Tapez simplement `ssh set` sans argument pour être guidé pas à pas :
```bash
ssh set
```

---

### 2. Lister les serveurs (`ssh list` ou `ssh ls`)

Affiche le tableau de bord avec statut live et latence réseau :
```bash
ssh list
```
*Options :*
- `ssh list --no-ping` : Affichage instantané sans vérification réseau.
- `ssh list -t prod` : Filtrer par tag `#prod`.
- `ssh list --json` : Exporter la liste au format JSON.

---

### 3. Se connecter (`ssh connect` ou `ssh <alias>`)

**Menu interactif (TUI) :**
Tapez simplement `ssh` sans argument ou `ssh connect` :
```bash
ssh connect
```
- `↑` / `↓` ou `k` / `j` : Naviguer
- `Entrée` : Se connecter au serveur sélectionné
- `1` - `9` : Sélectionner immédiatement le serveur par son index
- Tapez du texte pour filtrer la liste en direct
- `q` ou `Échap` : Quitter

**Connexion directe par nom :**
```bash
ssh vps-cloud
# ou
ssh connect vps-cloud
```

---

### 4. Diagnostiquer un serveur (`ssh test`)

Vérifie la joignabilité réseau, mesure la latence exacte, extrait la bannière du serveur et teste l'authentification par clé :
```bash
ssh test vps-cloud
```
```text
Test de la connexion vers 'vps-cloud' (root@198.51.100.42:22)...
  ✔ Réseau : Accessible (latence : 49.7 ms)
  ✔ Bannière SSH : SSH-2.0-OpenSSH_9.6p1 Ubuntu-3ubuntu13.20
  ✔ Authentification : Réussie avec id_ed25519 !
```

---

### 5. Autres commandes

| Commande | Action |
| :--- | :--- |
| `ssh edit <nom>` | Modifie les paramètres d'un serveur existant |
| `ssh rm <nom>` | Supprime un serveur enregistré |
| `ssh copy-id <nom>` | Copie votre clé publique sur le serveur distant |
| `ssh sync` | Force la synchronisation de `~/.ssh/sshm_config` |

---

## 🔌 Compatibilité native OpenSSH

Parce que `sshm` synchronise ses serveurs dans `~/.ssh/sshm_config` (automatiquement inclus dans `~/.ssh/config`), vous pouvez utiliser vos alias dans **n'importe quel outil standard** :

- **VS Code & Cursor** : Vos serveurs apparaissent automatiquement dans l'extension Remote SSH.
- **Transfert de fichiers** :
  ```bash
  scp mon-fichier vps-cloud:/root/
  rsync -avz ./site/ vps-cloud:/var/www/
  ```
- **Git sur serveur privé** :
  ```bash
  git clone vps-cloud:/srv/git/mon-projet.git
  ```

---

## 🗑️ Désinstallation

Pour désinstaller proprement `sshm` de votre machine :
```bash
./scripts/uninstall.sh
```

---

## 🤝 Contribution

Les contributions, signalements de bugs et suggestions sont les bienvenus !
1. Forkez le projet
2. Créez votre branche (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commitez vos modifications (`git commit -m 'feat: ajout nouvelle fonctionnalite'`)
4. Pushez vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Ouvrez une Pull Request

---

## 📄 Licence

Ce projet est sous licence MIT. Consultez le fichier [LICENSE](LICENSE) pour plus d'informations.
