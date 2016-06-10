################################################################################
#
# s6-linux-init-services
#
################################################################################

# source included in buildroot
S6_LINUX_INIT_SERVICES_SOURCE =
S6_LINUX_INIT_SERVICES_DEPENDENCIES = s6-linux-init-skeleton

S6_LINUX_INIT_SERVICES_STORE = package/s6-linux-init-services/files/etc/s6-rc/source

ifeq ($(BR2_PACKAGE_DROPBEAR),y)
define S6_LINUX_INIT_SERVICES_DROPBEAR
	cp -a $(S6_LINUX_INIT_SERVICES_STORE)/dropbear \
		$(TARGET_DIR)/etc/s6-rc/source
	cp -a $(S6_LINUX_INIT_SERVICES_STORE)/dropbear-log \
		$(TARGET_DIR)/etc/s6-rc/source
	echo dropbear >> $(TARGET_DIR)/etc/s6-rc/source/bundle-lan/contents
endef
S6_LINUX_INIT_SERVICES_ITEMS += S6_LINUX_INIT_SERVICES_DROPBEAR
endif

ifeq ($(BR2_PACKAGE_RNG_TOOLS),y)
define S6_LINUX_INIT_SERVICES_RNGD
	cp -a $(S6_LINUX_INIT_SERVICES_STORE)/rngd \
		$(TARGET_DIR)/etc/s6-rc/source
	cp -a $(S6_LINUX_INIT_SERVICES_STORE)/rngd-log \
		$(TARGET_DIR)/etc/s6-rc/source
	echo rngd >> $(TARGET_DIR)/etc/s6-rc/source/bundle-local/contents
endef
S6_LINUX_INIT_SERVICES_ITEMS += S6_LINUX_INIT_SERVICES_RNGD
endif

define S6_LINUX_INIT_SERVICES_INSTALL_INIT_S6_INIT
	$(foreach item,$(S6_LINUX_INIT_SERVICES_ITEMS),$(call $(item))$(sep))
endef

$(eval $(generic-package))
