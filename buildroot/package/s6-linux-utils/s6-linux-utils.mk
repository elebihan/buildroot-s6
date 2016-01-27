################################################################################
#
# s6-linux-utils
#
################################################################################

S6_LINUX_UTILS_VERSION = v2.0.2.3
S6_LINUX_UTILS_SITE = git://git.skarnet.org/s6-linux-utils.git
S6_LINUX_UTILS_LICENSE = ISC
S6_LINUX_UTILS_LICENSE_FILES = COPYING
S6_LINUX_UTILS_DEPENDENCIES = skalibs

S6_LINUX_UTILS_CONFIGURE_OPTS = \
	--prefix=/usr \
	--with-sysdeps=$(STAGING_DIR)/usr/lib/skalibs/sysdeps \
	--with-include=$(STAGING_DIR)/usr/include \
	--with-dynlib=$(STAGING_DIR)/usr/lib \
	--with-lib=$(STAGING_DIR)/usr/lib/skalibs

ifeq ($(BR2_STATIC_LIBS),y)
S6_LINUX_UTILS_CONFIGURE_OPTS +=  --enable-static --disable-shared
else
S6_LINUX_UTILS_CONFIGURE_OPTS +=  --disable-static --enable-shared --disable-allstatic
endif

ifeq ($(BR2_TOOLCHAIN_USES_UCLIBC),y)
S6_LINUX_UTILS_CONFIGURE_ENV = LDFLAGS="-lrt"
endif

define S6_LINUX_UTILS_CONFIGURE_CMDS
	(cd $(@D); $(TARGET_CONFIGURE_OPTS) $(S6_LINUX_UTILS_CONFIGURE_ENV) \
		./configure $(S6_LINUX_UTILS_CONFIGURE_OPTS))
endef

define S6_LINUX_UTILS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D)
endef

define S6_LINUX_UTILS_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

$(eval $(generic-package))
