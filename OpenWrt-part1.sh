#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: OpenWrt-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# upgrade gcc11
# sudo apt-get update && sudo apt-get upgrade -y
# sudo apt-get install software-properties-common -y
# sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
# sudo apt-get update
# sudo apt-get install gcc-11 g++-11 -y
# sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 60 --slave /usr/bin/g++ g++ /usr/bin/g++-11
# sudo update-alternatives --config gcc
# gcc --version

# 自定义函数
addFeeds(){
  if [ $# == 2 ];then
    echo src-git $1 $2 >> feeds.conf.default
  fi
}

function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}


# Uncomment a feed source

# sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# addFeeds passwall_packages "https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main"
# addFeeds passwall_luci "https://github.com/Openwrt-Passwall/openwrt-passwall.git;main"

addFeeds custom https://github.com/kenzok8/openwrt-packages.git
addFeeds small https://github.com/kenzok8/small.git

# 支持 turboacc
# 不带 shortcut-fe
curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh --no-sfe
# 带  不带 shortcut-fe
# curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh
# shortcut-fe
git_sparse_clone package https://github.com/chenmozhijin/turboacc shortcut-fe

# 关机
git clone --depth=1 https://github.com/esirplayground/luci-app-poweroff package/luci-app-poweroff

# 应用过滤
git clone -b v6.1.3  https://github.com/destan19/OpenAppFilter package/OpenAppFilter

# 钉钉推送
git clone --depth=1 https://github.com/zzsj0928/luci-app-pushbot package/luci-app-pushbot

# 端口转发 A luci app of socat for nftables
# git clone --depth=1 https://github.com/WROIATE/luci-app-socat package/luci-app-socat
git_sparse_clone main https://github.com/kenzok8/small-package luci-app-socat 

# 定时重启
git clone https://github.com/zxl78585/luci-app-autoreboot.git package/luci-app-autoreboot

# 磁盘管理
git clone --depth=1 https://github.com/lisaac/luci-app-diskman package/luci-app-diskman

# 温度插件
git clone --depth=1 https://github.com/gSpotx2f/luci-app-temp-status package/luci-app-temp-status

# 带宽监控+在线设备，相互依赖
git_sparse_clone main https://github.com/kenzok8/small-package luci-app-wrtbwmon wrtbwmon luci-app-onliner

# usb打印+网络唤醒Plus
git_sparse_clone main https://github.com/kenzok8/small-package luci-app-usb-printer luci-app-wolplus

# kms
git_sparse_clone master https://github.com/DokiDuck/luci-app-vlmcsd luci-app-vlmcsd vlmcsd


# natmapt
git clone --depth 1 --branch master --single-branch --no-checkout https://github.com/muink/openwrt-stuntman.git package/stuntman
pushd package/stuntman
umask 022
git checkout
popd

git clone --depth 1 --branch master --single-branch --no-checkout https://github.com/muink/luci-app-natmapt.git package/luci-app-natmapt
pushd package/luci-app-natmapt
umask 022
git checkout
popd

git clone --depth 1 --branch master --single-branch --no-checkout https://github.com/muink/openwrt-natmapt.git package/natmapt
pushd package/natmapt
umask 022
git checkout
popd

# git_sparse_clone master https://github.com/muink/openwrt-stuntman stuntman
# git_sparse_clone master https://github.com/muink/luci-app-natmapt luci-app-natmapt

# SMS tools
git_sparse_clone master https://github.com/4IceG/luci-app-sms-tool luci-app-sms-tool sms-tool

# luci-app-airplay2
# git_sparse_clone luci19 https://github.com/tcsr200722/openwrt-luci-app luci-app-airplay2

git_sparse_clone main https://github.com/kenzok8/small-package dns2socks ipt2socks microsocks

# cd OpenWrt buildroot 
# mkdir -p "package/cdnspeedtest"
# curl -fL "https://raw.githubusercontent.com/immortalwrt/packages/master/net/cdnspeedtest/Makefile" | sed 's,../../lang,$(TOPDIR)/feeds/packages/lang,' > "package/cdnspeedtest/Makefile"
# # buildroot menuconfig
# # check Network -> cdnspeedtest
# # Network  --->
# # <*> cdnspeedtest.............. Getting the fastest ips to your network of CDN

# 
./scripts/feeds update -a

rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,v2ray*,sing*,smartdns}
rm -rf feeds/packages/utils/v2dat

# remove 
ls -lh feeds/small/
rm -rf feeds/small/{luci-app-bypass,luci-app-ssr-plus}

echo  "--------------------------------------------------------------"
find ./ -name luci-app-store
rm -rf feeds/custom/{luci-app-store}
rm -rf package/feeds/custom/luci-app-store
echo  "--------------------------------------------------------------"
