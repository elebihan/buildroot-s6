################################################################################
#
# s6-dns
#
################################################################################

S6_DNS_VERSION = v2.0.1.0
S6_DNS_SITE = git://git.skarnet.org/s6-dns.git
S6_DNS_LICENSE = ISC
S6_DNS_LICENSE_FILES = COPYING
S6_DNS_INSTALL_STAGING = YES
S6_DNS_DEPENDENCIES = skalibs

S6_DNS_CONFIGURE_OPTS = \
	--prefix=/usr \
	--with-sysdeps=$(STAGING_DIR)/usr/lib/skalibs/sysdeps \
	--with-include=$(STAGING_DIR)/usr/include \
	--with-dynlib=$(STAGING_DIR)/usr/lib \
	--with-lib=$(STAGING_DIR)/usr/lib/skalibs

ifeq ($(BR2_STATIC_LIBS),y)
S6_DNS_CONFIGURE_OPTS +=  --enable-static --disable-shared
else
S6_DNS_CONFIGURE_OPTS +=  --disable-static --enable-shared --disable-allstatic
endif

define S6_DNS_CONFIGURE_CMDS
	(cd $(@D); $(TARGET_CONFIGURE_OPTS) ./configure $(S6_DNS_CONFIGURE_OPTS))
endef

define S6_DNS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D)
endef

define S6_DNS_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

define S6_DNS_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) DESTDIR=$(STAGING_DIR) install
endef

$(eval $(generic-package))
