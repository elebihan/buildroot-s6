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

S6_RC_SOURCE_TOOL = package/s6-linux-init-skeleton/s6-rc-source

ifeq ($(BR2_PACKAGE_BUSYBOX_WATCHDOG),y)
define S6_LINUX_INIT_SKELETON_ENABLE_WATCHDOG
	$(S6_RC_SOURCE_TOOL) add watchdog services-local \
		$(TARGET_DIR)/etc/s6-rc/source
	echo $(call qstrip,$(BR2_PACKAGE_BUSYBOX_WATCHDOG_PERIOD)) \
		> $(TARGET_DIR)/etc/s6-rc/source/watchdog/env/PERIOD
endef
S6_LINUX_INIT_SKELETON_POST_INSTALL_TARGET_HOOKS += \
	S6_LINUX_INIT_SKELETON_ENABLE_WATCHDOG
endif

define S6_LINUX_INIT_SKELETON_INSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/sbin/init
	rm -rf $(TARGET_DIR)/etc/s6-rc
	cp -a package/s6-linux-init-skeleton/files/* $(TARGET_DIR)/
endef

ifneq ($(S6_LINUX_INIT_SKELETON_DHCP_IFACE),)
define S6_LINUX_INIT_SKELETON_MANAGE_DHCPC
	$(S6_RC_SOURCE_TOOL) render udhcpc-@ default setup-net \
		$(TARGET_DIR)/etc/s6-rc/source
	echo $(S6_LINUX_INIT_SKELETON_DHCP_IFACE) > \
		$(TARGET_DIR)/etc/s6-rc/source/udhcpc-default/env/INTERFACE
	ln -sf ../run/resolv.conf $(TARGET_DIR)/etc/resolv.conf
endef
else
define S6_LINUX_INIT_SKELETON_MANAGE_DHCPC
	$(S6_RC_SOURCE_TOOL) del -p udhcpc-default setup-net \
		$(TARGET_DIR)/etc/s6-rc/source
endef
endif

ifneq ($(S6_LINUX_INIT_SKELETON_GETTY_PORT),)
define S6_LINUX_INIT_SKELETON_MANAGE_GETTY
	echo $(S6_LINUX_INIT_SKELETON_GETTY_PORT) > \
		$(TARGET_DIR)/etc/s6-init/run-image/service/getty/env/TTY
	rm -f $(TARGET_DIR)/etc/s6-init/run-image/service/getty/down
endef
else
define S6_LINUX_INIT_SKELETON_MANAGE_GETTY
	touch $(TARGET_DIR)/etc/s6-init/run-image/service/getty/down
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

TARGET_FINALIZE_HOOKS += S6_LINUX_INIT_SKELETON_MANAGE_GETTY
TARGET_FINALIZE_HOOKS += S6_LINUX_INIT_SKELETON_MANAGE_DHCPC
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
