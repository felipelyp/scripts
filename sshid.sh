#!/bin/bash

# =============================
# CONFIGURAÇÕES DO SISTEMA
# =============================
export PATH=$PATH:/usr/sbin:/sbin

# =============================
# CONFIG - altere essas variáveis
# =============================
USUARIO="felipelyp"
PORTA_SSH="5000"
CHAVE_PUBLICA="https://sshid.io/felipelyp"

# =============================
# ATUALIZA O SISTEMA
# =============================
echo ""
echo "Atualizando o sistema..."
apt update -y

# =============================
# CRIA USUÁRIO COM SENHA
# =============================
echo ""
if id "$USUARIO" &>/dev/null; then
    echo "Usuário $USUARIO já existe, pulando criação..."
else
    echo "Criando usuário $USUARIO..."
    adduser $USUARIO
fi

# =============================
# INSTALA SUDO E CONFIGURA PERMISSÕES
# =============================
echo ""
echo "Instalando sudo..."
apt install sudo -y

if grep -q "^$USUARIO ALL=(ALL:ALL) ALL" /etc/sudoers; then
    echo "Permissão sudo já configurada, pulando..."
else
    echo "$USUARIO ALL=(ALL:ALL) ALL" >> /etc/sudoers
    echo "Permissão sudo adicionada!"
fi

# =============================
# CONFIGURA CHAVE SSH
# =============================
echo ""
echo "Configurando chave SSH..."
mkdir -p /home/$USUARIO/.ssh
curl -fs $CHAVE_PUBLICA > /home/$USUARIO/.ssh/authorized_keys
chmod 700 /home/$USUARIO/.ssh
chmod 600 /home/$USUARIO/.ssh/authorized_keys
chown -R $USUARIO:$USUARIO /home/$USUARIO/.ssh

# =============================
# CONFIGURA SSH
# =============================
echo ""
echo "Configurando SSH..."
sed -i "s/#Port 22/Port $PORTA_SSH/" /etc/ssh/sshd_config
sed -i "s/Port 22/Port $PORTA_SSH/" /etc/ssh/sshd_config
sed -i "s/PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin no/" /etc/ssh/sshd_config

# =============================
# DESATIVAR ACESSO POR SENHA
# =============================
echo ""
read -p "Desativar acesso SSH por usuário e senha? (s/N): " DESATIVAR_SENHA
if [[ "$DESATIVAR_SENHA" =~ ^[Ss]$ ]]; then
    sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
    sed -i "s/PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
    echo "Acesso por senha desativado!"
else
    sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
    echo "Acesso por senha mantido/reativado!"
fi

# =============================
# REINICIA SSH
# =============================
echo ""
echo "Reiniciando SSH..."
systemctl restart ssh

echo ""
echo "=============================="
echo "          Pronto!             "
echo "=============================="
echo "Usuário : $USUARIO"
echo "Porta   : $PORTA_SSH"
echo "=============================="
