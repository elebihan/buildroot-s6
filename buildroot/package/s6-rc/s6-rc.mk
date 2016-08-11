################################################################################
#
# s6-rc
#
################################################################################

S6_RC_VERSION = 0.0.3.0
S6_RC_SITE = http://skarnet.org/software/s6-rc
S6_RC_LICENSE = ISC
S6_RC_LICENSE_FILES = COPYING
S6_RC_INSTALL_STAGING = YES
S6_RC_DEPENDENCIES = s6

S6_RC_CONF_OPTS = \
	--prefix=/usr \
	--with-sysdeps=$(STAGING_DIR)/usr/lib/skalibs/sysdeps \
	--with-include=$(STAGING_DIR)/usr/include \
	--with-dynlib=$(STAGING_DIR)/usr/lib \
	--with-lib=$(STAGING_DIR)/usr/lib/execline \
	--with-lib=$(STAGING_DIR)/usr/lib/s6 \
	--with-lib=$(STAGING_DIR)/usr/lib/skalibs \
	$(if $(BR2_STATIC_LIBS),,--disable-allstatic) \
	$(SHARED_STATIC_LIBS_OPTS)

S6_RC_MAKE_OPTS = $(if $(BR2_TOOLCHAIN_USES_UCLIBC),LDLIBS=-lrt)

define S6_RC_CONFIGURE_CMDS
	(cd $(@D); $(TARGET_CONFIGURE_OPTS) ./configure $(S6_RC_CONF_OPTS))
endef

define S6_RC_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(S6_RC_MAKE_OPTS) -C $(@D)
endef

define S6_RC_REMOVE_STATIC_LIB_DIR
	rm -rf $(TARGET_DIR)/usr/lib/s6-rc
endef

S6_RC_POST_INSTALL_TARGET_HOOKS += S6_RC_REMOVE_STATIC_LIB_DIR

define S6_RC_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

define S6_RC_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
endef

HOST_S6_RC_DEPENDENCIES = host-s6

HOST_S6_RC_CONF_OPTS = \
	--prefix=/usr \
	--with-sysdeps=$(HOST_DIR)/usr/lib/skalibs/sysdeps \
	--with-include=$(HOST_DIR)/usr/include \
	--with-dynlib=$(HOST_DIR)/usr/lib \
	--disable-static \
	--enable-shared \
	--disable-allstatic

define HOST_S6_RC_CONFIGURE_CMDS
	(cd $(@D); $(HOST_CONFIGURE_OPTS) ./configure $(HOST_S6_RC_CONF_OPTS))
endef

define HOST_S6_RC_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(HOST_DIR)
endef

define HOST_S6_RC_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(HOST_DIR) \
		install-dynlib \
		install-bin
	rm -f $(HOST_DIR)/usr/bin/s6-rc-dryrun
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
