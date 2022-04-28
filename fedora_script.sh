#!/usr/bin/env bash
export LC_ALL=C

jetbrainsToolboxVersion="1.23.11849"

# Update and upgrade system if needed
dnf update -y
dnf upgrade -y

# Blacklist nouveau
grubby --update-kernel=ALL --args="rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1"

# Add RPM fusion (both free and non-free)
dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Enable COPR repo for PolyMC
dnf copr enable sentry/polymc

# Install apps and NVIDIA drivers from repos
dnf install dolphin-emu gimp gamehub legendary solaar thunderbird steam akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-cuda nvidia-settings polymc nheko -y

# Install JetBrains Toolbox
# This is mostly taken from https://github.com/nagygergo/jetbrains-toolbox-install
# Download
wget "https://download.jetbrains.com/toolbox/jetbrains-toolbox-${jetbrainsToolboxVersion}.tar.gz" -O jetbrains.tar.gz
# Extract
tar -xzf jetbrains.tar.gz -C /opt/jetbrains-toolbox --strip-components=1
# Create symlink
chmod -R +rwx /opt/jetbrains-toolbox
touch /opt/jetbrains-toolbox/jetbrains-toolbox.sh
echo "#!/usr/bin/env bash" >> /opt/jetbrains-toolbox/jetbrains-toolbox.sh
echo "/opt/jetbrains-toolbox/jetbrains-toolbox" >> /opt/jetbrains-toolbox/jetbrains-toolbox.sh
ln -s /opt/jetbrains-toolbox/jetbrains-toolbox.sh /usr/local/bin/jetbrains-toolbox
chmod -R +rwx /usr/local/bin/jetbrains-toolbox

# Copy personal configs if they exist
copy ".config" "~/.config"
copy ".mozilla" "~/.mozilla"
copy ".thunderbird" "~/.thunderbird"
copy "RiderProjects" "~/RiderProjects"
copy "IdeaProjects" "~/IdeaProjects"
copy "Wii Games" "~/Documents/Wii Games"
copy "PolyMC" "~/.local/share/PolyMC"

function copy()
{
	if [ -d "$1" ]; then
		cp -R "$1" "$2"
	fi
}