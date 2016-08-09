################################################################################
#
# s6-networking
#
################################################################################

S6_NETWORKING_VERSION = 2.1.1.0
S6_NETWORKING_SITE = http://skarnet.org/software/s6-networking
S6_NETWORKING_LICENSE = ISC
S6_NETWORKING_LICENSE_FILES = COPYING
S6_NETWORKING_INSTALL_STAGING = YES
S6_NETWORKING_DEPENDENCIES = s6-dns s6

S6_NETWORKING_CONFIGURE_OPTS = \
	--prefix=/usr \
	--with-sysdeps=$(STAGING_DIR)/usr/lib/skalibs/sysdeps \
	--with-include=$(STAGING_DIR)/usr/include \
	--with-dynlib=$(STAGING_DIR)/usr/lib \
	--with-lib=$(STAGING_DIR)/usr/lib/execline \
	--with-lib=$(STAGING_DIR)/usr/lib/s6 \
	--with-lib=$(STAGING_DIR)/usr/lib/s6-dns \
	--with-lib=$(STAGING_DIR)/usr/lib/skalibs

ifeq ($(BR2_STATIC_LIBS),y)
S6_NETWORKING_CONFIGURE_OPTS +=  --enable-static --disable-shared
else
S6_NETWORKING_CONFIGURE_OPTS +=  --disable-static --enable-shared --disable-allstatic
endif

define S6_NETWORKING_CONFIGURE_CMDS
	(cd $(@D); $(TARGET_CONFIGURE_OPTS) ./configure $(S6_NETWORKING_CONFIGURE_OPTS))
endef

define S6_NETWORKING_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D)
endef

define S6_NETWORKING_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

define S6_NETWORKING_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) DESTDIR=$(STAGING_DIR) install
endef

$(eval $(generic-package))
