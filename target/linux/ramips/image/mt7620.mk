#
# MT7620A Profiles
#

define Build/tplink-header
	$(STAGING_DIR_HOST)/bin/mktplinkfw2 -a 0x4 -V "ver. 2.0" -B $(1) \
		-o $@.new -k $@ -r $(IMAGE_ROOTFS) && mv $@.new $@
endef

define Build/pad-kernel-ex2700
	cp $@ $@.tmp && dd if=/dev/zero bs=64 count=1 >> $@.tmp \
		&& dd if=$@.tmp of=$@.new bs=64k conv=sync && truncate -s -64 $@.new \
		&& cat ex2700-fakeroot.uImage >> $@.new && rm $@.tmp && mv $@.new $@
endef

define Build/netgear-header
	$(STAGING_DIR_HOST)/bin/mkdniimg \
		$(1) -v OpenWrt -i $@ \
		-o $@.new && mv $@.new $@
endef

define Build/elecom-header
	cp $@ $(KDIR)/v_0.0.0.bin
	( \
		mkhash md5 $(KDIR)/v_0.0.0.bin && \
		echo 458 \
	) | mkhash md5 > $(KDIR)/v_0.0.0.md5
	$(STAGING_DIR_HOST)/bin/tar -cf $@ -C $(KDIR) v_0.0.0.bin v_0.0.0.md5
endef

define Build/zyimage
	$(STAGING_DIR_HOST)/bin/zyimage $(1) $@
endef

define Device/ArcherC20i
  DTS := ArcherC20i
  SUPPORTED_DEVICES := c20i
  KERNEL := $(KERNEL_DTB)
  KERNEL_INITRAMFS := $(KERNEL_DTB) | tplink-header ArcherC20i -c
  IMAGE/factory.bin := append-kernel | tplink-header ArcherC20i -j
  IMAGE/sysupgrade.bin := append-kernel | tplink-header ArcherC20i -j -s | append-metadata
  IMAGES += factory.bin
  DEVICE_TITLE := TP-Link ArcherC20i
endef
TARGET_DEVICES += ArcherC20i

define Device/ArcherC50
  DTS := ArcherC50
  SUPPORTED_DEVICES := c50
  KERNEL := $(KERNEL_DTB)
  KERNEL_INITRAMFS := $(KERNEL_DTB) | tplink-header ArcherC50 -c
  IMAGE/factory.bin := append-kernel | tplink-header ArcherC50 -j
  IMAGE/sysupgrade.bin := append-kernel | tplink-header ArcherC50 -j -s | append-metadata
  IMAGES += factory.bin
  DEVICE_TITLE := TP-Link ArcherC50
endef
TARGET_DEVICES += ArcherC50

define Device/ArcherMR200
  DTS := ArcherMR200
  SUPPORTED_DEVICES := mr200
  KERNEL := $(KERNEL_DTB)
  KERNEL_INITRAMFS := $(KERNEL_DTB) | tplink-header ArcherMR200 -c
  IMAGE/sysupgrade.bin := append-kernel | tplink-header ArcherMR200 -j -s | append-metadata
  DEVICE_PACKAGES := kmod-usb2 kmod-usb-net kmod-usb-net-rndis kmod-usb-serial kmod-usb-serial-option adb
  DEVICE_TITLE := TP-Link ArcherMR200
endef
TARGET_DEVICES += ArcherMR200

define Device/ex2700
  DTS := EX2700
  BLOCKSIZE := 4k
  IMAGE_SIZE := $(ralink_default_fw_size_4M)
  IMAGES += factory.bin
  KERNEL := $(KERNEL_DTB) | uImage lzma | pad-kernel-ex2700
  IMAGE/factory.bin := $$(sysupgrade_bin) | check-size $$$$(IMAGE_SIZE) | \
	netgear-header -B EX2700 -H 29764623+4+0+32+2x2+0
  DEVICE_TITLE := Netgear EX2700
endef
TARGET_DEVICES += ex2700

define Device/wn3000rpv3
  DTS := WN3000RPV3
  BLOCKSIZE := 4k
  IMAGES += factory.bin
  KERNEL := $(KERNEL_DTB) | uImage lzma | pad-kernel-ex2700
  IMAGE/factory.bin := $$(sysupgrade_bin) | check-size $$$$(IMAGE_SIZE) | \
	netgear-header -B WN3000RPv3 -H 29764836+8+0+32+2x2+0
  DEVICE_TITLE := Netgear WN3000RPv3
endef
TARGET_DEVICES += wn3000rpv3

define Device/wt3020-4M
  DTS := WT3020-4M
  BLOCKSIZE := 4k
  IMAGE_SIZE := $(ralink_default_fw_size_4M)
  IMAGES += factory.bin
  IMAGE/factory.bin := $$(sysupgrade_bin) | check-size $$$$(IMAGE_SIZE) | \
	poray-header -B WT3020 -F 4M
  DEVICE_TITLE := Nexx WT3020 (4MB)
endef
TARGET_DEVICES += wt3020-4M

define Device/wt3020-8M
  DTS := WT3020-8M
  IMAGES += factory.bin
  IMAGE/factory.bin := $$(sysupgrade_bin) | check-size $$$$(IMAGE_SIZE) | \
	poray-header -B WT3020 -F 8M
  DEVICE_TITLE := Nexx WT3020 (8MB)
  DEVICE_PACKAGES := kmod-usb2 kmod-usb-ohci
endef
TARGET_DEVICES += wt3020-8M

define Device/wrh-300cr
  DTS := WRH-300CR
  IMAGE_SIZE := $(ralink_default_fw_size_16M)
  IMAGES += factory.bin
  IMAGE/factory.bin := $$(sysupgrade_bin) | check-size $$$$(IMAGE_SIZE) | \
	elecom-header
  DEVICE_TITLE := Elecom WRH-300CR 
  DEVICE_PACKAGES := kmod-usb2 kmod-usb-ohci
endef
TARGET_DEVICES += wrh-300cr

define Device/e1700
  DTS := E1700
  IMAGES += factory.bin
  IMAGE/factory.bin := $$(sysupgrade_bin) | check-size $$$$(IMAGE_SIZE) | \
	umedia-header 0x013326
  DEVICE_TITLE := Linksys E1700
endef
TARGET_DEVICES += e1700

define Device/ai-br100
  DTS := AI-BR100
  IMAGE_SIZE := 7936k
  DEVICE_TITLE := Aigale Ai-BR100
  DEVICE_PACKAGES:= kmod-usb2 kmod-usb-ohci
endef
TARGET_DEVICES += ai-br100

define Device/whr-300hp2
  DTS := WHR-300HP2
  IMAGE_SIZE := 6848k
  DEVICE_TITLE := Buffalo WHR-300HP2
endef
TARGET_DEVICES += whr-300hp2

define Device/whr-600d
  DTS := WHR-600D
  IMAGE_SIZE := 6848k
  DEVICE_TITLE := Buffalo WHR-600D
endef
TARGET_DEVICES += whr-600d

define Device/whr-1166d
  DTS := WHR-1166D
  IMAGE_SIZE := 15040k
  DEVICE_TITLE := Buffalo WHR-1166D
endef
TARGET_DEVICES += whr-1166d

define Device/dir-810l
  DTS := DIR-810L
  IMAGE_SIZE := 6720k
  DEVICE_TITLE := D-Link DIR-810L
endef
TARGET_DEVICES += dir-810l

define Device/na930
  DTS := NA930
  IMAGE_SIZE := 20m
  DEVICE_TITLE := Sercomm NA930
endef
TARGET_DEVICES += na930

define Device/microwrt
  DTS := MicroWRT
  IMAGE_SIZE := 16128k
  DEVICE_TITLE := Microduino MicroWRT
endef
TARGET_DEVICES += microwrt

define Device/mt7620a
  DTS := MT7620a
  DEVICE_TITLE := MediaTek MT7620a EVB
endef
TARGET_DEVICES += mt7620a

define Device/mt7620a_mt7610e
  DTS := MT7620a_MT7610e
  DEVICE_TITLE := MediaTek MT7620a + MT7610e EVB
endef
TARGET_DEVICES += mt7620a_mt7610e

define Device/mt7620a_mt7530
  DTS := MT7620a_MT7530
  DEVICE_TITLE := MediaTek MT7620a + MT7530 EVB
endef
TARGET_DEVICES += mt7620a_mt7530

define Device/mt7620a_v22sg
  DTS := MT7620a_V22SG
  DEVICE_TITLE := MediaTek MT7620a V22SG
endef
TARGET_DEVICES += mt7620a_v22sg

define Device/rp-n53
  DTS := RP-N53
  DEVICE_TITLE := Asus RP-N53
endef
TARGET_DEVICES += rp-n53

define Device/cf-wr800n
  DTS := CF-WR800N
  DEVICE_TITLE := Comfast CF-WR800N
endef
TARGET_DEVICES += cf-wr800n

define Device/cs-qr10
  DTS := CS-QR10
  DEVICE_TITLE := Planex CS-QR10
  DEVICE_PACKAGES := kmod-usb2 kmod-usb-ohci \
	kmod-sound-core kmod-sound-mt7620 \
	kmod-i2c-ralink kmod-sdhci-mt7620
endef
TARGET_DEVICES += cs-qr10

define Device/db-wrt01
  DTS := DB-WRT01
  DEVICE_TITLE := Planex DB-WRT01
endef
TARGET_DEVICES += db-wrt01

define Device/mzk-750dhp
  DTS := MZK-750DHP
  DEVICE_TITLE := Planex MZK-750DHP
  DEVICE_PACKAGES := kmod-mt76
endef
TARGET_DEVICES += mzk-750dhp

define Device/mzk-ex300np
  DTS := MZK-EX300NP
  DEVICE_TITLE := Planex MZK-EX300NP
endef
TARGET_DEVICES += mzk-ex300np

define Device/mzk-ex750np
  DTS := MZK-EX750NP
  DEVICE_TITLE := Planex MZK-EX750NP
  DEVICE_PACKAGES := kmod-mt76
endef
TARGET_DEVICES += mzk-ex750np

define Device/hc5661
  DTS := HC5661
  IMAGE_SIZE := $(ralink_default_fw_size_16M)
  DEVICE_TITLE := HiWiFi HC5661
  DEVICE_PACKAGES := kmod-usb2 kmod-sdhci kmod-sdhci-mt7620 kmod-usb-ledtrig-usbport
endef
TARGET_DEVICES += hc5661

define Device/hc5761
  DTS := HC5761
  IMAGE_SIZE := $(ralink_default_fw_size_16M)
  DEVICE_TITLE := HiWiFi HC5761 
  DEVICE_PACKAGES := kmod-usb2 kmod-usb-ohci kmod-sdhci kmod-sdhci-mt7620 kmod-usb-ledtrig-usbport
endef
TARGET_DEVICES += hc5761

define Device/hc5861
  DTS := HC5861
  IMAGE_SIZE := $(ralink_default_fw_size_16M)
  DEVICE_TITLE := HiWiFi HC5861
  DEVICE_PACKAGES := kmod-usb2 kmod-usb-ohci kmod-sdhci kmod-sdhci-mt7620 kmod-usb-ledtrig-usbport
endef
TARGET_DEVICES += hc5861

define Device/oy-0001
  DTS := OY-0001
  IMAGE_SIZE := $(ralink_default_fw_size_16M)
  DEVICE_TITLE := Oh Yeah OY-0001
endef
TARGET_DEVICES += oy-0001

define Device/psg1208
  DTS := PSG1208
  DEVICE_TITLE := Phicomm PSG1208
  DEVICE_PACKAGES := kmod-mt76
endef
TARGET_DEVICES += psg1208

define Device/psg1218
  DTS := PSG1218
  DEVICE_TITLE := Phicomm PSG1218
  DEVICE_PACKAGES := kmod-mt76
endef
TARGET_DEVICES += psg1218

define Device/y1
  DTS := Y1
  IMAGE_SIZE := $(ralink_default_fw_size_16M)
  DEVICE_TITLE := Lenovo Y1
endef
TARGET_DEVICES += y1

define Device/y1s
  DTS := Y1S
  IMAGE_SIZE := $(ralink_default_fw_size_16M)
  DEVICE_TITLE := Lenovo Y1S
  DEVICE_PACKAGES := kmod-usb-ohci kmod-usb2
endef
TARGET_DEVICES += y1s

define Device/mlw221
  DTS := MLW221
  IMAGE_SIZE := $(ralink_default_fw_size_16M)
  DEVICE_TITLE := Kingston MLW221
endef
TARGET_DEVICES += mlw221

define Device/mlwg2
  DTS := MLWG2
  IMAGE_SIZE := $(ralink_default_fw_size_16M)
  DEVICE_TITLE := Kingston MLWG2
endef
TARGET_DEVICES += mlwg2

define Device/wmr-300
  DTS := WMR-300
  DEVICE_TITLE := Buffalo WMR-300
endef
TARGET_DEVICES += wmr-300

define Device/rt-n14u
  DTS := RT-N14U
  DEVICE_TITLE := Asus RT-N14u
endef
TARGET_DEVICES += rt-n14u

define Device/wrtnode
  DTS := WRTNODE
  IMAGE_SIZE := $(ralink_default_fw_size_16M)
  DEVICE_TITLE := WRTNode
endef
TARGET_DEVICES += wrtnode

define Device/miwifi-mini
  DTS := MIWIFI-MINI
  IMAGE_SIZE := $(ralink_default_fw_size_16M)
  DEVICE_TITLE := Xiaomi MiWiFi Mini
  DEVICE_PACKAGES := kmod-usb2 kmod-usb-ohci
endef
TARGET_DEVICES += miwifi-mini

define Device/gl-mt300a
  DTS := GL-MT300A
  IMAGE_SIZE := $(ralink_default_fw_size_16M)
  DEVICE_TITLE := GL-Inet GL-MT300A
  DEVICE_PACKAGES := kmod-usb2 kmod-usb-ohci kmod-mt76
endef
TARGET_DEVICES += gl-mt300a

define Device/gl-mt300n
  DTS := GL-MT300N
  IMAGE_SIZE := $(ralink_default_fw_size_16M)
  DEVICE_TITLE := GL-Inet GL-MT300N
  DEVICE_PACKAGES := kmod-usb2 kmod-usb-ohci kmod-mt76
endef
TARGET_DEVICES += gl-mt300n

define Device/gl-mt750
  DTS := GL-MT750
  IMAGE_SIZE := $(ralink_default_fw_size_16M)
  DEVICE_TITLE := GL-Inet GL-MT750
  DEVICE_PACKAGES := kmod-usb2 kmod-usb-ohci kmod-mt76
endef
TARGET_DEVICES += gl-mt750

define Device/zte-q7
  DTS := ZTE-Q7
  DEVICE_TITLE := ZTE Q7
endef
TARGET_DEVICES += zte-q7

define Device/youku-yk1
  DTS := YOUKU-YK1
  IMAGE_SIZE := $(ralink_default_fw_size_32M)
  DEVICE_TITLE := YOUKU YK1
  DEVICE_PACKAGES := kmod-usb2 kmod-usb-ohci kmod-sdhci-mt7620 kmod-usb-ledtrig-usbport
endef
TARGET_DEVICES += youku-yk1

define Device/mw310r-v4
  DTS := MW310R-V4
  IMAGE_SIZE := $(ralink_default_fw_size_16M)
  DEVICE_TITLE := MERCURY MW310R v4
endef
TARGET_DEVICES += mw310r-v4

define Device/zbt-ape522ii
  DTS := ZBT-APE522II
  DEVICE_TITLE := Zbtlink ZBT-APE522II
  DEVICE_PACKAGES := kmod-mt76
endef
TARGET_DEVICES += zbt-ape522ii

define Device/zbt-cpe102
  DTS := ZBT-CPE102
  DEVICE_TITLE := Zbtlink ZBT-CPE102
  DEVICE_PACKAGES := kmod-usb2 kmod-usb-ohci
endef
TARGET_DEVICES += zbt-cpe102

define Device/zbt-wa05
  DTS := ZBT-WA05
  DEVICE_TITLE := Zbtlink ZBT-WA05
endef
TARGET_DEVICES += zbt-wa05

define Device/zbt-we826
  DTS := ZBT-WE826
  IMAGE_SIZE := $(ralink_default_fw_size_16M)
  DEVICE_TITLE := Zbtlink ZBT-WE826
  DEVICE_PACKAGES := kmod-usb2 kmod-usb-ohci kmod-mt76 kmod-sdhci-mt7620 
endef
TARGET_DEVICES += zbt-we826

define Device/zbt-wr8305rt
  DTS := ZBT-WR8305RT
  DEVICE_TITLE := Zbtlink ZBT-WR8305RT
endef
TARGET_DEVICES += zbt-wr8305rt

define Device/tiny-ac
  DTS := TINY-AC
  DEVICE_TITLE := Dovado Tiny AC
  DEVICE_PACKAGES := kmod-usb2 kmod-usb-ohci
endef
TARGET_DEVICES += tiny-ac

define Device/dch-m225
  DTS := DCH-M225
  BLOCKSIZE := 4k
  IMAGES += factory.bin
  IMAGE_SIZE := 6848k
  IMAGE/sysupgrade.bin := \
	append-kernel | pad-offset $$$$(BLOCKSIZE) 64 | append-rootfs | \
	seama -m "dev=/dev/mtdblock/2" -m "type=firmware" | \
	pad-rootfs | append-metadata | check-size $$$$(IMAGE_SIZE)
  IMAGE/factory.bin := \
	append-kernel | pad-offset $$$$(BLOCKSIZE) 64 | \
	append-rootfs | pad-rootfs -x 64 | \
	seama -m "dev=/dev/mtdblock/2" -m "type=firmware" | \
	seama-seal -m "signature=wapn22_dlink.2013gui_dap1320b" | \
	check-size $$$$(IMAGE_SIZE)
  DEVICE_TITLE := D-Link DCH-M225
  DEVICE_PACKAGES := kmod-mt76 kmod-sound-core kmod-sound-mt7620 kmod-i2c-ralink
endef
TARGET_DEVICES += dch-m225

define Device/kn_rc
  DTS := kn_rc
  DEVICE_TITLE := ZyXEL Keenetic Omni
  DEVICE_PACKAGES := kmod-usb2 kmod-usb-ohci kmod-usb-ledtrig-usbport
  IMAGES += factory.bin
  IMAGE/factory.bin := $$(IMAGE/sysupgrade.bin) | pad-to 64k | check-size $$$$(IMAGE_SIZE) | \
	zyimage -d 4882 -v "ZyXEL Keenetic Omni"
endef
TARGET_DEVICES += kn_rc

define Device/kn_rf
  DTS := kn_rf
  DEVICE_TITLE := ZyXEL Keenetic Omni II
  DEVICE_PACKAGES := kmod-usb2 kmod-usb-ohci kmod-usb-ledtrig-usbport
  IMAGES += factory.bin
  IMAGE/factory.bin := $$(IMAGE/sysupgrade.bin) | pad-to 64k | check-size $$$$(IMAGE_SIZE) | \
	zyimage -d 2102034 -v "ZyXEL Keenetic Omni II"
endef
TARGET_DEVICES += kn_rf

define Device/kng_rc
  DTS := kng_rc
  IMAGE_SIZE := $(ralink_default_fw_size_16M)
  DEVICE_TITLE := ZyXEL Keenetic Viva
  DEVICE_PACKAGES := kmod-usb2 kmod-usb-ohci kmod-usb-ledtrig-usbport kmod-switch-rtl8366-smi kmod-switch-rtl8367b
  IMAGES += factory.bin
  IMAGE/factory.bin := $$(sysupgrade_bin) | pad-to 64k | check-size $$$$(IMAGE_SIZE) | \
	zyimage -d 8997 -v "ZyXEL Keenetic Viva"
endef
TARGET_DEVICES += kng_rc

define Device/d240
  DTS := D240
  IMAGE_SIZE := $(ralink_default_fw_size_16M)
  DEVICE_TITLE := Sanlinking Technologies D240
  DEVICE_PACKAGES := kmod-usb2 kmod-usb-ohci kmod-mt76 kmod-sdhci-mt7620
endef
TARGET_DEVICES += d240

define Device/hd51-n
  DTS := HD51-N
  IMAGE_SIZE := $(ralink_default_fw_size_16M)
  DEVICE_TITLE := 100MI NETBOX HD51-N
  DEVICE_PACKAGES := kmod-usb2 kmod-usb-ohci kmod-sdhci-mt7620 kmod-usb-ledtrig-usbport
endef
TARGET_DEVICES += hd51-n
