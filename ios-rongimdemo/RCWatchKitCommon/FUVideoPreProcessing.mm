//
//  AGVideoPreProcessing.m
//  OpenVideoCall
//
//  Created by Alex Zheng on 7/28/16.
//  Copyright © 2016 Agora.io All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FUVideoPreProcessing.h"

#import <AgoraRtcEngineKit/IAgoraMediaEngine.h>
#import <RongCallLib/IVideoFrameObserver.h>
#import <string.h>

class FUAgoraAudioFrameObserver : public agora::media::IAudioFrameObserver
{
public:
  virtual bool onRecordAudioFrame(AudioFrame& audioFrame) override
  {
    return true;
  }
  virtual bool onPlaybackAudioFrame(AudioFrame& audioFrame) override
  {
    return true;
  }
  virtual bool onPlaybackAudioFrameBeforeMixing(unsigned int uid, AudioFrame& audioFrame) override
  {
    return true;
  }
};

class FUAgoraVideoFrameObserver : public agora::media::IVideoFrameObserver
{
public:
  virtual bool onCaptureVideoFrame(VideoFrame& videoFrame) override
  {
//    int width = videoFrame.width;
    int height = videoFrame.height;
    
    memset(videoFrame.uBuffer, 128, videoFrame.uStride*height/2);
    memset(videoFrame.vBuffer, 128, videoFrame.vStride*height/2);
    return true;
  }
  virtual bool onRenderVideoFrame(unsigned int uid, VideoFrame& videoFrame) override
  {
    return true;
  }
};

//static AgoraAudioFrameObserver s_audioFrameObserver;
static FUAgoraVideoFrameObserver s_videoFrameObserver;


@implementation FUVideoPreProcessing


+ (int) registerVideoPreprocessing
{
    agoraRegisterVideoFrameObserver(&s_videoFrameObserver,true,true);
 
  return 0;
}

//+ (int) deregisterVideoPreprocessing: (AgoraRtcEngineKit*) kit
//{
//  if (!kit) {
//    return -1;
//  }
//  
//  agora::rtc::IRtcEngine* rtc_engine = (agora::rtc::IRtcEngine*)kit.getNativeHandle;
//  agora::util::AutoPtr<agora::media::IMediaEngine> mediaEngine;
//  mediaEngine.queryInterface(*rtc_engine, agora::rtc::AGORA_IID_MEDIA_ENGINE);
//  if (mediaEngine)
//  {
//    //mediaEngine->registerAudioFrameObserver(NULL);
//    mediaEngine->registerVideoFrameObserver(NULL);
//  }
//  return 0;
//}

@end
