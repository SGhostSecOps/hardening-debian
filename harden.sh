#!/bin/bash
# ========================================================
# 🔐 Script de durcissement automatique pour Debian 10/11/12
# Auteur : Peniel (ZeroTraceSec)
# ========================================================

set -e

echo "=== 🔐 Durcissement Debian en cours ==="

# 🔁 Vérification des droits root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Ce script doit être exécuté en tant que root."
  exit 1
fi

# 🧩 Mise à jour du système
echo "➡️ Mise à jour du système..."
apt update && apt upgrade -y

# 🔥 Pare-feu UFW
echo "➡️ Installation et configuration de UFW..."
apt install -y ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw enable

# 🚨 Fail2Ban
echo "➡️ Installation de Fail2Ban..."
apt install -y fail2ban

# ⚙️ Configuration de sysctl (renforcement du noyau)
echo "➡️ Configuration sysctl..."
cat >> /etc/sysctl.conf <<EOF

# Sécurité réseau
net.ipv4.ip_forward = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0

EOF

sysctl -p

# 🧼 Suppression des services inutiles
echo "➡️ Suppression des paquets inutiles..."
apt purge -y telnet xinetd rpcbind avahi-daemon
apt autoremove -y

# 🔐 Désactivation de root en SSH
echo "➡️ Sécurisation SSH (désactivation de root)..."
sed -i 's/^PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart ssh

echo "✅ Durcissement terminé avec succès ! Redémarrage recommandé."

