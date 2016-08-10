################################################################################
#
# s6-portable-utils
#
################################################################################

S6_PORTABLE_UTILS_VERSION = 2.0.6.0
S6_PORTABLE_UTILS_SITE = http://skarnet.org/software/s6-portable-utils
S6_PORTABLE_UTILS_LICENSE = ISC
S6_PORTABLE_UTILS_LICENSE_FILES = COPYING
S6_PORTABLE_UTILS_DEPENDENCIES = skalibs

S6_PORTABLE_UTILS_CONF_OPTS = \
	--prefix=/usr \
	--with-sysdeps=$(STAGING_DIR)/usr/lib/skalibs/sysdeps \
	--with-include=$(STAGING_DIR)/usr/include \
	--with-dynlib=$(STAGING_DIR)/usr/lib \
	--with-lib=$(STAGING_DIR)/usr/lib/skalibs

ifeq ($(BR2_STATIC_LIBS),y)
S6_PORTABLE_UTILS_CONF_OPTS +=  --enable-static --disable-shared
else
S6_PORTABLE_UTILS_CONF_OPTS +=  --disable-static --enable-shared --disable-allstatic
endif

define S6_PORTABLE_UTILS_CONFIGURE_CMDS
	(cd $(@D); $(TARGET_CONFIGURE_OPTS) ./configure $(S6_PORTABLE_UTILS_CONF_OPTS))
endef

define S6_PORTABLE_UTILS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D)
endef

define S6_PORTABLE_UTILS_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

$(eval $(generic-package))
