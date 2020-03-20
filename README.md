# FUSealTalkDemo 快速集成文档

FUSealTalkDemo 是集成了 Faceunity 面部跟踪和虚拟道具功能 和 [SealTalk](https://github.com/sealtalk/sealtalk-ios) 功能的 Demo。

本文是 FaceUnity SDK 快速对接融云 SealTalk 的导读说明，关于 `FaceUnity SDK` 的详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)



## 运行 SealTalk-iOS

SealTalk 从 2.0.0 版本开始改用 cocoaPods 管理融云 SDK 库和其他第三方库，下载完源码后，按照下面步骤操作

1.终端进入 Podfile 目录

2.更新本地 CocoaPods 的本地仓库，终端执行下面命令

```
$ pod repo update
```

3.下载 Podfile 中的依赖库，终端执行下面命令

```
$ pod install
```



## 主要文件说明

**FUManager** 对 FaceUnity SDK 接口和数据的简单封装。

## 快速集成方法

### 一、获取视频数据回调

首先在进行视频通话的时候拿到摄像头采集到的视频数据，参照 RCCallBaseViewController 中代码：

1.设置外部美颜

```C
[[RCCallClient sharedRCCallClient] setEnableBeauty:YES];
```
2.实现视频回调代理,在回调函数中处理图形

```
-(CMSampleBufferRef)processVideoFrame:(CMSampleBufferRef)sampleBuffer{
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];
    
    return sampleBuffer;
}
```

### 二、接入 Faceunity SDK

将  FaceUnity  文件夹全部拖入工程中，并且添加依赖库 OpenGLES.framework、Accelerate.framework、CoreMedia.framework、AVFoundation.framework、stdc++.tbd

#### 1、快速加载道具

调用 FUManager 里面的 `[[FUManager shareManager] loadItems]` 加载贴纸道具及美颜道具

#### 2、图像处理

在 视频回调函数中__processVideoFrame__中

```C
  CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];
    
```

#### 3、道具切换

调用 `[[FUManager shareManager] loadItem: itemName];` 切换道具

#### 4、更新美颜参数

```C
- (void)demoBarBeautyParamChanged {
    
    [FUManager shareManager].skinDetectEnable = _demoBar.skinDetectEnable;
    [FUManager shareManager].blurShape = _demoBar.blurShape;
    [FUManager shareManager].blurLevel = _demoBar.blurLevel ;
    [FUManager shareManager].whiteLevel = _demoBar.whiteLevel;
    [FUManager shareManager].redLevel = _demoBar.redLevel;
    [FUManager shareManager].eyelightingLevel = _demoBar.eyelightingLevel;
    [FUManager shareManager].beautyToothLevel = _demoBar.beautyToothLevel;
    [FUManager shareManager].faceShape = _demoBar.faceShape;
    [FUManager shareManager].enlargingLevel = _demoBar.enlargingLevel;
    [FUManager shareManager].thinningLevel = _demoBar.thinningLevel;
    [FUManager shareManager].enlargingLevel_new = _demoBar.enlargingLevel_new;
    [FUManager shareManager].thinningLevel_new = _demoBar.thinningLevel_new;
    [FUManager shareManager].jewLevel = _demoBar.jewLevel;
    [FUManager shareManager].foreheadLevel = _demoBar.foreheadLevel;
    [FUManager shareManager].noseLevel = _demoBar.noseLevel;
    [FUManager shareManager].mouthLevel = _demoBar.mouthLevel;
    [FUManager shareManager].selectedFilter = _demoBar.selectedFilter ;
    [FUManager shareManager].selectedFilterLevel = _demoBar.selectedFilterLevel;
}
```

#### 4、道具销毁

调用 `[[FUManager shareManager] destoryItems];` 销毁贴纸及美颜道具。

**注：如果在 RongCallKit.framework 中找不到  RCCallSingleCallViewController 类， 请获取 RongCallKit.framework  源码，重新自行打包 或者 直接将  RongCallKit.framework  源码拉进工程替换  RongCallKit.framework .**

demo使用RongCallKit 源码方式集成