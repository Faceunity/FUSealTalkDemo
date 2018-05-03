# FUSealTalkDemo 快速集成文档

FUSealTalkDemo 是集成了 Faceunity 面部跟踪和虚拟道具功能 和 [SealTalk](https://github.com/sealtalk/sealtalk-ios) 功能的 Demo。

本文是 FaceUnity SDK 快速对接融云 SealTalk 的导读说明，关于 `FaceUnity SDK` 的详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)

## 主要文件说明

**FUManager** 对 FaceUnity SDK 接口和数据的简单封装。

**FUView** 展示 FaceUnity 效果的 UI。

## 快速集成方法

### 一、获取视频数据回调

首先在进行视频通话的时候拿到摄像头采集到的视频数据，参照 FUVideoFrameObserverManager 编写视频数据注册类， 在发起视频通话之前和注册监听接听视频的时候调用下面的方法进行注册：

```C
[FUVideoFrameObserverManager registerVideoFrameObserver];
```
本例中此方法在 FUView 类的 addToKeyWindow（将控制美颜贴纸的界面添加到主窗口上）方法中进行。

注册之后，在 FUVideoFrameObserverManager 中以下函数中便可得到视频数据，并对其进行处理。

```
FUVideoFrameObserver::onCaptureVideoFrame(agora::media::IVideoFrameObserver::VideoFrame& videoFrame)
```

需要说明的是本例中共有三处需要注册视频回调的地方，本文着重描述集成 FaceUnity SDK 的步骤，故将该内容放在文末，您可以点击[快速注册视频回调](#快速注册视频回调)进行查看。

### 二、接入 Faceunity SDK

将  FaceUnity  文件夹全部拖入工程中，并且添加依赖库 OpenGLES.framework、Accelerate.framework、CoreMedia.framework、AVFoundation.framework、stdc++.tbd

#### 1、快速加载道具

调用 FUManager 里面的 `[[FUManager shareManager] loadItems]` 加载贴纸道具及美颜道具

#### 2、图像处理

在 FUVideoFrameObserverManager 的 `FUVideoFrameObserver::onCaptureVideoFrame(agora::media::IVideoFrameObserver::VideoFrame& videoFrame)` 方法里面进行图像处理。

```C
bool FUVideoFrameObserver::onCaptureVideoFrame(agora::media::IVideoFrameObserver::VideoFrame& videoFrame)  {

    [[FUManager shareManager] processFrameWithY:videoFrame.yBuffer U:videoFrame.uBuffer V:videoFrame.vBuffer yStride:videoFrame.yStride uStride:videoFrame.uStride vStride:videoFrame.vStride FrameWidth:videoFrame.width FrameHeight:videoFrame.height];
    
  return true;
}
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

## 快速注册视频回调

#### 1、在联系人列表点击视频通话按钮直接发起视频通话

在  RCDPersonDetailViewController.m  的 `btnVideoCall:` 方法中调用 `[[FUView shareInstance] addToKeyWindow];` 即可在发起视频通话的时候 将  FUView  的内容添加到主窗口上。

#### 2、在聊天页面发起视频通话

在  RCDChatViewController.m  的 `pluginBoardView: clickedItemWithTag:` 方法中的 `switch`语句中 添加如下代码即可

```C
case PLUGIN_BOARD_ITEM_VIDEO_VOIP_TAG: {
    
    [[RCCall sharedRCCall] startSingleCall:self.targetId mediaType:RCCallMediaVideo];
    [[FUView shareInstance] addToKeyWindow];
}
    break ;
```

#### 3、监听视频通话来电
在  AppDelegate.m  中添加头文件

```C
#import <RongCallLib/RongCallLib.h>
#import "FUView.h"
```

在  `application: didFinishLaunchingWithOptions: `方法中添加监听接听代理 

```C
[[RCCallClient sharedRCCallClient] setDelegate:self ];
```
实现 接听通话 `didReceiveCall:` 代理方法

```C
- (void)didReceiveCall:(RCCallSession *)callSession {
    
    // 接听通话界面
    RCCallSingleCallViewController *singleCallViewController =
    [[RCCallSingleCallViewController alloc] initWithActiveCall:callSession];

    [[RCCall sharedRCCall] presentCallViewController:singleCallViewController];
    
    // FU 美颜贴纸界面
    [[FUView shareInstance] addToKeyWindow];
}
```

**注：如果在 RongCallKit.framework 中找不到  RCCallSingleCallViewController 类， 请获取 RongCallKit.framework  源码，重新自行打包 或者 直接将  RongCallKit.framework  源码拉进工程替换  RongCallKit.framework .**