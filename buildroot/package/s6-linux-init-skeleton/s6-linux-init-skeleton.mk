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

ifneq ($(S6_LINUX_INIT_SKELETON_DHCP_IFACE),)
define S6_LINUX_INIT_SKELETON_INSTALL_DHCPC
	cp -a $(TARGET_DIR)/etc/s6-rc/template/udhcpc-@ \
		$(TARGET_DIR)/etc/s6-rc/source/udhcpc-$(S6_LINUX_INIT_SKELETON_DHCP_IFACE)
	sed -i -e 's/@NAME@/$(S6_LINUX_INIT_SKELETON_DHCP_IFACE)/g' \
		$(TARGET_DIR)/etc/s6-rc/source/udhcpc-$(S6_LINUX_INIT_SKELETON_DHCP_IFACE)/*
	cp -a $(TARGET_DIR)/etc/s6-rc/template/udhcpc-@-log \
		$(TARGET_DIR)/etc/s6-rc/source/udhcpc-$(S6_LINUX_INIT_SKELETON_DHCP_IFACE)-log
	sed -i -e 's/@NAME@/$(S6_LINUX_INIT_SKELETON_DHCP_IFACE)/g' \
		$(TARGET_DIR)/etc/s6-rc/source/udhcpc-$(S6_LINUX_INIT_SKELETON_DHCP_IFACE)-log/*
	echo udhcpc-$(S6_LINUX_INIT_SKELETON_DHCP_IFACE) >> \
		$(TARGET_DIR)/etc/s6-rc/source/bundle-lan/contents
	ln -sf ../run/resolv.conf $(TARGET_DIR)/etc/resolv.conf
endef
endif

ifneq ($(S6_LINUX_INIT_SKELETON_GETTY_PORT),)
define S6_LINUX_INIT_SKELETON_INSTALL_GETTY
	sed -i -e 's/@NAME@/$(S6_LINUX_INIT_SKELETON_GETTY_PORT)/g' \
		$(TARGET_DIR)/etc/s6-init/run-image/service/getty/run
endef
endif

define S6_LINUX_INIT_SKELETON_INSTALL_INIT_S6_INIT
	$(S6_LINUX_INIT_SKELETON_INSTALL_GETTY)
	$(S6_LINUX_INIT_SKELETON_INSTALL_DHCPC)
endef

define S6_LINUX_INIT_SKELETON_BUILD_SERVICE_DB
	rm -rf ${TARGET_DIR}/etc/s6-rc/compiled
	$(HOST_DIR)/usr/bin/s6-rc-compile -v 3 \
		$(TARGET_DIR)/etc/s6-rc/compiled \
		$(TARGET_DIR)/etc/s6-rc/source
endef

TARGET_FINALIZE_HOOKS += S6_LINUX_INIT_SKELETON_BUILD_SERVICE_DB

define S6_LINUX_INIT_SKELETON_USERS
	fdh -1 fdh -1 - /home -
	log -1 log -1 - /var/log -
	fdhlog -1 fdhlog -1 - /var/log/fdholder -
	klog -1 klog -1 - /var/log/klogd -
	syslog -1 syslog -1 - /var/log/syslogd -
endef

$(eval $(generic-package))
