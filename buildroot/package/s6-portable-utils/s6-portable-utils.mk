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
	--with-lib=$(STAGING_DIR)/usr/lib/skalibs \
	$(if $(BR2_STATIC_LIBS),,--disable-allstatic) \
	$(SHARED_STATIC_LIBS_OPTS)

S6_PORTABLE_UTILS_MAKE_OPTS = $(if $(BR2_TOOLCHAIN_USES_UCLIBC),LDLIBS=-lrt)

define S6_PORTABLE_UTILS_CONFIGURE_CMDS
	(cd $(@D); $(TARGET_CONFIGURE_OPTS) ./configure $(S6_PORTABLE_UTILS_CONF_OPTS))
endef

define S6_PORTABLE_UTILS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(S6_PORTABLE_UTILS_MAKE_OPTS) -C $(@D)
endef

define S6_PORTABLE_UTILS_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

$(eval $(generic-package))
