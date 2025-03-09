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

addFeeds custom https://github.com/kenzok8/openwrt-packages.git
addFeeds small https://github.com/kenzok8/small.git

# 关机
git clone --depth=1 https://github.com/esirplayground/luci-app-poweroff package/luci-app-poweroff
# 应用过滤
git clone --depth=1 https://github.com/destan19/OpenAppFilter package/OpenAppFilter
# 钉钉推送
git clone --depth=1 https://github.com/zzsj0928/luci-app-pushbot package/luci-app-pushbot
# 端口转发
git clone --depth=1 https://github.com/chenmozhijin/luci-app-socat package/luci-app-socat
# 定时重启
git clone https://github.com/zxl78585/luci-app-autoreboot.git package/luci-app-autoreboot


# 带宽监控+在线设备，相互依赖
git_sparse_clone main https://github.com/kenzok8/small-package luci-app-wrtbwmon wrtbwmon luci-app-onliner
# usb打印+网络唤醒Plus
git_sparse_clone main https://github.com/kenzok8/small-package luci-app-usb-printer luci-app-wolplus
# KMS 
git_sparse_clone main https://github.com/kenzok8/small-package luci-app-vlmcsd vlmcsd

