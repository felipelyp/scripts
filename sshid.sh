#!/bin/bash

# =============================
# CONFIG - altere essas variáveis
# =============================
USUARIO="felipelyp"
PORTA_SSH="5000"
CHAVE_PUBLICA="https://sshid.io/felipelyp"

# =============================
# CONFIGURAÇÕES DO SISTEMA
# =============================
export PATH=$PATH:/usr/sbin:/sbin

# =============================
# CRIA USUÁRIO COM SENHA
# =============================
adduser $USUARIO

# =============================
# INSTALA SUDO E CONFIGURA PERMISSÕES
# =============================
apt install sudo -y
echo "$USUARIO ALL=(ALL:ALL) ALL" >> /etc/sudoers

# =============================
# CONFIGURA CHAVE SSH
# =============================
mkdir -p /home/$USUARIO/.ssh
curl -fs $CHAVE_PUBLICA > /home/$USUARIO/.ssh/authorized_keys
chmod 700 /home/$USUARIO/.ssh
chmod 600 /home/$USUARIO/.ssh/authorized_keys
chown -R $USUARIO:$USUARIO /home/$USUARIO/.ssh

# =============================
# CONFIGURA SSH
# =============================
sed -i "s/#Port 22/Port $PORTA_SSH/" /etc/ssh/sshd_config
sed -i "s/Port 22/Port $PORTA_SSH/" /etc/ssh/sshd_config
sed -i "s/PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
sed -i "s/PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config

# =============================
# REINICIA SSH
# =============================
systemctl restart ssh

echo "=============================="
echo "Pronto! Configure assim:"
echo "Usuário: $USUARIO"
echo "Porta: $PORTA_SSH"
echo "=============================="
