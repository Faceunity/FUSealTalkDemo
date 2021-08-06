# FURCloudMessage 快速接入文档

FURCloudMessage 是集成了 Faceunity 面部跟踪和虚拟道具功能 和 融云sealtalk  的 Demo。

本文是 FaceUnity SDK 快速对融云 [sealtalk] (https://github.com/sealtalk/sealtalk-ios) demo的导读说明，关于 `FaceUnity SDK` 的详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo)

## 快速集成方法

### 一、导入 SDK

将  FaceUnity  文件夹全部拖入工程中，NamaSDK所需依赖库为 `OpenGLES.framework`、`Accelerate.framework`、`CoreMedia.framework`、`AVFoundation.framework`、`libc++.tbd`、`CoreML.framework`

- 备注: 运行在iOS11以下系统时,需要手动添加`CoreML.framework`,并在**TARGETS -> Build Phases-> Link Binary With Libraries**将`CoreML.framework`手动修改为可选**Optional**

### FaceUnity 模块简介

```objc
+ Abstract          // 美颜参数数据源业务文件夹
    + FUProvider    // 美颜参数数据源提供者
    + ViewModel     // 模型视图参数传递者
-FUManager          //nama 业务类
-authpack.h         //权限文件  
+FUAPIDemoBar     //美颜工具条,可自定义
+items            //美妆贴纸 xx.bundel文件

```

### 二、加入展示 FaceUnity SDK 美颜贴纸效果的  UI

1、在 RCCallBaseViewController.m  中添加头文件
```objc
#import "FUManager.h"
#import "UIViewController+FaceUnityUIExtension.h"
```

2、在 `viewDidLoad` 方法中初始化FU `setupFaceUnity` 会初始化FUSDK,和添加美颜工具条,具体实现可查看 `UIViewController+FaceUnityUIExtension.m`
```objc
[self setupFaceUnity];
```

### 三、图片数据处理
在processVideoFrame添加数据回调代理方法,将数据传由Faceunity处理

```C
- (CMSampleBufferRef)processVideoFrame:(CMSampleBufferRef)sampleBuffer{
    
    //在此处处理sampleBuffer后同步返回, 当前 [[RCCallClient sharedRCCallClient] setEnableBeauty:YES]; 已经打开
    //目前返回nil, 则显示的是我们底层默认的美颜滤镜
    
    /* ------ faceU ------ */
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) ;
    [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];
    
    return sampleBuffer;
}
```


### 四、销毁道具和切换摄像头

1 视图控制器生命周期结束时 `[[FUManager shareManager] destoryItems];`销毁道具。

2 切换摄像头需要调用 `[[FUManager shareManager] onCameraChange];`切换摄像头

### 关于 FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo)