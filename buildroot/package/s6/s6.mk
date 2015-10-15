################################################################################
#
# s6
#
################################################################################

S6_VERSION = v2.2.2.0
S6_SITE = git://git.skarnet.org/s6.git
S6_LICENSE = ISC
S6_LICENSE_FILES = COPYING
S6_INSTALL_STAGING = YES
S6_DEPENDENCIES = execline

S6_CONFIGURE_OPTS = \
	--prefix=/usr \
	--with-sysdeps=$(STAGING_DIR)/usr/lib/skalibs/sysdeps \
	--with-include=$(STAGING_DIR)/usr/include \
	--with-dynlib=$(STAGING_DIR)/usr/lib \
	--with-lib=$(STAGING_DIR)/usr/lib/execline \
	--with-lib=$(STAGING_DIR)/usr/lib/skalibs

ifeq ($(BR2_STATIC_LIBS),y)
S6_CONFIGURE_OPTS +=  --enable-static --disable-shared
else
S6_CONFIGURE_OPTS +=  --disable-static --enable-shared --disable-allstatic
endif

define S6_CONFIGURE_CMDS
	(cd $(@D); $(TARGET_CONFIGURE_OPTS) ./configure $(S6_CONFIGURE_OPTS))
endef

define S6_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D)
endef

define S6_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

define S6_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) DESTDIR=$(STAGING_DIR) install
endef

HOST_S6_DEPENDENCIES = host-execline

HOST_S6_CONFIGURE_OPTS = \
	--prefix=/usr \
	--with-sysdeps=$(HOST_DIR)/usr/lib/skalibs/sysdeps \
	--with-include=$(HOST_DIR)/usr/include \
	--with-dynlib=$(HOST_DIR)/usr/lib \
	--disable-static \
	--enable-shared \
	--disable-allstatic

define HOST_S6_CONFIGURE_CMDS
	(cd $(@D); $(HOST_CONFIGURE_OPTS) ./configure $(HOST_S6_CONFIGURE_OPTS))
endef

define HOST_S6_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(HOST_DIR)
endef

define HOST_S6_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(HOST_DIR) \
		install-dynlib \
		install-include
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
