#!/bin/bash
set -e
function isScreenOn() {
    adb connect 192.168.50.128
    screen_info=`adb shell dumpsys input_method | grep mInteractive=true`
    if [[ $screen_info == *"mInteractive"* ]]
    then
        echo "Screen is ON"
        return 0
    else
        echo "Screen is OFF"
        return 1 
    fi
}
echo Sony Tv Auto Shutdown
echo
echo Wait 5 minutes...
sleep 300
while :
do
    CLOSE_TV=1
    for i in 1 2 3 4 5
    do
        if isScreenOn; then
            CLOSE_TV=0
            echo "Skip"
            break;
        fi
        echo Wait 2 minutes...
        sleep 120
    done
    if [[ "$CLOSE_TV" == 1 ]];
    then
        echo "Shutdown"
        adb shell reboot -p
        adb disconnect
    fi
    echo Wait 10 minutes...
    sleep 600
done