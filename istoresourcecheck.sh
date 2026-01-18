#!/bin/sh
# istore_source_check.sh
# 检测 iStore 源可用性、DNS 解析、HTTP 访问与 opkg 更新能力

ISTORE_HOST="istore.linkease.com"
ISTORE_URL="https://istore.linkease.com/repo/all/nas_luci"
CUSTOM_FEEDS="/etc/opkg/customfeeds.conf"
TMP_LOG="/tmp/istore_check.log"

green()  { echo -e "\033[32m$*\033[0m"; }
yellow() { echo -e "\033[33m$*\033[0m"; }
red()    { echo -e "\033[31m$*\033[0m"; }

print_header() {
  echo "======================================================="
  echo " iStore 源可用性检测（国内网络环境）"
  echo " 目标源: $ISTORE_URL"
  echo "======================================================="
}

check_dns() {
  echo
  yellow "【步骤1】DNS 解析检测：$ISTORE_HOST"
  if command -v nslookup >/dev/null 2>&1; then
    nslookup "$ISTORE_HOST" | tee "$TMP_LOG"
    if grep -E "Address|addresses" "$TMP_LOG" >/dev/null 2>&1; then
      green "✅ DNS 解析正常：$ISTORE_HOST"
    else
      red "❌ DNS 解析失败：请检查路由器的 DNS 设置（建议 114.114.114.114 或运营商默认 DNS）"
      return 1
    fi
  else
    yellow "未找到 nslookup，尝试 ping 检测..."
    if ping -c 1 -W 2 "$ISTORE_HOST" >/dev/null 2>&1; then
      green "✅ 通过 ping 验证域名可达：$ISTORE_HOST"
    else
      red "❌ 无法 ping 通域名：请检查 DNS 或网络连通性"
      return 1
    fi
  fi
  return 0
}

check_http() {
  echo
  yellow "【步骤2】HTTP/HTTPS 访问检测：$ISTORE_URL"
  if command -v wget >/dev/null 2>&1; then
    wget -q --spider --timeout=5 "$ISTORE_URL"
    if [ $? -eq 0 ]; then
      green "✅ 源页面可访问：$ISTORE_URL"
    else
      red "❌ 源页面不可访问：可能是临时维护或网络波动，稍后重试"
      return 1
    fi
  else
    yellow "未找到 wget，尝试 curl 检测..."
    if command -v curl >/dev/null 2>&1; then
      curl -s --head --max-time 5 "$ISTORE_URL" | head -n 1 | grep -q "HTTP"
      if [ $? -eq 0 ]; then
        green "✅ 源页面可访问（curl）：$ISTORE_URL"
      else
        red "❌ 源页面不可访问（curl）：可能是临时维护或网络波动，稍后重试"
        return 1
      fi
    else
      red "❌ 未找到 wget/curl，无法进行 HTTP 检测"
      return 1
    fi
  fi
  return 0
}

ensure_feed() {
  echo
  yellow "【步骤3】确保 iStore 源写入 opkg feeds：$CUSTOM_FEEDS"
  touch "$CUSTOM_FEEDS"
  if ! grep -q "istore.linkease.com" "$CUSTOM_FEEDS" 2>/dev/null; then
    echo "src/gz istore $ISTORE_URL" >> "$CUSTOM_FEEDS"
    green "✅ 已写入 iStore 源到 $CUSTOM_FEEDS"
  else
    green "✅ 已存在 iStore 源，跳过写入"
  fi
}

check_opkg_update() {
  echo
  yellow "【步骤4】opkg update 检测"
  opkg update >/tmp/opkg_update.log 2>&1
  if [ $? -eq 0 ]; then
    green "✅ opkg update 成功：包列表已更新"
  else
    red "❌ opkg update 失败：请检查网络/DNS/源可用性"
    echo "---- opkg update 输出 ----"
    tail -n +1 /tmp/opkg_update.log
    return 1
  fi
  return 0
}

final_tips() {
  echo
  echo "======================================================="
  green "检测完成：如果以上步骤均为 ✅，即可运行你的 iStore 风格化脚本。"
  echo
  yellow "若仍失败，建议："
  echo "- **检查 DNS**：设置为 114.114.114.114 或运营商默认 DNS"
  echo "- **确认时间**：系统时间正确（证书校验依赖时间）"
  echo "- **稍后重试**：源可能临时维护"
  echo "======================================================="
}

main() {
  print_header
  check_dns || exit 1
  check_http || exit 1
  ensure_feed
  check_opkg_update || exit 1
  final_tips
}

main
