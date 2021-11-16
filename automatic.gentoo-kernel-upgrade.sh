#!/bin/sh
KERNEL_DIRECTORY="/usr/src/"
CURRENT_KERNEL_VERSION=$(uname -r | sed -e 's/-.*//g')
LATEST_KERNEL_VERSION=$(find $KERNEL_DIRECTORY -maxdepth 1 -type d -iname "linux-*" | sed -e 's/[[:alpha:]]//g' -e 's/[][/-]//g' | sort -rV | head -n 1)

_install() {
	echo "New kernel version found. Press ENTER to install or Ctrl+C to cancel."
	read -r line
	echo "Continuing..."
	LATEST_KERNEL_DIRECTORY=$(find "$KERNEL_DIRECTORY" -maxdepth 1 -type d -iname "*$LATEST_KERNEL_VERSION*")
	CURRENT_KERNEL_DIRECTORY=$(find "$KERNEL_DIRECTORY" -maxdepth 1 -type d -iname "*$CURRENT_KERNEL_VERSION*")
	ln -nsf "$LATEST_KERNEL_DIRECTORY" "$KERNEL_DIRECTORY"/linux
	cd "$KERNEL_DIRECTORY"linux || exit 2
	cp "$CURRENT_KERNEL_DIRECTORY"/.config .
	make oldconfig # replace this with olddefconfig if you don't want to interactively configure the kernel
	echo "Building new kernel..."
	make -j8; make modules_prepare; make modules_install; make install
	echo "Installing extra modules from portage..."
	emerge -qv @module-rebuild
	echo "Adding latest kernel to EFI boot entry..."
	KERNEL_FILE=$(find /boot -maxdepth 1 -type f -iname "vmlinuz*$LATEST_KERNEL_VERSION*" -printf "%P\n"| grep -v '.old')
	LABEL_NAME=$( echo "$KERNEL_FILE" | sed 's/vmlinuz-/Gentoo\ /')
	##########################################################
	## CHANGE THE NEXT LINE FOR YOUR SPECIFIC CONFIGURATION ##
	##########################################################
	efibootmgr --disk /dev/nvme0n1 --part 1 --create --label "$LABEL_NAME" --loader /"$KERNEL_FILE"
	# In my case: my EFI partition is /boot, which is located on Partition 1 of /dev/nvme0n1, this may differ for you
}

if [ "$LATEST_KERNEL_VERSION" = "$CURRENT_KERNEL_VERSION" ]; then
	echo "Latest kernel already installed. Exiting..."
	exit 1;
else
	_install && echo "Kernel installation complete! You may reboot to load the new kernel."
fi
