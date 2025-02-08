#!/bin/bash

# TV的IP地址和端口
TV_IP="192.168.88.112"
TV_PORT="5555"
CHECK_INTERVAL=300  # 每次检测间隔5分钟
RETRY_INTERVAL=1800  # 每次大循环间隔30分钟

# 连接TV
connect_tv() {
    echo "Attempting to connect to TV at $TV_IP:$TV_PORT..."
    connect_output=$(adb connect $TV_IP:$TV_PORT 2>&1)
    
    if [[ $connect_output == *"connected"* || $connect_output == *"already"* ]]; then
        echo "Connected to TV."
        return 0
    else
        echo "Failed to connect to TV. It may be powered off."
        return 1
    fi
}

# 检测屏幕状态（增加连接状态检测）
isScreenOn() {
    # 第一次尝试获取状态
    screen_info=$(adb shell dumpsys input_method 2>/dev/null | grep mInteractive=true)
    adb_exit_code=$?
    if [[ $adb_exit_code -ne 0 ]]; then
        # ADB命令失败时尝试重连
        connect_tv || return 2
        # 重连成功后再次尝试获取状态
        screen_info=$(adb shell dumpsys input_method 2>/dev/null | grep mInteractive=true)
        adb_exit_code=$?
        [[ $adb_exit_code -ne 0 ]] && return 2
    fi

    # 解析屏幕状态
    if [[ $screen_info == *"mInteractive"* ]]; then
        echo "Screen is ON"
        return 0
    else
        echo "Screen is OFF"
        return 1
    fi
}

# 主逻辑
echo "Start Sony TV Auto Shutdown"

while :; do
    # 尝试连接TV
    if ! connect_tv; then
        echo "TV is unreachable. Retrying in $RETRY_INTERVAL seconds..."
        sleep $RETRY_INTERVAL
        continue
    fi

    SHOULD_SHUTDOWN=1
    for i in {1..12}; do
        isScreenOn
        case $? in
            0)  # 屏幕开启
                SHOULD_SHUTDOWN=0
                echo "Screen is ON, skip shutdown."
                break
                ;;
            1)  # 屏幕关闭
                echo "Screen is OFF, check $i/12. Waiting $CHECK_INTERVAL seconds..."
                sleep $CHECK_INTERVAL
                ;;
            *)  # 连接失败
                SHOULD_SHUTDOWN=0
                echo "Connection lost during check. Retrying in $RETRY_INTERVAL seconds..."
                sleep $RETRY_INTERVAL
                continue 2  # 继续外层循环，重新连接
                ;;
        esac
    done

    if [[ "$SHOULD_SHUTDOWN" == 1 ]]; then
        echo "Screen has been OFF for 1 hour. Shutting down..."
        if adb shell reboot -p; then
            echo "TV has been shut down."
        else
            echo "Failed to send shutdown command. TV may already be off."
        fi
        adb disconnect
        echo "Disconnected from TV."
    fi

    echo "Wait $RETRY_INTERVAL seconds before next check..."
    sleep $RETRY_INTERVAL
done
