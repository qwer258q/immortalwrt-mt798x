#!/bin/bash

# =====================================================================
# 0. 自动复制 MT7986 设备默认配置文件到 .config
# =====================================================================
echo "正在自动复制 mt7986-ax6000.config 作为当前编译配置..."
if [ -f "defconfig/mt7986-ax6000.config" ]; then
    cp -f defconfig/mt7986-ax6000.config .config
    echo ">>>> 🎉 .config 配置文件已成功应用！ <<<<"
else
    echo "⚠️ 警告：未找到 defconfig/mt7986-ax6000.config 文件，请检查路径！"
fi


# =====================================================================
# 1. 【精准修改】将固件默认后台 IP 修改为 192.168.31.1
# =====================================================================
echo "正在修改默认后台 IP 为 192.168.31.1 ..."
sed -i 's/192.168.6.1/192.168.31.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.1.1/192.168.31.1/g' package/base-files/files/bin/config_generate


# =====================================================================
# 2. 克隆指定的第三方插件
# =====================================================================
# 强拉稳定版分支，防止最新版对 Go 版本要求过高导致闭源驱动冲突
rm -rf package/mosdns
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns

rm -rf feeds/packages/net/v2ray-geodata
git clone https://github.com/sbwml/v2ray-geodata.git package/feeds/v2ray-geodata

rm -rf package/netspeedtest
git clone --depth=1 https://github.com/muink/luci-app-netspeedtest.git package/netspeedtest

rm -rf package/luci-app-openclash
git clone --depth=1 https://github.com/vernesong/OpenClash.git package/luci-app-openclash


# =====================================================================
# 3. 【核心提取】直接从仓库根目录复制你上传的 Clash Meta 内核
# =====================================================================
META_CORE_DIR="package/luci-app-openclash/luasrc/view/openclash/root/etc/openclash/core"
mkdir -p "$META_CORE_DIR"

echo "正在从仓库根目录复制 Clash Meta 内核..."
if [ -f "clash_meta" ]; then
    cp clash_meta "$META_CORE_DIR/clash_meta"
    chmod +x "$META_CORE_DIR/clash_meta"
    echo ">>>> 🎉 Clash Meta 内核已从根目录成功复制并集成！ <<<<"
else
    echo "❌ 错误：未在仓库根目录下找到 clash_meta 文件！"
fi


# =====================================================================
# 4. 强制升级 Go 编译器到最新的 26.x 最高版本分支
# =====================================================================
if [ -d "feeds/packages" ]; then
    echo "检测到 feeds 已下载，开始替换最高版本 Golang (26.x) 并清理冲突包..."
    
    # 精准替换为你指定的 Go 1.26.x 编译器分支
    rm -rf feeds/packages/lang/golang
    git clone https://github.com/sbwml/packages_lang_golang -b 26.x feeds/packages/lang/golang

    rm -rf feeds/packages/net/mosdns
    rm -rf feeds/packages/net/v2ray-geodata
    rm -rf feeds/packages/utils/v2dat
    rm -rf feeds/luci/applications/luci-app-mosdns
    rm -rf feeds/luci/applications/luci-app-openclash
fi
