#!/bin/bash
# Calculate setup estimated elapsed time
SECONDS=0

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
    exploitdb
    ffuf
    flameshot
    fonts-ubuntu
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
    virtualbox-guest-x11
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
cd $HOME/pwnbox-postinstall

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

echo -e "\nThings to do manually to have the look and feel of pwnbox:"

echo -e "- Change the theme\n"

echo "- Font Settings:"
echo -e "-- Application font: Lato Regular 11
-- Document font: Lato Regular 11
-- Desktop font: Lato Regular 11
-- Fixed width font: Ubuntu Mono Regular 12\n"

echo "- Terminal Colors:"
echo -e "-- Text Color: #A4B1CD
-- Bold Color: #C5D1EB
-- Background Color: #141D2B\n"

echo "- Customize the Panel:"
echo -e "-- Add VPN message (/opt/vpnpanel.sh)
-- Add/Edit icons\n"

echo "- System monitor:"
echo -e "-- Width: 135px
-- Update interval: 100ms\n"

echo -e "- Add bottom dock (plank)\n"

kill $pid_sudo_loop
wait $pid_sudo_loop 2>/dev/null

duration=$SECONDS
echo "The setup took $(($duration / 3600)) hours, $((($duration / 60) % 60)) minutes and $(($duration % 60)) seconds to complete."
