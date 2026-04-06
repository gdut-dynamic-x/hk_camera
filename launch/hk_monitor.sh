#!/bin/bash

source /opt/ros/noetic/setup.bash
source /home/lovod/rm_code/devel/setup.bash

# 启动初始摄像头节点
roslaunch hk_camera single_device.launch >/dev/null 2>&1 & LAUNCH_PID=$!
echo "初始进程PID：$LAUNCH_PID"
sleep 3  # 等待节点初始化

check_camera_fps()
{
    echo "检查摄像头帧率..."
    # 增加超时时间至5秒，确保数据采集
    output=$(timeout 3s rostopic hz /hk_camera/image_raw 2>&1)
    echo "rostopic原始输出：$output"
    # 提取帧率（兼容整数和小数）
    FPS=$(echo "$output" | awk '/average rate:/ {gsub("Hz",""); fps=$3} END {print fps}' | cut -d '.' -f1)
    echo "当前帧率：$FPS"

  if [[ -z $FPS ]]; then
    echo "错误：无法获取摄像头帧率，请检查话题/hk_camera/image_raw"
    return 1
  elif [[ $FPS =~ ^[0-9]+$ ]]; then
    if (( FPS < 150 )); then
      echo "帧率过低：$FPS Hz，未达到150 Hz要求"
      return 1
    else
      echo "帧率正常：$FPS Hz"
      return 0
    fi
  else
    echo "非数值帧率：$FPS"
    return 1
  fi
}

kill_ros_process()
{
  echo "终止ROS相关进程..."
  kill -INT -$LAUNCH_PID 2>/dev/null
  sleep 1
}

while true; do
  if ! check_camera_fps; then
    echo "正在终止原有摄像头节点..."
    kill_ros_process

    echo "重新启动摄像头节点..."
    roslaunch hk_camera single_device.launch >/dev/null 2>&1 & LAUNCH_PID=$!
    echo "新进程PID：$LAUNCH_PID"
    sleep 3  # 确保节点初始化完成
  fi
done

trap "kill_ros_process; exit" SIGINT
