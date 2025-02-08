# Sony TV 自动关机脚本

## 简介

这是一个用于自动检测 Sony TV 屏幕状态并在屏幕关闭一段时间后自动关闭电视的 Bash 脚本。通过 ADB（Android Debug Bridge）连接到电视，脚本会定期检查屏幕状态，并在屏幕关闭超过 1 小时后发送关机命令。

## 功能

- **屏幕状态检测**：脚本会定期检测电视屏幕的状态（开启或关闭）。
- **自动关机**：如果屏幕关闭超过 1 小时，脚本会发送关机命令关闭电视。
- **重连机制**：如果连接中断，脚本会自动重连电视。

## 配置

在脚本中，您需要配置以下参数：

- `TV_IP`：电视的 IP 地址，例如 `192.168.88.112`。
- `TV_PORT`：电视的 ADB 端口，默认是 `5555`。
- `CHECK_INTERVAL`：每次检测屏幕状态的间隔时间，默认是 300 秒（5 分钟）。
- `RETRY_INTERVAL`：每次大循环的间隔时间，默认是 1800 秒（30 分钟）。

## 使用前提
 **电视的 ADB 调试**：确保电视已启用 ADB 调试功能，并且可以通过网络访问。


## 使用方式

### 一、在linux种运行 
1. **ADB 工具**：确保在运行脚本的设备上安装了 ADB 工具。可以通过以下命令安装：
   ```bash
   sudo apt-get install adb
   ```
2. 赋予脚本执行权限：
   ```bash
   chmod +x sony_tv_auto_shutdown.sh
   ```
3. 运行脚本：
   ```bash
   ./sony_tv_auto_shutdown.sh >> ./tv_auto_shutdown.log 2>&1
   ```
### 二、在docker种运行
1. 准备文件
确保以下文件在同一目录下：
Dockerfile
auto_shutdown.sh

2. 构建 Docker 镜像
在文件所在目录下运行以下命令：
   ```bash
    docker build -t sony-tv-auto-shutdown .
   ```
3. 运行 Docker 容器
运行以下命令启动容器：
     ```bash
       docker run -d --name sony-tv-auto-shutdown sony-tv-auto-shutdown --network host
     ```
4. 查看日志
查看容器日志：
     ```bash
       docker logs -f sony-tv-auto-shutdown
     ```

### 电视端
   脚本执行后电视端回弹出是否允许adb调试的提示，点击允许
