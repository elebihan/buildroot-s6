################################################################################
#
# s6-linux-init-services
#
################################################################################

# source included in buildroot
S6_LINUX_INIT_SERVICES_SOURCE =
S6_LINUX_INIT_SERVICES_DEPENDENCIES = s6-linux-init-skeleton

S6_LINUX_INIT_SERVICES_STORE = package/s6-linux-init-services/files/etc/s6-rc/source

define S6_LINUX_INIT_SERVICES_INSTALL_INIT_S6_INIT
	$(foreach item,$(S6_LINUX_INIT_SERVICES_ITEMS),$(call $(item))$(sep))
endef

$(eval $(generic-package))
