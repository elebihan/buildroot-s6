################################################################################
#
# skalibs
#
################################################################################

SKALIBS_VERSION = v2.3.10.0
SKALIBS_SITE = git://git.skarnet.org/skalibs.git
SKALIBS_LICENSE = ISC
SKALIBS_LICENSE_FILES = COPYING
SKALIBS_INSTALL_STAGING = YES

SKALIBS_CONFIGURE_OPTS = \
	--prefix=/usr \
	--enable-force-devr \
	--with-default-path=/sbin:/usr/sbin:/bin:/usr/bin

ifeq ($(BR2_STATIC_LIBS),y)
SKALIBS_CONFIGURE_OPTS +=  --enable-static --disable-shared
else
SKALIBS_CONFIGURE_OPTS +=  --disable-static --enable-shared --disable-allstatic
endif

define SKALIBS_CONFIGURE_CMDS
	(cd $(@D); $(TARGET_CONFIGURE_OPTS) ./configure $(SKALIBS_CONFIGURE_OPTS))
endef

define SKALIBS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define SKALIBS_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

define SKALIBS_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
endef

HOST_SKALIBS_CONFIGURE_OPTS = \
	--prefix=/usr \
	--disable-static \
	--enable-shared \
	--disable-allstatic

define HOST_SKALIBS_CONFIGURE_CMDS
	(cd $(@D); $(HOST_CONFIGURE_OPTS) ./configure $(HOST_SKALIBS_CONFIGURE_OPTS))
endef

define HOST_SKALIBS_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(HOST_DIR)
endef

define HOST_SKALIBS_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(HOST_DIR) install
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
