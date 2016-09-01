################################################################################
#
# s6-br2-init-skeleton
#
################################################################################

S6_BR2_INIT_SKELETON_VERSION = 0.2.0
S6_BR2_INIT_SKELETON_SITE = $(call github,elebihan,s6-br2-init-skeleton,$(S6_BR2_INIT_SKELETON_VERSION))
S6_BR2_INIT_SKELETON_DEPENDENCIES = host-s6-rc host-s6-br2-init-skeleton

S6_BR2_INIT_SKELETON_GETTY_PORT = $(call qstrip,$(BR2_TARGET_GENERIC_GETTY_PORT))
S6_BR2_INIT_SKELETON_DHCP_IFACE = $(call qstrip,$(BR2_SYSTEM_DHCP))

S6_RC_SOURCE_TOOL = $(HOST_DIR)/usr/bin/s6-rc-source

ifeq ($(BR2_PACKAGE_BUSYBOX_WATCHDOG),y)
define S6_BR2_INIT_SKELETON_ENABLE_WATCHDOG
	$(S6_RC_SOURCE_TOOL) add watchdog services-local \
		$(TARGET_DIR)/etc/s6-rc/source
	echo $(call qstrip,$(BR2_PACKAGE_BUSYBOX_WATCHDOG_PERIOD)) \
		> $(TARGET_DIR)/etc/s6-rc/source/watchdog/env/PERIOD
endef
S6_BR2_INIT_SKELETON_POST_INSTALL_TARGET_HOOKS += \
	S6_BR2_INIT_SKELETON_ENABLE_WATCHDOG
endif

S6_BR2_INIT_SKELETON_CONF_OPTS = \
	--prefix=/ \
	--enable-sbin-init=yes \
	--enable-debug-console=no

define S6_BR2_INIT_SKELETON_CONFIGURE_CMDS
	(cd $(@D); ./configure $(S6_BR2_INIT_SKELETON_CONF_OPTS))
endef

define S6_BR2_INIT_SKELETON_INSTALL_TARGET_CMDS
	$(MAKE) DESTDIR=$(TARGET_DIR) -C $(@D) install
endef

ifneq ($(S6_BR2_INIT_SKELETON_DHCP_IFACE),)
define S6_BR2_INIT_SKELETON_MANAGE_DHCPC
	$(S6_RC_SOURCE_TOOL) render udhcpc-@ default setup-net \
		$(TARGET_DIR)/etc/s6-rc/source
	echo $(S6_BR2_INIT_SKELETON_DHCP_IFACE) > \
		$(TARGET_DIR)/etc/s6-rc/source/udhcpc-default/env/INTERFACE
	ln -sf ../run/resolv.conf $(TARGET_DIR)/etc/resolv.conf
endef
else
define S6_BR2_INIT_SKELETON_MANAGE_DHCPC
	$(S6_RC_SOURCE_TOOL) del -p udhcpc-default setup-net \
		$(TARGET_DIR)/etc/s6-rc/source
endef
endif

ifneq ($(S6_BR2_INIT_SKELETON_GETTY_PORT),)
define S6_BR2_INIT_SKELETON_MANAGE_GETTY
	echo $(S6_BR2_INIT_SKELETON_GETTY_PORT) > \
		$(TARGET_DIR)/etc/s6-init/run-image/service/getty/env/TTY
	rm -f $(TARGET_DIR)/etc/s6-init/run-image/service/getty/down
endef
else
define S6_BR2_INIT_SKELETON_MANAGE_GETTY
	touch $(TARGET_DIR)/etc/s6-init/run-image/service/getty/down
endef
endif

ifeq ($(BR2_TARGET_GENERIC_REMOUNT_ROOTFS_RW),y)
define S6_BR2_INIT_SKELETON_REMOUNT_ROOTFS_RW
	echo yes > $(TARGET_DIR)/etc/s6-init/env/REMOUNT_ROOTFS_RW
endef
else
define S6_BR2_INIT_SKELETON_REMOUNT_ROOTFS_RW
	echo no > $(TARGET_DIR)/etc/s6-init/env/REMOUNT_ROOTFS_RW
endef
endif

define S6_BR2_INIT_SKELETON_BUILD_SERVICE_DB
	rm -rf ${TARGET_DIR}/etc/s6-rc/compiled
	$(HOST_DIR)/usr/bin/s6-rc-compile -v 3 \
		$(TARGET_DIR)/etc/s6-rc/compiled \
		$(TARGET_DIR)/etc/s6-rc/source
endef

TARGET_FINALIZE_HOOKS += S6_BR2_INIT_SKELETON_MANAGE_GETTY
TARGET_FINALIZE_HOOKS += S6_BR2_INIT_SKELETON_MANAGE_DHCPC
TARGET_FINALIZE_HOOKS += S6_BR2_INIT_SKELETON_REMOUNT_ROOTFS_RW
TARGET_FINALIZE_HOOKS += S6_BR2_INIT_SKELETON_BUILD_SERVICE_DB

define S6_BR2_INIT_SKELETON_USERS
	fdh -1 fdh -1 - /home -
	log -1 log -1 - /var/log -
	fdhlog -1 fdhlog -1 - /var/log/fdholder -
	klog -1 klog -1 - /var/log/klogd -
	syslog -1 syslog -1 - /var/log/syslogd -
endef

define HOST_S6_BR2_INIT_SKELETON_INSTALL_CMDS
	install -D -m 0755 $(@D)/tools/s6-rc-source $(HOST_DIR)/usr/bin
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
