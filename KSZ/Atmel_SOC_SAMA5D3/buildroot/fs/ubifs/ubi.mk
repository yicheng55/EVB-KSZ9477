################################################################################
#
# Embed the ubifs image into an ubi image
#
################################################################################

UBI_UBINIZE_OPTS := -m $(BR2_TARGET_ROOTFS_UBIFS_MINIOSIZE)
UBI_UBINIZE_OPTS += -p $(BR2_TARGET_ROOTFS_UBI_PEBSIZE)
ifneq ($(BR2_TARGET_ROOTFS_UBI_SUBSIZE),0)
UBI_UBINIZE_OPTS += -s $(BR2_TARGET_ROOTFS_UBI_SUBSIZE)
endif

UBI_UBINIZE_OPTS += $(call qstrip,$(BR2_TARGET_ROOTFS_UBI_OPTS))

ROOTFS_UBI_DEPENDENCIES = rootfs-ubifs

ifeq ($(BR2_TARGET_ROOTFS_UBI_USE_CUSTOM_CONFIG),y)
UBINIZE_CONFIG_FILE_PATH = $(call qstrip,$(BR2_TARGET_ROOTFS_UBI_CUSTOM_CONFIG_FILE))
else
UBINIZE_CONFIG_FILE_PATH = $(TOPDIR)/fs/ubifs/ubinize.cfg
endif

# Prepare ubinize config before fakeroot
$(BINARIES_DIR)/rootfs.ubi: $(BUILD_DIR)/ubinize.cfg

$(BUILD_DIR)/ubinize.cfg: $(UBINIZE_CONFIG_FILE_PATH)
	$(INSTALL) -m 0644 $(UBINIZE_CONFIG_FILE_PATH) $@
	$(SED) 's;BR2_ROOTFS_UBIFS_PATH;$(BINARIES_DIR)/rootfs.ubifs;' $@

define ROOTFS_UBI_CMD
	$(HOST_DIR)/usr/sbin/ubinize -o $@ $(UBI_UBINIZE_OPTS) $(BUILD_DIR)/ubinize.cfg
endef

# Clean up after build
ROOTFS_UBI_POST_GEN_HOOKS += ROOTFS_UBI_CLEANUP

define ROOTFS_UBI_CLEANUP
	rm -f $(BUILD_DIR)/ubinize.cfg
endef

$(eval $(call ROOTFS_TARGET,ubi))
