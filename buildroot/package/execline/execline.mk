################################################################################
#
# execline
#
################################################################################

EXECLINE_VERSION = v2.1.4.2
EXECLINE_SITE = git://git.skarnet.org/execline.git
EXECLINE_LICENSE = ISC
EXECLINE_LICENSE_FILES = COPYING
EXECLINE_INSTALL_STAGING = YES
EXECLINE_DEPENDENCIES = skalibs

EXECLINE_CONFIGURE_OPTS = \
	--prefix=/usr \
	--with-sysdeps=$(STAGING_DIR)/usr/lib/skalibs/sysdeps \
	--with-include=$(STAGING_DIR)/usr/include \
	--with-dynlib=$(STAGING_DIR)/usr/lib \
	--with-lib=$(STAGING_DIR)/usr/lib/skalibs

ifeq ($(BR2_STATIC_LIBS),y)
EXECLINE_CONFIGURE_OPTS +=  --enable-static --disable-shared
else
EXECLINE_CONFIGURE_OPTS +=  --disable-static --enable-shared --disable-allstatic
endif

define EXECLINE_CONFIGURE_CMDS
	(cd $(@D); $(TARGET_CONFIGURE_OPTS) ./configure $(EXECLINE_CONFIGURE_OPTS))
endef

define EXECLINE_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D)
endef

define EXECLINE_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

define EXECLINE_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) DESTDIR=$(STAGING_DIR) install
endef

HOST_EXECLINE_DEPENDENCIES = host-skalibs

HOST_EXECLINE_CONFIGURE_OPTS = \
	--prefix=/usr \
	--with-sysdeps=$(HOST_DIR)/usr/lib/skalibs/sysdeps \
	--with-include=$(HOST_DIR)/usr/include \
	--with-dynlib=$(HOST_DIR)/usr/lib \
	--disable-static \
	--enable-shared \
	--disable-allstatic

define HOST_EXECLINE_CONFIGURE_CMDS
	(cd $(@D); $(HOST_CONFIGURE_OPTS) ./configure $(HOST_EXECLINE_CONFIGURE_OPTS))
endef

define HOST_EXECLINE_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(HOST_DIR)
endef

define HOST_EXECLINE_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(HOST_DIR) install
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
