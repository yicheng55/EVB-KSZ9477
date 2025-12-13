# EVB KSZ9477 Source Build Instructions

**Revision:** 0.1
**Date:** Sept 14, 2017
**Copyright:** © 2016-2017 Microchip Technology Inc.
**Location:** 2180 Fortune Dr., San Jose, CA 95131, USA
**Phone:** (408) 944-0480
**Website:** http://www.microchip.com

---

## Overview

This document contains instructions on how to download and build images for the **EVB-KSZ9477 evaluation board**, which features an Atmel SAMA5D3 SOC and a KSZ9477 Ethernet switch.

## Prerequisites

The Buildroot procedure requires the following tools. Install them on Ubuntu Linux (tested on Ubuntu 14.04 LTS x64 version):

```bash
apt-get install sed make binutils gcc g++ bash patch gzip bzip2 perl tar cpio python unzip rsync wget libncurses-dev
```

For more information about Buildroot for Atmel SAMA5 processors, visit:
http://www.at91.com/linux4sam/bin/view/Linux4SAM/BuildRootBuild

### Tested Build Environment

This document has been verified to work with the following build environment:

- **Operating System**: Ubuntu 20.04.5 LTS
- **Kernel**: Linux 5.15.0-139-generic
- **Architecture**: x86-64
- **GCC Version**: 9.4.0
- **Binutils**: 2.34

---

## Build Instructions

### Step 1: Create the Source Tree

Clone the repository:
```bash
git clone https://github.com/Microchip-Ethernet/EVB-KSZ9477.git
```

Or download the ZIP file from:
https://github.com/Microchip-Ethernet/EVB-KSZ9477

### Step 2: Change Directory to KSZ Folder

```bash
cd EVB-KSZ9477/KSZ
```

### Step 3: Export KSZ_HOME Variable to KSZ Folder

```bash
# KSZ EVB development environment.
# 只在目前終端機有效（暫時）
export KSZ_HOME=`pwd`
```

Or add the following line to your `~/.bashrc` file:
```
# ------------------------------------------------------------
# KSZ EVB-KSZ9477 development environment setup example
# KSZ_HOME points to the root directory of the KSZ SDK
# 只對「某個使用者」永久有效（最常用）
# ------------------------------------------------------------
export KSZ_HOME="$HOME/Prg/EVB-KSZ9477/KSZ"
````

Then, source the `~/.bashrc` file to apply the changes:
```bash# 使剛剛修改的 ~/.bashrc 生效
-->$ source ~/.bashrc
```


### Step 4: Change Directory to Atmel_SOC_SAMA5D3/buildroot

```bash
cd Atmel_SOC_SAMA5D3/buildroot
```

### Step 5: Choose Image Type

Decide whether you need NAND flash image or SD card image:

*** 原始檔 .pdf 說明錯誤，已修正如下 ***

**For NAND flash image:**
```bash
make atmel_sama5d3_xplained_ksz_5_4_defconfig
```

**For SD card image:**
```bash
make atmel_sama5d3_xplained_ksz_5_4_mmc_defconfig
```

### Step 6: Build

```bash
make
```

### Step 7: Locate Generated Images

The images will be created in:
```
$KSZ_HOME/Atmel_SOC_SAMA5D3/buildroot/output/images
```

---

## Flashing NAND Image to EVB-KSZ9477

1. **Connect the micro-USB connector (J12)** of the EVB-KSZ9477 to the Linux PC.

2. **Connect the 5V power** to the EVB-KSZ9477 board.

3. **Remove the NAND enable (J13) jumper** and hit the Master Reset button. This creates `/dev/ttyACM0`. You can verify this by executing:
   ```bash
   tail -f /var/log/kernel.log
   ```

4. **Insert the NAND enable (J13) jumper**.

5. **Change directory** to buildroot:
   ```bash
   cd $KSZ_HOME/Atmel_SOC_SAMA5D3/buildroot
   ```

6. **Run the appropriate flash script**:
   - For x86 systems:
     ```bash
     sudo flash_board
     ```
   - For x64 systems:
     ```bash
     sudo flash_board_x64
     ```

---

## Using SD Card Image to Boot EVB-KSZ9477

The SD card image `sdcard.img` is located at:
```
$KSZ_HOME/Atmel_SOC_SAMA5D3/buildroot/output/images
```

For detailed SD card programming instructions, refer to the **EVB-KSZ9477_Image_Programming_Guide.pdf** available at:
https://github.com/Microchip-Ethernet/EVB-KSZ9477/releases

---

**Confidential Information**
© 2016-2017 Microchip Technology Inc.
