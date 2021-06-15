DESCRIPTION = "NILRT linux kernel debug build"
NI_RELEASE_VERSION = "21.0"
LINUX_VERSION = "4.14"
LINUX_KERNEL_TYPE = "debug"

require linux-nilrt-alternate.inc

SRC_URI += "\
	file://debug.cfg \
"

# This is the place to overwrite the source AUTOREV from linux-nilrt.inc, if
# the kernel recipe requires a particular ref.
#SRCREV = ""
