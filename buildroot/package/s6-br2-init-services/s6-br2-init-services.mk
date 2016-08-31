################################################################################
#
# s6-br2-init-skeleton
#
################################################################################

S6_BR2_INIT_SERVICES_VERSION = 0.2.0
S6_BR2_INIT_SERVICES_SITE = $(call github,elebihan,s6-br2-init-services,$(S6_BR2_INIT_SERVICES_VERSION))
S6_BR2_INIT_SERVICES_DEPENDENCIES = s6-br2-init-skeleton

S6_BR2_INIT_SERVICES_CONF_OPTS = \
	--prefix=/ \
	--services=$(shell echo $(S6_BR2_INIT_SERVICES_LIST) | sed -e 's/ /,/g')

define S6_BR2_INIT_SERVICES_CONFIGURE_CMDS
	(cd $(@D); ./configure $(S6_BR2_INIT_SERVICES_CONF_OPTS))
endef

define S6_BR2_INIT_SERVICES_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) DESTDIR=$(TARGET_DIR) -C $(@D) install
endef

ifeq ($(BR2_PACKAGE_DROPBEAR),y)
S6_BR2_INIT_SERVICES_LIST += dropbear
endif

ifneq ($(shell grep CONFIG_HTTPD=y $(BR2_PACKAGE_BUSYBOX_CONFIG) 2>/dev/null),)
S6_BR2_INIT_SERVICES_LIST += httpd
endif

ifeq ($(BR2_PACKAGE_NTP),y)
S6_BR2_INIT_SERVICES_LIST += ntpd
endif

ifeq ($(BR2_PACKAGE_RNG_TOOLS),y)
S6_BR2_INIT_SERVICES_LIST += rngd
endif

$(eval $(generic-package))
