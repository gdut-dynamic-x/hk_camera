# hk_camera
ROS wrapper for the hk camera made by Hikrobot.

# Install dependencies
Dependencies:
- ROS Noetic
- libMvCameraControl.so  download `MVS_STD_GML_V2.1.1_220511` from
https://www.hikrobotics.com/cn/machinevision/service/download?module=0 and install,
then extract `MVS-2.1.1_x86_64_20220511.tar.gz` and decompress it.
- In the catalogue of which you decompressed, run `sudo ./setup.sh`.
  - 24年的驱动用`sudo bash setup.sh`
- Then run `sudo cp /opt/MVS/lib/64/libMvCameraControl.so /usr/lib`.
Turn
# 跑hk没有compressed话题

```shell
sudo apt-get update
sudo apt-get install ros-noetic-image-transport-plugins
```
重新跑即可

# Calibrattion steps

## 车上标定

1. 小电脑上停掉所有视觉服务(标定帧率低)，单跑相机
```shell
stopvi
mon launch hk_camera singe_device.launch
```

2. 在自己电脑上跑标定程序
```shell
rosrun camera_calibration cameracalibrator.py --size 11x8 --square 0.020 image:=/hk_camera/image_raw camera:=/hk_camera
```
Tips:
* size：the size of the inner corners of the chessboard.(是内部角点的数量，不是棋盘格的格子数)
* square：the length of each square (unit：m).

3. 开始标定，直至caliberate出现绿色后，点击后，等命令行有反应后再点save，此时标定文件会保存在/tmp下(命令行会显示)

4. cd进/tmp，将标定文件传进小电脑的/.ros/camera_info/中
```shell
cd /tmp/calibrationdata
scp xxxx.yaml dynamicx@192.168.100.2:/home/dynamicx/.ros/camera_info/
```

5. 修改参数文件

![alt text](pictures/calibrate1.png)
(改哪个文件要看rm_config/launch/vision/camera.launch里加载的是哪个yaml,一般是camera.yaml)

![alt text](pictures/calibrate2.png)
修改下面两个参数
* camera_info_url:对应标定文件的路径(为空默认路径为file:///home/dynamicx/.ros/camera_info/hk_camera.yaml)
* camera_name:相机名字，对应标定文件中的camera_name

改完后把参数文件传到车上

6. 修改小电脑中对应标定文件的名字和里面的camera_name

## 直连相机标定

同车上标定一样，在自己电脑上标定完后，把标定文件传到车上即可(记得改yaml)

More information:

- http://wiki.ros.org/image_pipeline
