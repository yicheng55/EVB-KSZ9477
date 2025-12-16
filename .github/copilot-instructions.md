# EVB-KSZ9477 開發指南

這是 Microchip KSZ9477 乙太網路交換器評估板的嵌入式 Linux BSP 專案，基於 Atmel SAMA5D3 SoC。

## 專案架構

### 核心組件層次

```
KSZ/
├── Atmel_SOC_SAMA5D3/buildroot/     # Buildroot 構建系統（系統映像生成）
├── linux-drivers/                    # KSZ 交換器驅動（多內核版本）
│   ├── ksz9897/, ksz9131/           # KSZ9xxx 系列驅動
│   ├── ksz8795/, ksz8863/, ksz8463/ # KSZ8xxx 系列驅動
│   └── [kernel-version]/            # 支援 Linux 3.3 - 6.6
├── ptp/                              # IEEE 1588 PTP 子系統
│   ├── linuxptp/                    # LinuxPTP 實作（多版本：3.1.1, 4.0.0, main）
│   └── Open-AVB/                    # AVB/TSN 協議棧
├── app_utils/                        # 使用者空間工具
│   ├── ptp_cli/                     # PTP 設定 CLI
│   ├── mdio-tool/                   # MDIO 寄存器訪問
│   └── web_gui/                     # Web 管理界面
└── kernels/linux-4.9.143/           # 基礎內核源碼
```

### 驅動架構要點

**1. KSZ_1588_PTP 條件編譯：** 所有 PTP 相關功能使用 `#ifdef KSZ_1588_PTP` 包裹。這個宏定義在 Buildroot 構建時通過 `EXTRA_CFLAGS=-DKSZ_1588_PTP` 注入（見 `buildroot/package/microchip/ksz_linuxptp/ksz_linuxptp.mk`）。

**2. 多設備模式（multi_dev）：** 驅動支援三種模式：
   - Mode 0: 單一網路設備
   - Mode 1-3: 多設備模式（每個交換器 port 作為獨立網路介面）
   - Mode 3 需要啟用 STP（詳見 ReleaseNotes.txt v1.2.0）

**3. Host Port 映射：** 從 v1.2.0 開始，host port 統一映射為最後一個 port（對使用者可見），簡化 API 介面。KSZ9897 的 host port 可為任意 port，但對外總是顯示為最後一個。

**4. 驅動集成點：**
   - Cadence MACB 驅動：`linux-drivers/ksz*/linux-*/drivers/net/ethernet/cadence/macb_main.c` 中 `#ifdef CONFIG_KSZ_SWITCH` 引入 `ksz_mac_pre.c`
   - CONFIG 層級：`ksz_cfg_*.h` 文件管理功能開關（CONFIG_1588_PTP, CONFIG_KSZ_MRP 等）

## 關鍵開發流程

### 構建系統

**環境設定（必須）：**
```bash
export KSZ_HOME=/home/user1/Prg/EVB-KSZ9477/KSZ
# 建議加入 ~/.bashrc 以永久生效
```

**標準構建流程：**
```bash
cd $KSZ_HOME/Atmel_SOC_SAMA5D3/buildroot

# 選擇配置（NAND flash）
make atmel_sama5d3_xplained_ksz_5_4_defconfig
# 或 SD 卡版本
make atmel_sama5d3_xplained_ksz_5_4_mmc_defconfig

# 開始構建
make

# 輸出位置
ls output/images/  # zImage, at91-sama5d3_xplained.dtb, rootfs.ubi/sdcard.img
```

**重要：配置文件修改後的重建：**
若修改 `KSZ/ptp/bin/*.cfg` 或腳本，需強制重建：
```bash
make ksz_ptp_scripts-dirclean  # 清除套件
make                            # 重新構建
```
原因：Buildroot 套件管理使用時間戳判斷，本地源碼修改不會自動觸發重建。

### LinuxPTP 版本切換

控制檔案：`buildroot/package/microchip/ksz_linuxptp/ksz_linuxptp.mk`
```makefile
# 第 9 行切換版本
KSZ_LINUXPTP_SITE = $(KSZ_HOME)/ptp/linuxptp/linuxptp-4.0.0  # 當前
# KSZ_LINUXPTP_SITE = $(KSZ_HOME)/ptp/linuxptp/linuxptp-3.1.1
# KSZ_LINUXPTP_SITE = $(KSZ_HOME)/ptp/linuxptp/main  # 版本 1.8（基礎）
```
切換後需 `make ksz_linuxptp-dirclean && make`。

### 調試與刷寫

**NAND Flash 刷寫：**
1. 連接 USB (J12) 和 5V 電源
2. 移除 NAND jumper (J13)，按 Reset 產生 `/dev/ttyACM0`
3. 插回 NAND jumper (J13)
4. `cd $KSZ_HOME/Atmel_SOC_SAMA5D3/buildroot && sudo flash_board_x64`

**SD 卡刷寫：**
直接使用 `dd` 將 `output/images/sdcard.img` 寫入 SD 卡。

## PTP 開發要點

### ptp4l 修改模式

查看 `KSZ/ptp/linuxptp/linuxptp-3.1.1/ptp4l.c`:
- **第 301 行**：`case CLOCK_TYPE_E2E:` 處理 E2E Transparent Clock
- **多 port 支援**：使用 `-n <num_ports>` 選項配合 `-i eth0.1 -i eth0.2 ...` 創建多個介面
- **KSZ 擴展**：`#ifdef KSZ_1588_PTP` 區塊包含 VLAN 設備處理邏輯（L210-L245）

### PTP 配置架構

路徑：`KSZ/ptp/bin/*.cfg`
- `default.cfg`: 基礎配置
- `E2E-TC.cfg`, `P2P-TC.cfg`: Transparent Clock 配置
- `linuxptp.sh`: 啟動腳本

**特殊注意**：E2E Transparent Clock 需搭配 `delay_mechanism=E2E`（ptp4l.c L301-L311 驗證）。

## 常見模式與約定

### 條件編譯層次

```c
// 頂層功能開關（Kernel config）
#if defined(CONFIG_KSZ_PTP)
#define CONFIG_1588_PTP  // 內部實作宏
#endif

// 用戶空間/linuxptp 適配
#ifdef KSZ_1588_PTP
// Microchip 特定邏輯
#endif
```

### 寄存器訪問模式

所有驅動使用統一的 `sw->reg->` 介面（定義於 `ksz_sw.h`）：
```c
sw->reg->r8(sw, REG_ADDR)     // 讀取 8 位
sw->reg->w8(sw, REG_ADDR, val) // 寫入 8 位
```
實際 I/O 層可為 SPI/MDIO/IBA，由 `ksz_spi.c`/`ksz_i2c.c` 實作。

### 多版本驅動維護

單一交換器型號在 `linux-drivers/ksz*/` 下有多個 kernel 版本子目錄。修改時：
1. **優先編輯當前使用版本**（如 linux-5.4）
2. **結構性變更需同步至其他版本**（特別是 ksz_sw*.c/h 核心邏輯）
3. **API 差異**：查閱對應版本的 `ksz_cfg_*.h` 確認可用功能

## 文檔參考

- `doc/EVB_KSZ9477_Source_Build_Instructions.md`: 完整構建步驟
- `doc/KSZ_LINUXPTP_SITE_Configuration.md`: LinuxPTP 版本切換
- `doc/KSZ_PTP_Scripts_Reinstall_Guide.md`: 配置更新強制重建
- `KSZ/ReleaseNotes.txt`: 版本歷史與已知問題

## 開發警示

⚠️ **RSTP 依賴**：多設備模式 3 必須啟用 RSTP，否則 port 保持 partitioned 狀態（ReleaseNotes v1.0）。

⚠️ **KSZ_HOME 必須設定**：Buildroot 套件依賴此環境變數定位本地源碼。未設定將導致構建失敗。

⚠️ **交叉編譯器版本**：Buildroot 內建工具鏈，無需外部 cross compiler。修改 toolchain 配置需執行 `make clean`。

⚠️ **Device Tree 修改**：若需調整 GPIO/中斷（如 UNG8071 Rev.B GPIO 從 10 改 28），編輯 `dtb/linux-*/at91-sama5d3_xplained.dts` 並重建。
