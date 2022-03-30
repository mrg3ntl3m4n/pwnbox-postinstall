#!/bin/bash
# Calculate setup estimated elapsed time
SECONDS=0

# cd into pwnbox-postinstall folder
setup_folder=$(pwd)

# Prevent sudo timeout
echo "Caching user's password ..."
sudo -v
while true; do sudo -v; sleep 60; done &
pid_sudo_loop=$!

echo -e "\nUpdating the system ..."
sudo parrot-upgrade

echo -e "\nInstalling APT packages ..."
xargs -d '\n' -- sudo apt-get install -y < packages.txt

# Tools that can be "installed" only cloning repositories
echo -e "\nCloning GitHub repositories ..."
cd /opt

#for repo in ${git_repos[@]}; do
for repo in $(cat $setup_folder/repositories.txt); do
    sudo git clone $repo
    echo ""
done

echo "Installing adidnsdump ..."
cd adidnsdump
pip install .
cd ..

echo -e "\nInstalling BloodHound ..."
sudo mkdir BloodHound && cd BloodHound/
sudo wget -q --show-progress https://github.com/BloodHoundAD/BloodHound/releases/download/4.1.0/BloodHound-linux-x64.zip
echo -e "\nUnzipping BloodHound ..."
sudo unzip -q BloodHound-linux-x64.zip
sudo rm BloodHound-linux-x64.zip
cd ..

echo -e "\nInstalling builder ..."
pip3 install builder

echo -e "\nInstalling chisel ..."
sudo mkdir chisel && cd chisel/
sudo wget -q --show-progress https://github.com/jpillora/chisel/releases/download/v1.7.7/chisel_1.7.7_linux_amd64.gz
sudo wget -q --show-progress https://github.com/jpillora/chisel/releases/download/v1.7.7/chisel_1.7.7_windows_amd64.gz
sudo gunzip chisel_*.gz
cd ..

echo -e "\nInstalling Covenant ..."
sudo git clone --recurse-submodules https://github.com/cobbr/Covenant
cd Covenant/Covenant/
sudo dotnet build
cd ../../

echo -e "\nInstalling CrackMapExec ..."
python3 -m pip install pipx
pipx ensurepath
pipx install crackmapexec

echo -e "\nInstalling Docker ..."
sudo apt-get remove -y docker docker-engine docker.io containerd runc
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

echo -e "\nInstalling droopescan ..."
python3 -m pip install droopescan

echo -e "\nInstalling enumerate-iam ..."
cd enumerate-iam/
pip install -r requirements.txt
cd ..

echo -e "\nInstalling flask-unsign ..."
pip3 install flask-unsign

echo -e "\nInstalling Ghidra ..."
sudo mkdir Ghidra && cd Ghidra/
sudo wget -q --show-progress https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.1.2_build/ghidra_10.1.2_PUBLIC_20220125.zip
echo -e "\nUnzipping Ghidra ..."
sudo unzip -q ghidra_*_PUBLIC_*.zip
sudo rm ghidra_*_PUBLIC_*.zip
cd ..

echo -e "\nInstalling pip2 for Gopherus ..."
wget -q --show-progress -O ~/Downloads/get-pip.py https://bootstrap.pypa.io/pip/2.7/get-pip.py
sudo python2 ~/Downloads/get-pip.py
echo -e "\nInstalling Gopherus ..."
cd Gopherus/
sudo ./install.sh
cd ..

echo -e "\nInstalling haiti-hash ..."
sudo gem install haiti-hash

echo -e "\nInstalling httprobe ..."
go get -u github.com/tomnomnom/httprobe

echo -e "\nInstalling jwt_tool requirements ..."
python3 -m pip install termcolor cprint pycryptodomex requests

echo -e "\nInstalling kerbrute ..."
sudo mkdir kerbrute && cd kerbrute/
sudo wget -q --show-progress https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_amd64
cd ..

echo -e "\nInstalling nodemon ..."
sudo npm install -g nodemon

echo -e "\nInstalling Obsidian ..."
sudo mkdir Obsidian && cd Obsidian/
sudo wget -q --show-progress https://github.com/obsidianmd/obsidian-releases/releases/download/v0.13.23/Obsidian-0.13.23.AppImage
sudo chmod +x Obsidian-*.AppImage
ln -s /opt/Obsidian/Obsidian-*.AppImage $HOME/.local/bin/obsidian
cd ..

echo -e "\nInstalling pacu ..."
pip3 install -U pacu

echo -e "\nInstalling Postman ..."
sudo wget -q --show-progress -O Postman-linux-x86_64.tar.gz https://dl.pstmn.io/download/latest/linux64
sudo tar zxf Postman-linux-x86_64.tar.gz
sudo rm Postman-linux-x86_64.tar.gz
cp $setup_folder/Postman.desktop ~/.local/share/applications/Postman.desktop

echo -e "\nInstalling Search-That-Hash ..."
pip3 install search-that-hash

echo -e "\nInstalling SprayingToolkit ..."
cd SprayingToolkit/
sudo -H pip3 install -r requirements.txt
cd ..

echo -e "\nInstalling subfinder ..."
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

echo -e "\nInstalling waybackurls ..."
go get github.com/tomnomnom/waybackurls

echo -e "\nInstalling ysoserial ..."
sudo mkdir ysoserial && cd ysoserial/
sudo wget -q --show-progress https://jitpack.io/com/github/frohoff/ysoserial/master-SNAPSHOT/ysoserial-master-SNAPSHOT.jar
cd ..

echo -e "\nCopying files around ..."
cd $setup_folder/

cp $HOME/.bashrc $HOME/.bashrc.bak
cp .bashrc $HOME/.bashrc
cp .tmux.conf $HOME/.tmux.conf

sudo cp vpn*.sh /opt/
sudo chmod +x /opt/vpn*.sh

sudo cp desktop-bg/* /usr/share/backgrounds/
sudo cp -R Material-Black-Lime-Numix-FLAT/ /usr/share/icons/
sudo cp -R htb/ /usr/share/icons/

sudo mkdir /usr/share/themes/HackTheBox
sudo cp index.theme /usr/share/themes/HackTheBox/

# Theme settings
dconf write /org/mate/desktop/interface/gtk-theme "'ARK-Dark'"
dconf write /org/mate/marco/general/theme "'ARK-Dark'"
dconf write /org/mate/desktop/interface/icon-theme "'Material-Black-Lime-Numix-FLAT'"
dconf write /org/mate/desktop/interface/gtk-color-scheme "'base_color:#404552,fg_color:#D3DAE3,tooltip_fg_color:#FFFFFF,selected_bg_color:#5294E2,selected_fg_color:#FFFFFF,text_color:#D3DAE3,bg_color:#383C4A,insensitive_bg_color:#3e4350,insensitive_fg_color:#7c818c,notebook_bg:#404552,dark_sidebar_bg:#353945,tooltip_bg_color:#353945,link_color:#5294E2,menu_bg:#383C4A'"
dconf write /org/mate/desktop/peripherals/mouse/cursor-theme "'Breeze'"
dconf write /org/mate/desktop/peripherals/mouse/cursor-size "24"
dconf write /org/mate/desktop/background/picture-filename "'/usr/share/backgrounds/hackingnight.png'"

# Font settings
dconf write /org/mate/desktop/interface/font-name "'Lato 11'"
dconf write /org/mate/desktop/interface/document-font-name "'Lato 11'"
dconf write /org/mate/caja/desktop/font "'Lato 11'"
dconf write /org/mate/desktop/interface/monospace-font-name "'Ubuntu Mono 12'"

echo -e "\nAdding date and time to bash history ...\n"
echo 'export HISTTIMEFORMAT="%d/%m/%y %T "' >> ~/.bash_profile
source ~/.bash_profile

cat todo.txt

kill $pid_sudo_loop
wait $pid_sudo_loop 2>/dev/null

duration=$SECONDS
echo -e "\nThe setup took $(($duration / 3600)) hours, $((($duration / 60) % 60)) minutes and $(($duration % 60)) seconds to complete."
