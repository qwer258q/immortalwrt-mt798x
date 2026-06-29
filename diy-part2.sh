#!/bin/bash

# =====================================================================
# 1. 【精准修改】将固件默认后台 IP 修改为 192.168.31.1（红米官方同网段）
# =====================================================================
echo "正在修改默认后台 IP 为 192.168.31.1 ..."
# 优先匹配并替换该源码默认的 192.168.6.1
sed -i 's/192.168.6.1/192.168.31.1/g' package/base-files/files/bin/config_generate
# 同时兼容传统的 192.168.1.1 匹配
sed -i 's/192.168.1.1/192.168.31.1/g' package/base-files/files/bin/config_generate


# =====================================================================
# 2. 克隆指定的第三方插件（MosDNS / OpenClash / NetSpeedTest）
# =====================================================================
# 强制下载 sbwml 大佬 21.02 专用 mosdns 分支
rm -rf package/mosdns
git clone --depth=1 -b openwrt-21.02 https://github.com/sbwml/luci-app-mosdns package/mosdns

# 配套克隆 geodata 规则转换器
rm -rf package/v2ray-geodata
git clone --depth=1 https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# 引入指定的 netspeedtest 网速测试插件
rm -rf package/netspeedtest
git clone --depth=1 https://github.com/muink/luci-app-netspeedtest.git package/netspeedtest

# 更新 OpenClash 到官方最新版
rm -rf package/luci-app-openclash
git clone --depth=1 https://github.com/vernesong/OpenClash.git package/luci-app-openclash


# =====================================================================
# 3. 【核心提取】直接从仓库根目录复制你上传的 Clash Meta 内核
# =====================================================================
# 创建 OpenClash 放置 Meta 内核的特定源码目录
META_CORE_DIR="package/luci-app-openclash/luasrc/view/openclash/root/etc/openclash/core"
mkdir -p "$META_CORE_DIR"

echo "正在从仓库根目录复制 Clash Meta 内核..."
# 判断根目录下的备份内核是否存在
if [ -f "clash_meta" ]; then
    cp clash_meta "$META_CORE_DIR/clash_meta"
    chmod +x "$META_CORE_DIR/clash_meta"
    echo ">>>> 🎉 Clash Meta 内核已从根目录成功复制并集成！ <<<<"
else
    echo "❌ 错误：未在仓库根目录下找到 clash_meta 文件！"
fi


# =====================================================================
# 4. 强制清除 Feeds 目录中自带的旧文件并升级 Go 编译器为 26.x（核心修改点）
# =====================================================================
if [ -d "feeds/packages" ]; then
    echo "检测到 feeds 已下载，开始替换高版本 Golang (26.x) 和清理旧包..."
    
    # 强制将远古低版本 Go 语言编译器升级为 26.x 分支（解决新版 MosDNS 报错必备）
    rm -rf feeds/packages/lang/golang
    git clone --depth=1 https://github.com/sbwml/packages_lang_golang -b 26.x feeds/packages/lang/golang

    # 强力清除原本 feeds 里可能冲突的旧包
    rm -rf feeds/packages/net/mosdns
    rm -rf feeds/packages/net/v2ray-geodata
    rm -rf feeds/packages/utils/v2dat
    rm -rf feeds/luci/applications/luci-app-mosdns
    rm -rf feeds/luci/applications/luci-app-openclash
fi
