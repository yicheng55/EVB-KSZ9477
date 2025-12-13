# KSZ PTP Scripts 強制重新安裝指南

## 概述

本文件說明如何強制重新安裝 `ksz_ptp_scripts` 套件，以確保 PTP 配置文件的更新能正確打包進 sdcard.img。

## 何時需要強制重新安裝

當發生以下情況時，需要強制重新安裝 `ksz_ptp_scripts`：

1. ✅ **修改了 `KSZ/ptp/bin/` 目錄下的配置文件**
   - 例如：E2E-TC.cfg, P2P-TC.cfg, default.cfg 等

2. ✅ **修改了 PTP 腳本文件**
   - 例如：linuxptp.sh 等執行腳本

3. ✅ **執行 `make` 但配置文件沒有更新到 target 目錄**
   - 檢查 `output/target/ptp/` 目錄發現是舊版本

4. ✅ **`KSZ_HOME` 環境變數設定錯誤或未設定**
   - 導致 buildroot 無法找到正確的原始碼路徑

## 前置條件檢查

### 1. 確認 KSZ_HOME 環境變數

```bash
# 檢查 KSZ_HOME 是否設定
echo $KSZ_HOME
```

**預期輸出：**
```
/home/user1/Prg/EVB-KSZ9477/KSZ
```

**若未設定或路徑錯誤，請執行：**
```bash
# 設定 KSZ_HOME
export KSZ_HOME=/home/user1/Prg/EVB-KSZ9477/KSZ

# 加入 ~/.bashrc 以永久生效
echo 'export KSZ_HOME=/home/user1/Prg/EVB-KSZ9477/KSZ' >> ~/.bashrc
source ~/.bashrc
```

### 2. 確認原始碼目錄存在

```bash
# 檢查 ptp/bin 目錄
ls -la $KSZ_HOME/ptp/bin/

# 應該看到以下目錄結構
# 3.1.1/
# 4.0.0/
# avb/
# e2e/
# p2p/
# power/
# telecom/
```

### 3. 確認配置文件已修改

```bash
# 檢查配置文件內容
grep "twoStepFlag" $KSZ_HOME/ptp/bin/4.0.0/E2E-TC.cfg
grep "twoStepFlag" $KSZ_HOME/ptp/bin/3.1.1/E2E-TC.cfg
```

**預期輸出應包含：**
```
twoStepFlag         0
```

## 強制重新安裝步驟

### 方法 1: 完整清除並重新安裝（推薦）

```bash
# 1. 進入 buildroot 目錄
cd $KSZ_HOME/Atmel_SOC_SAMA5D3/buildroot

# 2. 清除 ksz_ptp_scripts 套件的所有編譯產物
make ksz_ptp_scripts-dirclean

# 3. 重新安裝（會重新同步原始碼並安裝到 target）
make ksz_ptp_scripts-reinstall
```

### 方法 2: 僅重新安裝（快速）

```bash
# 進入 buildroot 目錄
cd $KSZ_HOME/Atmel_SOC_SAMA5D3/buildroot

# 直接重新安裝
make ksz_ptp_scripts-reinstall
```

### 方法 3: 完整重新編譯（最徹底）

```bash
# 進入 buildroot 目錄
cd $KSZ_HOME/Atmel_SOC_SAMA5D3/buildroot

# 清除 ksz_ptp_scripts
make ksz_ptp_scripts-dirclean

# 重新編譯整個 buildroot（包含重新打包）
make
```

## 驗證安裝結果

### 1. 檢查 target 目錄

```bash
# 檢查 target 目錄中的配置文件
cat $KSZ_HOME/Atmel_SOC_SAMA5D3/buildroot/output/target/ptp/4.0.0/E2E-TC.cfg | head -10

# 應該看到
# [global]
# twoStepFlag         0
# priority1           254
# ...
```

### 2. 驗證完整目錄結構

```bash
# 列出 target/ptp/ 目錄結構
ls -la $KSZ_HOME/Atmel_SOC_SAMA5D3/buildroot/output/target/ptp/

# 應該包含以下內容：
# 3.1.1/
# 4.0.0/
# avb/
# e2e/
# p2p/
# power/
# telecom/
# README (如果有)
# *.sh 腳本檔案
```

### 3. 檢查編譯日誌

重新安裝時應該看到以下訊息：

```
>>> ksz_ptp_scripts 0 Syncing from source dir /home/user1/Prg/EVB-KSZ9477/KSZ/ptp/bin
rsync -au --chmod=u=rwX,go=rX --exclude .svn --exclude .git --exclude .hg --exclude .bzr --exclude CVS /home/user1/Prg/EVB-KSZ9477/KSZ/ptp/bin/ /home/user1/Prg/EVB-KSZ9477/KSZ/Atmel_SOC_SAMA5D3/buildroot/output/build/ksz_ptp_scripts-0
>>> ksz_ptp_scripts 0 Configuring
>>> ksz_ptp_scripts 0 Building
>>> ksz_ptp_scripts 0 Installing to target
mkdir -p /home/user1/Prg/EVB-KSZ9477/KSZ/Atmel_SOC_SAMA5D3/buildroot/output/target/ptp
cp -rp /home/user1/Prg/EVB-KSZ9477/KSZ/Atmel_SOC_SAMA5D3/buildroot/output/build/ksz_ptp_scripts-0/* /home/user1/Prg/EVB-KSZ9477/KSZ/Atmel_SOC_SAMA5D3/buildroot/output/target/ptp/
```

## 完整工作流程（從修改到打包）

### 完整步驟清單

```bash
# ============================================
# 步驟 1: 修改配置文件
# ============================================
# 編輯需要修改的配置文件，例如：
# vim $KSZ_HOME/ptp/bin/4.0.0/E2E-TC.cfg

# ============================================
# 步驟 2: 確認環境變數
# ============================================
echo $KSZ_HOME
# 若未設定，執行：
# export KSZ_HOME=/home/user1/Prg/EVB-KSZ9477/KSZ

# ============================================
# 步驟 3: 進入 buildroot 目錄
# ============================================
cd $KSZ_HOME/Atmel_SOC_SAMA5D3/buildroot

# ============================================
# 步驟 4: 清除並重新安裝 ksz_ptp_scripts
# ============================================
make ksz_ptp_scripts-dirclean
make ksz_ptp_scripts-reinstall

# ============================================
# 步驟 5: 驗證 target 目錄
# ============================================
cat output/target/ptp/4.0.0/E2E-TC.cfg | head -10

# ============================================
# 步驟 6: 重新打包生成 sdcard.img
# ============================================
make

# ============================================
# 步驟 7: 確認最終產出
# ============================================
ls -lh output/images/sdcard.img
```

### 快速命令整合版

```bash
# 一次執行所有命令（確保已設定 KSZ_HOME）
cd $KSZ_HOME/Atmel_SOC_SAMA5D3/buildroot && \
make ksz_ptp_scripts-dirclean && \
make ksz_ptp_scripts-reinstall && \
cat output/target/ptp/4.0.0/E2E-TC.cfg | head -10 && \
make
```

## 技術細節

### ksz_ptp_scripts 套件說明

**Package 定義檔案：**
```
KSZ/Atmel_SOC_SAMA5D3/buildroot/package/microchip/ksz_ptp_scripts/ksz_ptp_scripts.mk
```

**關鍵設定：**
```makefile
KSZ_PTP_SCRIPTS_VERSION = 0
KSZ_PTP_SCRIPTS_SITE = $(KSZ_HOME)/ptp/bin
KSZ_PTP_SCRIPTS_SITE_METHOD = local
KSZ_PTP_SCRIPTS_LICENSE = GPLv2

define KSZ_PTP_SCRIPTS_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/ptp
	cp -rp $(@D)/* $(TARGET_DIR)/ptp/
endef
```

**安裝過程：**
1. rsync 從 `$(KSZ_HOME)/ptp/bin/` 同步到 build 目錄
2. 複製所有內容到 `$(TARGET_DIR)/ptp/`
3. 最終打包進 rootfs.ext4 和 sdcard.img

### 相關目錄結構

```
KSZ/ptp/bin/                          # 原始碼目錄
├── 3.1.1/                            # linuxptp 3.1.1 配置文件
│   ├── E2E-TC.cfg
│   ├── P2P-TC.cfg
│   └── default.cfg
├── 4.0.0/                            # linuxptp 4.0.0 配置文件
│   ├── E2E-TC.cfg
│   ├── P2P-TC.cfg
│   └── default.cfg
├── e2e/                              # E2E 模式腳本
├── p2p/                              # P2P 模式腳本
├── power/                            # Power profile 腳本
└── telecom/                          # Telecom profile 腳本

↓ (make ksz_ptp_scripts-reinstall)

buildroot/output/target/ptp/         # 安裝目標目錄
├── 3.1.1/
├── 4.0.0/
├── e2e/
├── p2p/
├── power/
└── telecom/

↓ (make)

buildroot/output/images/
├── rootfs.ext4                       # Root filesystem
└── sdcard.img                        # 最終 SD 卡映像檔
```

## 常見問題排解

### 問題 1: KSZ_HOME 未定義

**症狀：**
```
make: *** No rule to make target '/ptp/bin'.  Stop.
```

**解決方法：**
```bash
export KSZ_HOME=/home/user1/Prg/EVB-KSZ9477/KSZ
echo 'export KSZ_HOME=/home/user1/Prg/EVB-KSZ9477/KSZ' >> ~/.bashrc
source ~/.bashrc
```

### 問題 2: target 目錄未更新

**症狀：**
執行 `make` 後，`output/target/ptp/` 目錄中的配置文件仍是舊版本。

**解決方法：**
```bash
# 強制清除並重新安裝
make ksz_ptp_scripts-dirclean
make ksz_ptp_scripts-reinstall
```

### 問題 3: 權限問題

**症狀：**
```
cp: cannot create directory: Permission denied
```

**解決方法：**
```bash
# 檢查目錄權限
ls -la $KSZ_HOME/Atmel_SOC_SAMA5D3/buildroot/output/

# 必要時更改所有權
sudo chown -R $USER:$USER $KSZ_HOME/Atmel_SOC_SAMA5D3/buildroot/output/
```

### 問題 4: rsync 失敗

**症狀：**
```
rsync: link_stat failed: No such file or directory
```

**解決方法：**
```bash
# 確認原始碼目錄存在
ls -la $KSZ_HOME/ptp/bin/

# 確認 KSZ_HOME 設定正確
echo $KSZ_HOME
```

### 問題 5: 編譯後 sdcard.img 沒有更新配置

**症狀：**
target 目錄已更新，但燒錄到板子後發現配置文件仍是舊版本。

**解決方法：**
```bash
# 重新打包 rootfs
make

# 或更徹底的重新生成
rm -f output/images/rootfs.ext4 output/images/sdcard.img
make
```

## Buildroot 相關指令參考

### 套件管理指令

```bash
# 顯示套件資訊
make ksz_ptp_scripts-show-info

# 顯示套件依賴
make ksz_ptp_scripts-show-depends

# 清除套件（刪除 build 目錄）
make ksz_ptp_scripts-dirclean

# 重新配置套件
make ksz_ptp_scripts-reconfigure

# 重新安裝到 target
make ksz_ptp_scripts-reinstall

# 重新編譯（從 build 步驟開始）
make ksz_ptp_scripts-rebuild
```

### 系統管理指令

```bash
# 清除所有套件
make clean

# 完全清除（包含下載的檔案）
make distclean

# 僅重新生成 rootfs
make rootfs

# 僅重新生成 sdcard.img
make post-image
```

## 配置文件修改範例

### 範例 1: 修改 E2E-TC.cfg

```bash
# 編輯文件
vim $KSZ_HOME/ptp/bin/4.0.0/E2E-TC.cfg

# 添加或修改設定
# twoStepFlag         0
# priority1           254
# free_running        1

# 重新安裝
cd $KSZ_HOME/Atmel_SOC_SAMA5D3/buildroot
make ksz_ptp_scripts-dirclean && make ksz_ptp_scripts-reinstall

# 驗證
cat output/target/ptp/4.0.0/E2E-TC.cfg | grep "twoStepFlag"

# 打包
make
```

### 範例 2: 批次修改多個配置文件

```bash
# 修改多個版本的配置文件
vim $KSZ_HOME/ptp/bin/3.1.1/E2E-TC.cfg
vim $KSZ_HOME/ptp/bin/4.0.0/E2E-TC.cfg
vim $KSZ_HOME/ptp/bin/3.1.1/P2P-TC.cfg
vim $KSZ_HOME/ptp/bin/4.0.0/P2P-TC.cfg

# 一次性重新安裝
cd $KSZ_HOME/Atmel_SOC_SAMA5D3/buildroot
make ksz_ptp_scripts-dirclean
make ksz_ptp_scripts-reinstall

# 批次驗證
for cfg in output/target/ptp/{3.1.1,4.0.0}/*.cfg; do
    echo "=== $cfg ==="
    head -10 "$cfg"
done

# 重新打包
make
```

## 最佳實踐建議

### 1. 版本控制

修改配置文件前，建議備份原始版本：

```bash
# 備份原始配置
cd $KSZ_HOME/ptp/bin/4.0.0/
cp E2E-TC.cfg E2E-TC.cfg.orig

# 或使用 git（如果專案使用 git）
git diff E2E-TC.cfg
```

### 2. 分階段驗證

```bash
# 階段 1: 修改原始檔
vim $KSZ_HOME/ptp/bin/4.0.0/E2E-TC.cfg

# 階段 2: 驗證修改
cat $KSZ_HOME/ptp/bin/4.0.0/E2E-TC.cfg

# 階段 3: 重新安裝
make ksz_ptp_scripts-dirclean && make ksz_ptp_scripts-reinstall

# 階段 4: 驗證 target
cat output/target/ptp/4.0.0/E2E-TC.cfg

# 階段 5: 重新打包
make

# 階段 6: 驗證最終映像（可選）
mkdir /tmp/test_mount
sudo mount -o loop,offset=4194304 output/images/sdcard.img /tmp/test_mount
cat /tmp/test_mount/ptp/4.0.0/E2E-TC.cfg
sudo umount /tmp/test_mount
```

### 3. 自動化腳本

建立一個自動化更新腳本：

```bash
#!/bin/bash
# update_ptp_configs.sh

set -e

echo "=== 更新 PTP 配置文件 ==="

# 1. 檢查環境
if [ -z "$KSZ_HOME" ]; then
    echo "錯誤: KSZ_HOME 未設定"
    exit 1
fi

# 2. 進入 buildroot
cd $KSZ_HOME/Atmel_SOC_SAMA5D3/buildroot

# 3. 重新安裝 ksz_ptp_scripts
echo "清除舊版本..."
make ksz_ptp_scripts-dirclean

echo "重新安裝..."
make ksz_ptp_scripts-reinstall

# 4. 驗證
echo "驗證安裝..."
if grep -q "twoStepFlag" output/target/ptp/4.0.0/E2E-TC.cfg; then
    echo "✓ 配置文件已更新"
else
    echo "✗ 配置文件更新失敗"
    exit 1
fi

# 5. 重新打包
echo "重新打包映像檔..."
make

echo "=== 完成 ==="
ls -lh output/images/sdcard.img
```

使用方式：
```bash
chmod +x update_ptp_configs.sh
./update_ptp_configs.sh
```

## 相關文件連結

- [EVB-KSZ9477 編譯指南](EVB_KSZ9477_Source_Build_Instructions.md)
- [KSZ LINUXPTP SITE 配置說明](KSZ_LINUXPTP_SITE_Configuration.md)
- [Buildroot 官方文檔](https://buildroot.org/docs.html)

## 修訂記錄

| 日期 | 版本 | 說明 |
|------|------|------|
| 2025-12-14 | 1.0 | 初版建立，包含完整的重新安裝步驟與疑難排解 |

---

**文件位置:** `/home/user1/Prg/EVB-KSZ9477/doc/KSZ_PTP_Scripts_Reinstall_Guide.md`
**維護者:** EVB-KSZ9477 專案團隊
**最後更新:** 2025-12-14
