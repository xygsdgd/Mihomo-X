#!/system/bin/sh
# ============================================================
# Mihomo X 一键诊断脚本
# 用途：把设备上模块的运行状态收集成一个 txt，发给豆包排查
# 用法：su -c "sh mihomo-x-diag.sh"
#       或 Termux：su 回车后 sh mihomo-x-diag.sh
# 输出：/sdcard/mihomo-x-diag-<时间>.txt
# ============================================================

MODDIR=/data/adb/modules/mihomo_x
WORKDIR=/data/adb/mihomo_x
RUNDIR=$WORKDIR/run
CFG=$WORKDIR/config.yaml
CTL=$MODDIR/scripts/mihomo.sh

if [ "$(id -u)" != "0" ]; then
  echo "需要 root 权限：请用 su -c \"sh $0\" 运行"
  exit 1
fi

STAMP=$(date +%Y%m%d-%H%M%S)
OUT=/sdcard/mihomo-x-diag-$STAMP.txt
[ -d /sdcard ] || OUT=/data/local/tmp/mihomo-x-diag-$STAMP.txt

sec() {
  echo "" >> "$OUT"
  echo "===== $1 =====" >> "$OUT"
}

run() {
  _d=$1; shift
  echo ">>> $_d" >> "$OUT"
  "$@" >> "$OUT" 2>&1
}

impatient() {
  _t=$1; shift
  if command -v timeout >/dev/null 2>&1; then
    timeout "$_t" "$@" >> "$OUT" 2>&1
  else
    "$@" >> "$OUT" 2>&1
  fi
}

: > "$OUT"

sec "0. 报告信息"
echo "生成时间：$(date '+%Y-%m-%d %H:%M:%S')" >> "$OUT"
echo "报告文件：$OUT" >> "$OUT"

sec "1. 设备与系统"
echo "机型：$(getprop ro.product.brand) $(getprop ro.product.model)" >> "$OUT"
echo "系统：$(getprop ro.build.version.release) / SDK $(getprop ro.build.version.sdk)" >> "$OUT"
echo "ROM：$(getprop ro.build.display.id)" >> "$OUT"
echo "内核：$(uname -a)" >> "$OUT"
echo "SELinux：$(getprop ro.boot.selinux)" >> "$OUT"
echo "ABI：$(getprop ro.product.cpu.abi)" >> "$OUT"

sec "2. Root 方式"
for k in magisk ksu apd; do
  [ -e "/data/adb/$k" ] && echo "存在：/data/adb/$k" >> "$OUT"
done
[ -x /data/adb/magisk/magisk ] && echo "magisk 版本：$(/data/adb/magisk/magisk -v 2>/dev/null)" >> "$OUT"
[ -x /data/adb/ksu/bin/ksud ] && echo "ksud：$(/data/adb/ksu/bin/ksud -V 2>/dev/null)" >> "$OUT"
command -v su >/dev/null 2>&1 && echo "su: $(command -v su)" >> "$OUT"

sec "3. 模块安装状态"
if [ -d "$MODDIR" ]; then
  echo "模块目录存在：$MODDIR" >> "$OUT"
  echo "-- module.prop --" >> "$OUT"
  cat "$MODDIR/module.prop" >> "$OUT" 2>&1
  if [ -f "$MODDIR/disable" ]; then
    echo "" >> "$OUT"
    echo "⚠️ 模块处于禁用状态（存在 disable 标记）" >> "$OUT"
  fi
  if [ -f "$MODDIR/remove" ]; then
    echo "⚠️ 模块标记为待卸载（存在 remove 标记）" >> "$OUT"
  fi
else
  echo "❌ 模块目录不存在：$MODDIR（可能没装成功或被卸载）" >> "$OUT"
fi

sec "4. 工作目录与内核文件"
ls -l "$WORKDIR" >> "$OUT" 2>&1
echo "" >> "$OUT"
echo "-- core 目录（内核二进制）--" >> "$OUT"
ls -l "$WORKDIR/core" >> "$OUT" 2>&1
echo "" >> "$OUT"
echo "-- 内核可执行性检查 --" >> "$OUT"
for c in mihomo-jieluojun mihomo-liuran001 mihomo-official; do
  f="$WORKDIR/core/$c"
  if [ -f "$f" ]; then
    echo "$c: 存在 $(ls -l "$f" | awk '{print $5" bytes"}') 权限 $(ls -l "$f" | awk '{print $1}')" >> "$OUT"
    "$f" -v >> "$OUT" 2>&1 | head -3
  fi
done
echo "" >> "$OUT"
echo "-- config.yaml --" >> "$OUT"
if [ -f "$CFG" ]; then
  echo "大小：$(wc -c < "$CFG") 字节，行数：$(wc -l < "$CFG")" >> "$OUT"
  echo "（配置内容含节点信息，本脚本不输出，避免泄露）" >> "$OUT"
else
  echo "❌ config.yaml 不存在" >> "$OUT"
fi
echo "" >> "$OUT"
echo "-- module-settings.conf --" >> "$OUT"
cat "$WORKDIR/module-settings.conf" >> "$OUT" 2>&1

sec "5. 运行状态"
if [ -f "$RUNDIR/core.pid" ]; then
  _pid=$(cat "$RUNDIR/core.pid" 2>/dev/null)
  echo "pid 文件：$_pid" >> "$OUT"
  if [ -n "$_pid" ] && kill -0 "$_pid" 2>/dev/null; then
    echo "✅ 进程存活" >> "$OUT"
  else
    echo "❌ 进程不在（pid 文件残留）" >> "$OUT"
  fi
else
  echo "无 pid 文件（内核未启动）" >> "$OUT"
fi
run "进程列表" ps -A 2>/dev/null
echo "" >> "$OUT"
echo "-- run 目录 --" >> "$OUT"
ls -l "$RUNDIR" >> "$OUT" 2>&1
echo "" >> "$OUT"
echo "-- 面板服务端口 --" >> "$OUT"
for p in 9090 8080 9091 7890 1053; do
  if command -v ss >/dev/null 2>&1; then
    ss -lntp 2>/dev/null | grep ":$p" >> "$OUT"
  elif command -v netstat >/dev/null 2>&1; then
    netstat -lntp 2>/dev/null | grep ":$p" >> "$OUT"
  fi
done

sec "6. 内核运行日志（core.log 末尾 150 行）"
if [ -f "$RUNDIR/core.log" ]; then
  echo "文件大小：$(wc -c < "$RUNDIR/core.log") 字节" >> "$OUT"
  echo "⚠️ 日志可能含节点地址/密码，外发前请自行检查" >> "$OUT"
  tail -n 150 "$RUNDIR/core.log" >> "$OUT" 2>&1
else
  echo "❌ 无 core.log" >> "$OUT"
fi

sec "7. 模块日志（mihomo.sh logs 末尾）"
if [ -x "$CTL" ] || [ -f "$CTL" ]; then
  ( cd "$MODDIR" 2>/dev/null; impatient 20 sh "$CTL" logs 2>&1 | tail -n 120 ) >> "$OUT" 2>&1
else
  echo "找不到控制脚本：$CTL" >> "$OUT"
fi

sec "8. 配置校验（mihomo.sh test）"
if [ -f "$CTL" ]; then
  ( cd "$MODDIR" 2>/dev/null; impatient 40 sh "$CTL" test 2>&1 | tail -n 60 ) >> "$OUT" 2>&1
else
  echo "跳过：控制脚本不存在" >> "$OUT"
fi

sec "9. 网络与代理状态"
echo "-- IP 地址 --" >> "$OUT"
ip -4 addr show 2>/dev/null | grep -E "inet |^[0-9]+:" >> "$OUT"
echo "" >> "$OUT"
echo "-- 路由表 --" >> "$OUT"
ip route show 2>/dev/null >> "$OUT"
echo "" >> "$OUT"
echo "-- 默认路由 --" >> "$OUT"
ip route get 1.1.1.1 2>/dev/null >> "$OUT"
echo "" >> "$OUT"
echo "-- DNS 设置 --" >> "$OUT"
getprop | grep -E "net\.dns|dns" >> "$OUT" 2>&1
echo "" >> "$OUT"
echo "-- TUN 网卡 --" >> "$OUT"
ip link show 2>/dev/null | grep -iE "tun|utun" >> "$OUT"
echo "" >> "$OUT"
echo "-- iptables 相关规则条数 --" >> "$OUT"
iptables -t nat -S 2>/dev/null | grep -cE "mihomo|clash|TPROXY|REDIRECT" >> "$OUT" 2>&1
echo "-- 连通性测试 --" >> "$OUT"
ping -c 2 -W 2 1.1.1.1 >> "$OUT" 2>&1
echo "" >> "$OUT"
ping -c 2 -W 2 223.5.5.5 >> "$OUT" 2>&1

sec "10. 完成"
echo "报告已生成：$OUT" >> "$OUT"
echo "" >&2
echo "报告已生成：$OUT"
echo "请把这个 txt 文件发给豆包，并附上你遇到的具体现象。"
echo "外发前建议打开看一眼，日志里可能包含节点地址、密码等信息。"
