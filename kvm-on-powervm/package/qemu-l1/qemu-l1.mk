################################################################################
#
# qemu
#
################################################################################

QEMU_L1_VERSION = 7.1.0
QEMU_L1_SOURCE = qemu-$(QEMU_VERSION).tar.xz
QEMU_L1_SITE = http://download.qemu.org
QEMU_L1_LICENSE = GPL-2.0, LGPL-2.1, MIT, BSD-3-Clause, BSD-2-Clause, Others/BSD-1c
QEMU_L1_LICENSE_FILES = COPYING COPYING.LIB
# NOTE: there is no top-level license file for non-(L)GPL licenses;
#       the non-(L)GPL license texts are specified in the affected
#       individual source files.
QEMU_L1_CPE_ID_VENDOR = qemu

#-------------------------------------------------------------

# The build system is now partly based on Meson.
# However, building is still done with configure and make as in previous versions of QEMU_L1.

# Target-qemu
QEMU_L1_DEPENDENCIES = host-meson host-pkgconf libglib2 zlib pixman host-python3

# Need the LIBS variable because librt and libm are
# not automatically pulled. :-(
QEMU_L1_LIBS = -lrt -lm

QEMU_L1_OPTS =

QEMU_L1_VARS = LIBTOOL=$(HOST_DIR)/bin/libtool

# If we want to specify only a subset of targets, we must still enable all
# of them, so that QEMU_L1 properly builds its list of default targets, from
# which it then checks if the specified sub-set is valid. That's what we
# do in the first part of the if-clause.
# Otherwise, if we do not want to pass a sub-set of targets, we then need
# to either enable or disable -user and/or -system emulation appropriately.
# That's what we do in the else-clause.
ifneq ($(call qstrip,$(BR2_PACKAGE_QEMU_L1_CUSTOM_TARGETS)),)
QEMU_L1_OPTS += --enable-system --enable-linux-user
QEMU_L1_OPTS += --target-list="$(call qstrip,$(BR2_PACKAGE_QEMU_L1_CUSTOM_TARGETS))"
else

ifeq ($(BR2_PACKAGE_QEMU_L1_SYSTEM),y)
QEMU_L1_OPTS += --enable-system
else
QEMU_L1_OPTS += --disable-system
endif

ifeq ($(BR2_PACKAGE_QEMU_L1_LINUX_USER),y)
QEMU_L1_OPTS += --enable-linux-user
else
QEMU_L1_OPTS += --disable-linux-user
endif

endif

ifeq ($(BR2_TOOLCHAIN_USES_UCLIBC),y)
QEMU_L1_OPTS += --disable-vhost-user
else
QEMU_L1_OPTS += --enable-vhost-user
endif

ifeq ($(BR2_PACKAGE_QEMU_L1_SLIRP),y)
QEMU_L1_OPTS += --enable-slirp=system
QEMU_L1_DEPENDENCIES += slirp
else
QEMU_L1_OPTS += --disable-slirp
endif

ifeq ($(BR2_PACKAGE_QEMU_L1_SDL),y)
QEMU_L1_OPTS += --enable-sdl
QEMU_L1_DEPENDENCIES += sdl2
QEMU_L1_VARS += SDL2_CONFIG=$(STAGING_DIR)/usr/bin/sdl2-config
else
QEMU_L1_OPTS += --disable-sdl
endif

ifeq ($(BR2_PACKAGE_QEMU_L1_FDT),y)
QEMU_L1_OPTS += --enable-fdt
QEMU_L1_DEPENDENCIES += dtc
else
QEMU_L1_OPTS += --disable-fdt
endif

ifeq ($(BR2_PACKAGE_QEMU_L1_TOOLS),y)
QEMU_L1_OPTS += --enable-tools
else
QEMU_L1_OPTS += --disable-tools
endif

ifeq ($(BR2_PACKAGE_LIBFUSE3),y)
QEMU_L1_OPTS += --enable-fuse --enable-fuse-lseek
QEMU_L1_DEPENDENCIES += libfuse3
else
QEMU_L1_OPTS += --disable-fuse --disable-fuse-lseek
endif

ifeq ($(BR2_PACKAGE_LIBSECCOMP),y)
QEMU_L1_OPTS += --enable-seccomp
QEMU_L1_DEPENDENCIES += libseccomp
else
QEMU_L1_OPTS += --disable-seccomp
endif

ifeq ($(BR2_PACKAGE_LIBSSH),y)
QEMU_L1_OPTS += --enable-libssh
QEMU_L1_DEPENDENCIES += libssh
else
QEMU_L1_OPTS += --disable-libssh
endif

ifeq ($(BR2_PACKAGE_LIBUSB),y)
QEMU_L1_OPTS += --enable-libusb
QEMU_L1_DEPENDENCIES += libusb
else
QEMU_L1_OPTS += --disable-libusb
endif

ifeq ($(BR2_PACKAGE_LIBVNCSERVER),y)
QEMU_L1_OPTS += \
	--enable-vnc \
	--disable-vnc-sasl
QEMU_L1_DEPENDENCIES += libvncserver
ifeq ($(BR2_PACKAGE_LIBPNG),y)
QEMU_L1_OPTS += --enable-png
QEMU_L1_DEPENDENCIES += libpng
else
QEMU_L1_OPTS += --disable-png
endif
ifeq ($(BR2_PACKAGE_JPEG),y)
QEMU_L1_OPTS += --enable-vnc-jpeg
QEMU_L1_DEPENDENCIES += jpeg
else
QEMU_L1_OPTS += --disable-vnc-jpeg
endif
else
QEMU_L1_OPTS += --disable-vnc
endif

ifeq ($(BR2_PACKAGE_NETTLE),y)
QEMU_L1_OPTS += --enable-nettle
QEMU_L1_DEPENDENCIES += nettle
else
QEMU_L1_OPTS += --disable-nettle
endif

ifeq ($(BR2_PACKAGE_NUMACTL),y)
QEMU_L1_OPTS += --enable-numa
QEMU_L1_DEPENDENCIES += numactl
else
QEMU_L1_OPTS += --disable-numa
endif

ifeq ($(BR2_PACKAGE_SPICE),y)
QEMU_L1_OPTS += --enable-spice
QEMU_L1_DEPENDENCIES += spice
else
QEMU_L1_OPTS += --disable-spice
endif

ifeq ($(BR2_PACKAGE_USBREDIR),y)
QEMU_L1_OPTS += --enable-usb-redir
QEMU_L1_DEPENDENCIES += usbredir
else
QEMU_L1_OPTS += --disable-usb-redir
endif

ifeq ($(BR2_STATIC_LIBS),y)
QEMU_L1_OPTS += --static
endif

# Override CPP, as it expects to be able to call it like it'd
# call the compiler.
define QEMU_L1_CONFIGURE_CMDS
	unset TARGET_DIR; \
	cd $(@D); \
		LIBS='$(QEMU_L1_LIBS)' \
		$(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CONFIGURE_ARGS) \
		CPP="$(TARGET_CC) -E" \
		$(QEMU_L1_VARS) \
		./configure \
			--prefix=/usr \
			--cross-prefix=$(TARGET_CROSS) \
			--audio-drv-list= \
			--ninja=$(HOST_DIR)/bin/ninja \
			--disable-alsa \
			--disable-bpf \
			--disable-brlapi \
			--disable-bsd-user \
			--disable-cap-ng \
			--disable-capstone \
			--disable-containers \
			--disable-coreaudio \
			--disable-curl \
			--disable-curses \
			--disable-dbus-display \
			--disable-docs \
			--disable-dsound \
			--disable-hvf \
			--disable-jack \
			--disable-libiscsi \
			--disable-linux-aio \
			--disable-linux-io-uring \
			--disable-malloc-trim \
			--disable-membarrier \
			--disable-mpath \
			--disable-netmap \
			--disable-opengl \
			--disable-oss \
			--disable-pa \
			--disable-rbd \
			--disable-sanitizers \
			--disable-selinux \
			--disable-sparse \
			--disable-strip \
			--disable-vde \
			--disable-vhost-crypto \
			--disable-vhost-user-blk-server \
			--disable-whpx \
			--disable-xen \
			--enable-attr \
			--enable-kvm \
			--enable-vhost-net \
			--enable-virtfs \
			--enable-cap-ng \
			--with-git-submodules=ignore \
			$(QEMU_L1_OPTS)
endef

define QEMU_L1_BUILD_CMDS
	unset TARGET_DIR; \
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define QEMU_L1_INSTALL_TARGET_CMDS
	unset TARGET_DIR; \
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) $(QEMU_L1_MAKE_ENV) DESTDIR=$(TARGET_DIR) install
endef

$(eval $(generic-package))
