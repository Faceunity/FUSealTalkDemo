//
//  FUVideoFrameObserver.mm
//  RongCallLib
//
//  Created by litao on 16/5/16.
//  Copyright © 2016年 Rong Cloud. All rights reserved.
//

#import "FUVideoFrameObserverManager.h"
#import <RongCallKit/RongCallKit.h>

#ifndef FUVideoFrameObserver_hpp
#define FUVideoFrameObserver_hpp
#include <RongCallLib/IVideoFrameObserver.h>
#import <UIKit/UIKit.h>
#include <stdio.h>
#import <AgoraRtcEngineKit/IAgoraMediaEngine.h>

#import "FUManager.h"

class FUVideoFrameObserver : public agora::media::IVideoFrameObserver {
public:
    static FUVideoFrameObserver *sharedObserver();
    unsigned int m_width;
    unsigned int m_height;
    unsigned int m_yStride;
    unsigned int m_uStride;
    unsigned int m_vStride;
    
    unsigned char *m_yBuffer;
    unsigned char *m_uBuffer;
    unsigned char *m_vBuffer;
    
    FUVideoFrameObserver();
    void setYUV(unsigned char *yBuffer, unsigned char *uBuffer,
                unsigned char *vBuffer, int width, int height);
    
    bool onCaptureVideoFrame(VideoFrame& videoFrame) ;
    bool onRenderVideoFrame(unsigned int uid, VideoFrame& videoFrame) ;
    
    virtual ~FUVideoFrameObserver();
};
#endif /* FUVideoFrameObserver_hpp */

static NSLock *s_lock;
FUVideoFrameObserver *FUVideoFrameObserver::sharedObserver() {
  static FUVideoFrameObserver sharedObserver;
  return &sharedObserver;
}

FUVideoFrameObserver::FUVideoFrameObserver() {
  m_width = 0;
  m_height = 0;
  m_yStride = 0;
  m_uStride = 0;
  m_vStride = 0;

  m_yBuffer = NULL;
  m_uBuffer = NULL;
  m_vBuffer = NULL;
  s_lock = [[NSLock alloc] init];
}

FUVideoFrameObserver::~FUVideoFrameObserver() {
  if (m_yBuffer) {
    delete[] m_yBuffer;
  }
  if (m_uBuffer) {
    delete[] m_uBuffer;
  }
  if (m_vBuffer) {
    delete[] m_vBuffer;
  }
  s_lock = nil;
}

bool FUVideoFrameObserver::onCaptureVideoFrame(agora::media::IVideoFrameObserver::VideoFrame& videoFrame)  {

    [[FUManager shareManager] processFrameWithY:videoFrame.yBuffer U:videoFrame.uBuffer V:videoFrame.vBuffer yStride:videoFrame.yStride uStride:videoFrame.uStride vStride:videoFrame.vStride FrameWidth:videoFrame.width FrameHeight:videoFrame.height];
    
  return true;
}

bool FUVideoFrameObserver::onRenderVideoFrame(unsigned int uid, agora::media::IVideoFrameObserver::VideoFrame& videoFrame) {
  NSString *userId = rcGetUserIdFromAgoraUID(uid);
  NSLog(@"the user id is %@", userId);
  return true;
}
void FUVideoFrameObserver::setYUV(unsigned char *yBuffer,
                                   unsigned char *uBuffer,
                                   unsigned char *vBuffer, int width,
                                   int height) {
  if (m_width) {
    [s_lock lock];
    for (int i = 0; i < height; i++) {
      if (i >= m_height) {
        break;
      }
      for (int j = 0; j < width; j++) {
        if (j >= m_width) {
          break;
        }
        *(m_yBuffer + i * m_yStride + j) = *(yBuffer + i * width + j);

        if (j < m_width * m_uStride / m_yStride) {
          *(m_uBuffer + i * (m_uStride * m_uStride / m_yStride) + j) =
              *(uBuffer + i * (m_uStride * m_uStride / m_yStride) + j);
        }

        if (j < m_width * m_vStride / m_yStride) {
          *(m_vBuffer + i * (m_vStride * m_vStride / m_yStride) + j) =
              *(vBuffer + i * (m_vStride * m_vStride / m_yStride) + j);
        }
      }
    }
    [s_lock unlock];
  }
}

@implementation FUVideoFrameObserverManager

+ (int) registerVideoFrameObserver
{
    agoraRegisterVideoFrameObserver(FUVideoFrameObserver::sharedObserver(), false, true);
    return 0;
}

@end
