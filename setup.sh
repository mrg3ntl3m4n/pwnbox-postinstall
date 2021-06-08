#!/bin/bash
# Calculate setup estimated elapsed time
SECONDS=0

setup_folder=$(pwd)

# Prevent sudo timeout
echo "Caching user's password ..."
sudo -v
while true; do sudo -v; sleep 300; done &
pid_sudo_loop=$!

echo -e "\nUpdating the system ..."
sudo parrot-upgrade

echo -e "\nInstalling APT packages ..."
apt_packages=(
    apt-transport-https
    awscli
    ca-certificates
    exploitdb
    ffuf
    flameshot
    fonts-ubuntu
    gnupg
    libssl-dev
    ltrace
    ncat
    neo4j
    plank
    powershell-empire
    python-dev
    python2.7
    python3-venv
    rdesktop
    snmp
    snmp-mibs-downloader
    strace
)

sudo apt-get install -y ${apt_packages[@]}

# Tools that can be "installed" only cloning repositories
echo -e "\nCloning GitHub repositories ..."
git_repos=(
    https://github.com/stealthcopter/deepce.git
    https://github.com/internetwache/GitTools.git
    https://github.com/mzet-/linux-exploit-suggester.git
    https://github.com/samratashok/nishang.git
    https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite.git
    https://github.com/danielmiessler/SecLists.git
    https://github.com/tennc/webshell.git
)

cd /opt

for repo in ${git_repos[@]}; do
    sudo git clone $repo
    echo ""
done

echo "Installing BloodHound ..."
sudo mkdir BloodHound && cd BloodHound/
sudo wget -q --show-progress https://github.com/BloodHoundAD/BloodHound/releases/download/4.0.2/BloodHound-linux-x64.zip
echo -e "\nUnzipping BloodHound ..."
sudo unzip -q BloodHound-linux-x64.zip
sudo rm BloodHound-linux-x64.zip
cd ..

echo -e "\nInstalling chisel ..."
sudo mkdir chisel && cd chisel/
sudo wget -q --show-progress https://github.com/jpillora/chisel/releases/download/v1.7.6/chisel_1.7.6_linux_amd64.gz
sudo wget -q --show-progress https://github.com/jpillora/chisel/releases/download/v1.7.6/chisel_1.7.6_windows_amd64.gz
sudo gunzip chisel_*.gz
cd ..

echo -e "\nInstalling CrackMapExec ..."
python3 -m pip install pipx
pipx ensurepath
pipx install crackmapexec

echo -e "\nInstalling Docker ..."
sudo apt-get remove -y docker docker-engine docker.io containerd runc
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  buster stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

echo -e "\nInstalling droopescan ..."
python3 -m pip install droopescan

echo -e "\nInstalling Ghidra ..."
sudo mkdir Ghidra && cd Ghidra/
sudo wget -q --show-progress https://ghidra-sre.org/ghidra_9.2.3_PUBLIC_20210325.zip
echo -e "\nUnzipping Ghidra ..."
sudo unzip -q ghidra_*_PUBLIC_*.zip
sudo rm ghidra_*_PUBLIC_*.zip
cd ..

echo -e "\nInstalling kerbrute ..."
sudo mkdir kerbrute && cd kerbrute/
sudo wget -q --show-progress https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_amd64
cd ..

echo -e "\nInstalling Obsidian ..."
sudo mkdir Obsidian && cd Obsidian/
sudo wget -q --show-progress https://github.com/obsidianmd/obsidian-releases/releases/download/v0.12.3/Obsidian-0.12.3.AppImage
sudo chmod +x Obsidian-*.AppImage
ln -s /opt/Obsidian/Obsidian-*.AppImage $HOME/.local/bin/obsidian

echo -e "\nCopying files around ..."
cd $setup_folder/

cp $HOME/.bashrc $HOME/.bashrc.bak
cp .bashrc $HOME/.bashrc
cp .tmux.conf $HOME/.tmux.conf

sudo cp vpn*.sh /opt/
sudo chmod +x /opt/vpn*.sh

sudo cp htb-bg*.jpg /usr/share/backgrounds/
sudo cp -R Material-Black-Lime-Numix-FLAT/ /usr/share/icons/
sudo cp -R htb/ /usr/share/icons/

sudo mkdir /usr/share/themes/HackTheBox
sudo cp index.theme /usr/share/themes/HackTheBox/

cat todo.txt

kill $pid_sudo_loop
wait $pid_sudo_loop 2>/dev/null

duration=$SECONDS
echo -e "\nThe setup took $(($duration / 3600)) hours, $((($duration / 60) % 60)) minutes and $(($duration % 60)) seconds to complete."
