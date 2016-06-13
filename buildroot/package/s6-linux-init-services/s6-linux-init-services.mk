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
