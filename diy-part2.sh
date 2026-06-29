#!/bin/bash

# =====================================================================
# 1. 【精准修改】将固件默认后台 IP 修改为 192.168.31.1
# =====================================================================
echo "正在修改默认后台 IP 为 192.168.31.1 ..."
sed -i 's/192.168.6.1/192.168.31.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.1.1/192.168.31.1/g' package/base-files/files/bin/config_generate


# =====================================================================
# 2. 克隆指定的第三方插件（选择完美兼容 23.x Go 环境的稳定版分支）
# =====================================================================
# 强拉稳定版分支，防止最新版对 Go 版本要求过高导致闭源驱动冲突
rm -rf package/mosdns
git clone --depth=1 -b openwrt-21.02 https://github.com/sbwml/luci-app-mosdns package/mosdns

rm -rf package/v2ray-geodata
git clone --depth=1 https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

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
# 4. 强制升级 Go 编译器到平稳的 23.x 分支（兼顾闭源驱动与新版插件）
# =====================================================================
if [ -d "feeds/packages" ]; then
    echo "检测到 feeds 已下载，开始替换平衡版 Golang (23.x) 并清理冲突包..."
    
    # 使用 23.x 分支，既满足新插件的编译下限，又不会因为特性太前沿导致闭源 Wi-Fi 驱动死机
    rm -rf feeds/packages/lang/golang
    git clone --depth=1 https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang

    rm -rf feeds/packages/net/mosdns
    rm -rf feeds/packages/net/v2ray-geodata
    rm -rf feeds/packages/utils/v2dat
    rm -rf feeds/luci/applications/luci-app-mosdns
    rm -rf feeds/luci/applications/luci-app-openclash
fi
