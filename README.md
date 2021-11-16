# automatic-gentoo-kernel-upgrade.sh
__NOTE:__ This script was written for the author's specific use case. More specifically, __it uses EFISTUB and `efibootmgr`__ in order to add the kernel directly as an EFI boot entry.
Outside of that this script should work across all Gentoo systems; just make sure to apply your own bootloader changes, if any.

This script was written in order to automate the Gentoo kernel upgrade process after I noticed that I kept running the same commands everytime.
The script works with supported kernels as well as unsupported ones (zen, pf, etc.)
It looks for whichever kernel is the newest (highest version number) and upgrades to it automatically.

If there are any bugs or if something doesn't work, please file an issue.
