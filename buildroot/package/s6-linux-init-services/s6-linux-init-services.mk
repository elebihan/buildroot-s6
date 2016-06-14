################################################################################
#
# s6-linux-init-services
#
################################################################################

# source included in buildroot
S6_LINUX_INIT_SERVICES_SOURCE =
S6_LINUX_INIT_SERVICES_DEPENDENCIES = s6-linux-init-skeleton

S6_LINUX_INIT_SERVICES_STORE = package/s6-linux-init-services/files/etc/s6-rc/source

define S6_LINUX_INIT_SERVICES_INSTALL_SERVICE
	cp -a $(S6_LINUX_INIT_SERVICES_STORE)/$(1) \
		$(TARGET_DIR)/etc/s6-rc/source
	cp -a $(S6_LINUX_INIT_SERVICES_STORE)/$(1)-log \
		$(TARGET_DIR)/etc/s6-rc/source
	if ! grep -q $(1) $(TARGET_DIR)/etc/s6-rc/source/$(2)/contents; then \
		echo $(1) >> $(TARGET_DIR)/etc/s6-rc/source/$(2)/contents; \
	fi
endef

ifeq ($(BR2_PACKAGE_DROPBEAR),y)
define S6_LINUX_INIT_SERVICES_DROPBEAR
	$(call S6_LINUX_INIT_SERVICES_INSTALL_SERVICE,dropbear,bundle-lan)
endef
S6_LINUX_INIT_SERVICES_LIST += S6_LINUX_INIT_SERVICES_DROPBEAR
endif

ifneq ($(shell grep CONFIG_HTTPD=y $(BUSYBOX_BUILD_CONFIG) 2>/dev/null),)
define S6_LINUX_INIT_SERVICES_HTTPD
	$(call S6_LINUX_INIT_SERVICES_INSTALL_SERVICE,httpd,bundle-lan)
endef
S6_LINUX_INIT_SERVICES_LIST += S6_LINUX_INIT_SERVICES_HTTPD
endif

ifeq ($(BR2_PACKAGE_NTP),y)
define S6_LINUX_INIT_SERVICES_NTPD
	$(call S6_LINUX_INIT_SERVICES_INSTALL_SERVICE,ntpd,bundle-lan)
endef
S6_LINUX_INIT_SERVICES_LIST += S6_LINUX_INIT_SERVICES_NTPD
endif

ifeq ($(BR2_PACKAGE_RNG_TOOLS),y)
define S6_LINUX_INIT_SERVICES_RNGD
	$(call S6_LINUX_INIT_SERVICES_INSTALL_SERVICE,rngd,bundle-local)
endef
S6_LINUX_INIT_SERVICES_LIST += S6_LINUX_INIT_SERVICES_RNGD
endif

define S6_LINUX_INIT_SERVICES_INSTALL_INIT_S6_INIT
	$(foreach entry,$(S6_LINUX_INIT_SERVICES_LIST),$(call $(entry))$(sep))
endef

$(eval $(generic-package))
