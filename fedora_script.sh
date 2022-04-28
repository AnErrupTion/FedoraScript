#!/usr/bin/env bash
export LC_ALL=C

jetbrainsToolboxVersion="1.23.11849"
nvidiaPackages="akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-cuda"

function copyDir()
{
	if [ -d "$1" ]; then
		cp -R "$1" "$2"
	fi
}

function executeScript()
{
	echo "What version of the NVIDIA drivers to install?"
	echo "1. 340"
	echo "2. 390"
	echo "3. Latest"

	read nvidiaVersion

	if [ ${nvidiaVersion} == "1" ]; then
		nvidiaPackages="akmod-nvidia-340xx xorg-x11-drv-nvidia-340xx xorg-x11-drv-nvidia-340xx-cuda"
	elif [ ${nvidiaVersion} == "2" ]; then
		nvidiaPackages="akmod-nvidia-390xx xorg-x11-drv-nvidia-390xx xorg-x11-drv-nvidia-390xx-cuda"
	fi

	# Update and upgrade system if needed
	dnf update -y
	dnf upgrade -y

	# Blacklist nouveau
	grubby --update-kernel=ALL --args="rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1"

	# Add RPM fusion (both free and non-free)
	dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

	# Enable COPR repo for PolyMC
	dnf copr enable sentry/polymc -y

	# Install apps and NVIDIA drivers from repos
	dnf install dolphin-emu gimp gamehub legendary solaar thunderbird steam ${nvidiaPackages} nvidia-settings polymc nheko -y

	# Install JetBrains Toolbox
	# This is mostly taken from https://github.com/nagygergo/jetbrains-toolbox-install
	# Download
	wget "https://download.jetbrains.com/toolbox/jetbrains-toolbox-${jetbrainsToolboxVersion}.tar.gz" -O jetbrains.tar.gz
	# Extract
	mkdir /opt/jetbrains-toolbox
	tar -xzf jetbrains.tar.gz -C /opt/jetbrains-toolbox --strip-components=1
	# Create symlink
	chmod -R +rwx /opt/jetbrains-toolbox
	touch /opt/jetbrains-toolbox/jetbrains-toolbox.sh
	echo "#!/usr/bin/env bash" >> /opt/jetbrains-toolbox/jetbrains-toolbox.sh
	echo "/opt/jetbrains-toolbox/jetbrains-toolbox" >> /opt/jetbrains-toolbox/jetbrains-toolbox.sh
	ln -s /opt/jetbrains-toolbox/jetbrains-toolbox.sh /usr/local/bin/jetbrains-toolbox
	chmod -R +rwx /usr/local/bin/jetbrains-toolbox

	# Copy personal configs if they exist
	copyDir ".config" "~/.config"
	copyDir ".mozilla" "~/.mozilla"
	copyDir ".thunderbird" "~/.thunderbird"
	copyDir "RiderProjects" "~/RiderProjects"
	copyDir "IdeaProjects" "~/IdeaProjects"
	copyDir "Wii Games" "~/Documents/Wii Games"
	copyDir "PolyMC" "~/.local/share/PolyMC"
}

executeScript