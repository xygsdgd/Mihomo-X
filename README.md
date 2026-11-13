# Mihomo X

Android 上基于 **Magisk / KernelSU** 的 Mihomo 模块：内置 mihomo 内核，附带本地 WebUI 管理面板，装完即可在手机上管理订阅、配置与分流。

- 当前版本：**v1.9.47**
- 作者：tg@jieluojun

## 下载安装

1. 到本仓库 **Releases** 页面，下载最新版 `Mihomo*.zip`（**不要解压**）
2. 打开 **Magisk** 或 **KernelSU** 管理器 → 模块 → 从本地安装 → 选择刚下载的 zip
3. 安装完成后 **重启手机**
4. 重启后在管理器里打开本模块的 **WebUI**（KernelSU：模块页面 → 打开；Magisk：模块自带 action 按钮）

升级同理：直接刷入新版 zip 覆盖，然后重启。配置会保留。

## 出问题了：先跑诊断，再发豆包

### 第一步：下载诊断脚本

- 网页直接看/下载：https://github.com/xygsdgd/Mihomo-X/blob/main/tools/mihomo-x-diag.sh
- 或命令行拉取：

```
curl -L -o /sdcard/diag.sh https://raw.githubusercontent.com/xygsdgd/Mihomo-X/main/tools/mihomo-x-diag.sh
```

### 第二步：运行（必须 root）

Termux 或任意终端里：

```
su
sh /sdcard/diag.sh
```

跑完会提示报告位置，一般是 `/sdcard/mihomo-x-diag-日期时间.txt`。

### 第三步：把报告发给豆包

用下面这段作为开场，再把 txt 当附件传上去：

```
我刷了 Mihomo X 模块（v1.9.47），出现的问题是：______
设备：______   Root 方式：Magisk / KernelSU
模块地址：https://github.com/xygsdgd/Mihomo-X
诊断报告在附件里
```

脚本会收集：设备与系统信息、Root 方式、模块安装状态、内核文件与可执行性、进程与 pid、监听端口、core.log 与模块日志、配置校验结果（`mihomo.sh test`）、IP/路由/DNS/TUN 网卡、iptables 规则、连通性测试。

## 为什么豆包“读不到模块”

模块装在**你手机上**，豆包在**云端**，它看不到你设备的文件、进程和网络状态。它只能读两种东西：

1. 你能打开的公网链接（比如本仓库的 README、Release 说明）
2. 你**主动上传的文件**（比如上面那个诊断 txt、截图）

所以“问模块有什么问题”这件事，正确姿势不是丢个仓库链接，而是：**仓库链接（告诉它这是哪个模块）+ 诊断 txt（告诉它你设备现在什么状态）+ 一句现象描述**。

另外，模块 zip 里主要是脚本、网页和二进制内核，豆包能读 `.sh/.js/.yaml` 这类文本，但读不了那个 70MB 的内核二进制，也不应该读——问题大多发生在运行环境，不在包本身。

## 反馈问题

- 有 GitHub 账号：在本仓库 **Issues** 新建一条，套用自带的问题模板
- 没有 GitHub 账号：把诊断报告 + 现象描述发给豆包，由作者整理归档

提问时尽量带上：

| 需要提供 | 在哪拿 |
| --- | --- |
| 模块版本 | 模块页面显示的版本号 |
| 机型 + 系统版本 | 诊断报告第 1 节 |
| Root 方式 | 诊断报告第 2 节 |
| 报错日志 | 诊断报告第 6/7/8 节 |
| 网络状态 | 诊断报告第 9 节 |

> 隐私提醒：`core.log` 和配置里可能有节点地址、密码。外发前自己看一眼，有敏感信息就删掉或打码。

## 目录结构

```
META-INF/           Magisk 安装脚本
action.sh           模块 action 按钮入口
core/               mihomo 内核
customize.sh        安装时执行脚本
data/               运行配置（config.yaml 等）
post-fs-data.sh     开机早期初始化
service.sh          开机服务启动
scripts/            运行脚本与工具
uninstall.sh        卸载清理
webroot/            本地 WebUI 面板
```

本仓额外提供：

```
tools/mihomo-x-diag.sh   一键诊断脚本（收集运行状态，不碰配置内容）
```

## 免责声明

本模块仅用于个人网络配置管理，请遵守当地法律法规与网络服务提供商的使用条款。使用本模块产生的任何后果由使用者自行承担。
