################################################################################
#
# s6-linux-init-skeleton
#
################################################################################

# source included in buildroot
S6_LINUX_INIT_SKELETON_SOURCE =
S6_LINUX_INIT_SKELETON_DEPENDENCIES = host-s6-rc

S6_LINUX_INIT_SKELETON_GETTY_PORT = $(call qstrip,$(BR2_TARGET_GENERIC_GETTY_PORT))
S6_LINUX_INIT_SKELETON_DHCP_IFACE = $(call qstrip,$(BR2_SYSTEM_DHCP))

define S6_LINUX_INIT_SKELETON_INSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/sbin/init
	rm -rf $(TARGET_DIR)/etc/s6-rc
	cp -a package/s6-linux-init-skeleton/files/* $(TARGET_DIR)/
endef

define S6_RENDER_TEMPLATE
	rm -rf $(TARGET_DIR)/etc/s6-rc/source/$(1)-$(2)$(3)
	cp -a $(TARGET_DIR)/etc/s6-rc/template/$(1)-@$(3) \
		$(TARGET_DIR)/etc/s6-rc/source/$(1)-$(2)$(3)
	$(SED) 's/@NAME@/$(2)/g' $(TARGET_DIR)/etc/s6-rc/source/$(1)-$(2)$(3)/*
endef

define S6_GEN_SERVICE
	$(call S6_RENDER_TEMPLATE,$(1),$(2))
	$(if $(3),$(call S6_RENDER_TEMPLATE,$(1),$(2),-log))
endef

define S6_ADD_SERVICE
	if ! grep -q $(1) $(TARGET_DIR)/etc/s6-rc/source/$(2)/contents; then \
		echo $(1) >> $(TARGET_DIR)/etc/s6-rc/source/$(2)/contents; \
	fi
endef

ifneq ($(S6_LINUX_INIT_SKELETON_DHCP_IFACE),)
define S6_LINUX_INIT_SKELETON_INSTALL_DHCPC
	$(call S6_GEN_SERVICE,udhcpc,$(S6_LINUX_INIT_SKELETON_DHCP_IFACE),y)
	$(call S6_ADD_SERVICE,udhcpc-$(S6_LINUX_INIT_SKELETON_DHCP_IFACE),services-lan)
	ln -sf ../run/resolv.conf $(TARGET_DIR)/etc/resolv.conf
endef
endif

ifneq ($(S6_LINUX_INIT_SKELETON_GETTY_PORT),)
define S6_LINUX_INIT_SKELETON_INSTALL_GETTY
	$(SED) 's/@NAME@/$(S6_LINUX_INIT_SKELETON_GETTY_PORT)/g' \
		$(TARGET_DIR)/etc/s6-init/run-image/service/getty/run
endef
endif

ifeq ($(BR2_TARGET_GENERIC_REMOUNT_ROOTFS_RW),y)
define S6_LINUX_INIT_SKELETON_REMOUNT_ROOTFS_RW
	echo yes > $(TARGET_DIR)/etc/s6-init/env/REMOUNT_ROOTFS_RW
endef
else
define S6_LINUX_INIT_SKELETON_REMOUNT_ROOTFS_RW
	echo no > $(TARGET_DIR)/etc/s6-init/env/REMOUNT_ROOTFS_RW
endef
endif

define S6_LINUX_INIT_SKELETON_BUILD_SERVICE_DB
	rm -rf ${TARGET_DIR}/etc/s6-rc/compiled
	$(HOST_DIR)/usr/bin/s6-rc-compile -v 3 \
		$(TARGET_DIR)/etc/s6-rc/compiled \
		$(TARGET_DIR)/etc/s6-rc/source
endef

TARGET_FINALIZE_HOOKS += S6_LINUX_INIT_SKELETON_INSTALL_GETTY
TARGET_FINALIZE_HOOKS += S6_LINUX_INIT_SKELETON_INSTALL_DHCPC
TARGET_FINALIZE_HOOKS += S6_LINUX_INIT_SKELETON_REMOUNT_ROOTFS_RW
TARGET_FINALIZE_HOOKS += S6_LINUX_INIT_SKELETON_BUILD_SERVICE_DB

define S6_LINUX_INIT_SKELETON_USERS
	fdh -1 fdh -1 - /home -
	log -1 log -1 - /var/log -
	fdhlog -1 fdhlog -1 - /var/log/fdholder -
	klog -1 klog -1 - /var/log/klogd -
	syslog -1 syslog -1 - /var/log/syslogd -
endef

$(eval $(generic-package))
