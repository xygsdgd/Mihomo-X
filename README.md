# Mihomo X

Android 上基于 **Magisk / KernelSU** 的 Mihomo 模块：内置 mihomo 内核，附带本地 WebUI 管理面板，装完即可在手机上管理订阅、配置与分流。

- 当前版本：**v1.9.47**
- 作者：tg@jieluojun

## 下载安装

1. 到本仓库 **Releases** 页面，下载最新版 `Mihomo X-V*.zip`（**不要解压**）
2. 打开 **Magisk** 或 **KernelSU** 管理器 → 模块 → 从本地安装 → 选择刚下载的 zip
3. 安装完成后 **重启手机**
4. 重启后在管理器里打开本模块的 **WebUI**（KernelSU：模块页面 → 打开；Magisk：模块自带 action 按钮 / 浏览器访问本地地址）

升级同理：直接刷入新版 zip 覆盖，然后重启。配置会保留。

## 遇到问题怎么办

把下面这段**复制发给豆包**，再补上你的实际情况：

```
我刷了 Mihomo X 模块（版本 v1.9.47），出现的问题是：______
设备系统：______   Root 方式：Magisk / KernelSU
模块地址：https://github.com/xygsdgd/Mihomo-X
```

再把**模块日志**和**报错截图**一起发过去。豆包会读本仓库的说明和你的日志，给出排查步骤。

> 提醒：豆包只能帮你看日志、判断原因、给操作步骤；下载和刷入仍需你自己在手机上完成。

## 反馈问题

- 有 GitHub 账号：在本仓库 **Issues** 里新建一条，写清版本、机型、现象、已尝试的操作
- 没有 GitHub 账号：按上面的方式发给豆包，由作者整理归档

提问时尽量带上这几样，定位会快很多：

| 需要提供 | 在哪拿 |
| --- | --- |
| 模块版本 | 模块页面显示的版本号 |
| 机型 + 系统版本 | 设置 → 关于手机 |
| Root 方式 | Magisk / KernelSU / APatch |
| 报错日志 | WebUI 内日志页，或 `/data/adb/modules/mihomo_x/` 下的日志文件 |
| 现象描述 | 什么时候开始的、改了什么之后出现的 |

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

## 免责声明

本模块仅用于个人网络配置管理，请遵守当地法律法规与网络服务提供商的使用条款。使用本模块产生的任何后果由使用者自行承担。
