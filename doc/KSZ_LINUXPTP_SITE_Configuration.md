# KSZ_LINUXPTP_SITE 參數設定說明

## 檔案位置

**設定檔路徑:**
```
KSZ/Atmel_SOC_SAMA5D3/buildroot/package/microchip/ksz_linuxptp/ksz_linuxptp.mk
```

**完整路徑:**
```
/home/user1/Prg/EVB-KSZ9477/KSZ/Atmel_SOC_SAMA5D3/buildroot/package/microchip/ksz_linuxptp/ksz_linuxptp.mk
```

## 參數說明

`KSZ_LINUXPTP_SITE` 是 Buildroot package 的原始碼路徑變數,用於指定 linuxptp 套件的來源位置。

### 當前設定

```makefile
KSZ_LINUXPTP_SITE = $(KSZ_HOME)/ptp/linuxptp/linuxptp-4.0.0
```

- **版本:** linuxptp-4.0.0
- **方法:** local (本地原始碼)
- **授權:** GPLv2

## 可用版本

專案中包含以下 linuxptp 版本:

### 1. linuxptp-4.0.0 (當前使用)
- **路徑:** `KSZ/ptp/linuxptp/linuxptp-4.0.0/`
- **特性:** 支援 Boundary Clock、Ordinary Clock、Transparent Clock
- **PTP Profiles:** 多種 profile 支援

### 2. linuxptp-3.1.1
- **路徑:** `KSZ/ptp/linuxptp/linuxptp-3.1.1/`
- **特性:** 支援 Boundary Clock、Ordinary Clock、Transparent Clock
- **適用:** 穩定版本

### 3. main (主開發分支)
- **路徑:** `KSZ/ptp/linuxptp/main/`
- **特性:** 最早版本 (1.8),僅支援 Boundary Clock、Ordinary Clock
- **適用:** 基礎功能需求

## 修改方式

### 方法 1: 直接修改設定檔

編輯 `ksz_linuxptp.mk` 檔案第 9 行:

```makefile
# 使用 linuxptp-4.0.0 (當前)
KSZ_LINUXPTP_SITE = $(KSZ_HOME)/ptp/linuxptp/linuxptp-4.0.0

# 或切換到 linuxptp-3.1.1
# KSZ_LINUXPTP_SITE = $(KSZ_HOME)/ptp/linuxptp/linuxptp-3.1.1

# 或切換到 main 分支版本
# KSZ_LINUXPTP_SITE = $(KSZ_HOME)/ptp/linuxptp/main
```

### 方法 2: 使用絕對路徑

如果 `KSZ_HOME` 環境變數未設定,可以使用絕對路徑:

```makefile
KSZ_LINUXPTP_SITE = /home/user1/Prg/EVB-KSZ9477/KSZ/ptp/linuxptp/linuxptp-4.0.0
```

### 方法 3: 使用自訂原始碼

如需使用自訂的 linuxptp 原始碼:

```makefile
KSZ_LINUXPTP_SITE = /path/to/your/custom/linuxptp
KSZ_LINUXPTP_SITE_METHOD = local
```

## 相關參數說明

```makefile
# 套件版本號
KSZ_LINUXPTP_VERSION = 0

# 原始碼取得方法 (local=本地檔案)
KSZ_LINUXPTP_SITE_METHOD = local

# 軟體授權
KSZ_LINUXPTP_LICENSE = GPLv2

# 編譯時額外的 C 旗標
KSZ_CFLAGS = -Wno-unused-but-set-variable

# 編譯時啟用 KSZ 1588 PTP 支援
EXTRA_CFLAGS = -DKSZ_1588_PTP
```

## 編譯流程

修改 `KSZ_LINUXPTP_SITE` 後,需重新編譯:

```bash
# 1. 進入 buildroot 目錄
cd KSZ/Atmel_SOC_SAMA5D3/buildroot

# 2. 清除舊的編譯
make ksz_linuxptp-dirclean

# 3. 重新編譯
make ksz_linuxptp

# 4. 或完整重新建置
make clean
make
```

## 安裝的執行檔

編譯後會安裝以下工具到目標系統:

| 執行檔 | 安裝路徑 | 功能 |
|--------|---------|------|
| ptp4l | /usr/sbin/ptp4l | PTP 主程式 |
| phc2sys | /usr/sbin/phc2sys | 硬體時鐘同步工具 |
| phc_ctl | /usr/sbin/phc_ctl | 硬體時鐘控制工具 |
| hwstamp_ctl | /usr/sbin/hwstamp_ctl | 硬體時間戳控制工具 |
| pmc | /usr/sbin/pmc | PTP 管理客戶端 |

## 參考文件

### linuxptp-4.0.0 文件
- 說明文件: `KSZ/ptp/linuxptp/linuxptp-4.0.0/README.org`
- 授權條款: `KSZ/ptp/linuxptp/linuxptp-4.0.0/COPYING`
- Makefile: `KSZ/ptp/linuxptp/linuxptp-4.0.0/makefile`

### 專案建置文件
- `doc/EVB_KSZ9477_Source_Build_Instructions.md`
- `KSZ/ReleaseNotes.txt`

## 版本差異比較

| 功能 | main | 3.1.1 | 4.0.0 |
|------|------|-------|-------|
| Boundary Clock | ✓ | ✓ | ✓ |
| Ordinary Clock | ✓ | ✓ | ✓ |
| Transparent Clock | ✗ | ✓ | ✓ |
| 多種 PTP Profiles | ✗ | ✓ | ✓ |
| 進階功能 | ✗ | ✓ | ✓ |

## 注意事項

1. **KSZ_HOME 環境變數**: 確保 `KSZ_HOME` 環境變數正確設定,指向 KSZ 目錄
   ```bash
   export KSZ_HOME=/home/user1/Prg/EVB-KSZ9477/KSZ
   ```

2. **版本相容性**: 切換版本時,請確認硬體和驅動程式的相容性

3. **編譯依賴**: 不同版本可能需要不同的編譯依賴套件

4. **功能需求**: 根據實際 PTP 應用需求選擇適當版本:
   - 基礎需求: main 版本即可
   - 需要 Transparent Clock: 選擇 3.1.1 或 4.0.0
   - 最新功能: 選擇 4.0.0

## 疑難排解

### KSZ_HOME 未定義
```bash
# 檢查環境變數
echo $KSZ_HOME

# 若未設定,請加入環境變數
export KSZ_HOME=/home/user1/Prg/EVB-KSZ9477/KSZ
```

### 編譯錯誤
```bash
# 清除並重新編譯
make ksz_linuxptp-dirclean
make ksz_linuxptp-reconfigure
make ksz_linuxptp
```

### 路徑不存在
```bash
# 確認原始碼目錄是否存在
ls -la $KSZ_HOME/ptp/linuxptp/
```

## 更新記錄

- **2025-12-15**: 建立此文件,記錄 KSZ_LINUXPTP_SITE 設定說明
