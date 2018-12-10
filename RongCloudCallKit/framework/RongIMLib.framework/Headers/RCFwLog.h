//
//  RCFwLog.h
//  MacLogTest
//
//  Created by ZhangLei on 26/02/2018.
//  Copyright © 2018 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#define __FILE_STRING__ [NSString stringWithUTF8String:__FILE__]
#define __GET_FILENAME__ [__FILE_STRING__ substringFromIndex:[__FILE_STRING__ rangeOfString:@"/" options:NSBackwardsSearch].location + 1]

#define RCLogF(k, ...) [[RCFwLog getInstance] write:Level_F type:Type_DEB tag:__GET_FILENAME__ keys:k, ##__VA_ARGS__]
#define RCLogE(k, ...) [[RCFwLog getInstance] write:Level_E type:Type_DEB tag:__GET_FILENAME__ keys:k, ##__VA_ARGS__]
#define RCLogW(k, ...) [[RCFwLog getInstance] write:Level_W type:Type_DEB tag:__GET_FILENAME__ keys:k, ##__VA_ARGS__]
#define RCLogI(k, ...) [[RCFwLog getInstance] write:Level_I type:Type_DEB tag:__GET_FILENAME__ keys:k, ##__VA_ARGS__]
#define RCLogD(k, ...) [[RCFwLog getInstance] write:Level_D type:Type_DEB tag:__GET_FILENAME__ keys:k, ##__VA_ARGS__]
#define RCLogV(k, ...) [[RCFwLog getInstance] write:Level_V type:Type_DEB tag:__GET_FILENAME__ keys:k, ##__VA_ARGS__]

#define FwLogF(p, t, k, ...) [[RCFwLog getInstance] write:Level_F type:p tag:t keys:k, ##__VA_ARGS__]
#define FwLogE(p, t, k, ...) [[RCFwLog getInstance] write:Level_E type:p tag:t keys:k, ##__VA_ARGS__]
#define FwLogW(p, t, k, ...) [[RCFwLog getInstance] write:Level_W type:p tag:t keys:k, ##__VA_ARGS__]
#define FwLogI(p, t, k, ...) [[RCFwLog getInstance] write:Level_I type:p tag:t keys:k, ##__VA_ARGS__]
#define FwLogD(p, t, k, ...) [[RCFwLog getInstance] write:Level_D type:p tag:t keys:k, ##__VA_ARGS__]
#define FwLogV(p, t, k, ...) [[RCFwLog getInstance] write:Level_V type:p tag:t keys:k, ##__VA_ARGS__]

typedef NS_ENUM(NSUInteger, LogLevel) { Level_F = 1, Level_E = 2, Level_W = 3, Level_I = 4, Level_D = 5, Level_V = 6 };

typedef NS_OPTIONS(NSUInteger, LogType) {
    Type_APP = 1 << 0,  // User interface.
    Type_PTC = 1 << 1,  // Protocol.
    Type_ENV = 1 << 2,
    Type_DET = 1 << 3,
    Type_CON = 1 << 4,
    Type_RCO = 1 << 5,
    Type_CRM = 1 << 6,
    Type_MSG = 1 << 7,  // Message.
    Type_MED = 1 << 8,  // Media file.
    Type_LOG = 1 << 9,
    Type_DEB = 1 << 10  // Debug log.
};

@interface RCFwLog : NSObject

// should be call init first, otherwise getInstance will return nil.
+ (void)init:(NSString *)appKey sdkVer:(NSString *)sdkVer;
+ (instancetype)getInstance;

+ (void)setLogMonitor:(NSInteger)value;
+ (void)setToken:(NSString *)token;
+ (void)setUserId:(NSString *)userId;
+ (void)setLogListener:(void (^)(NSString *log))logBlock;
+ (void)setLogLevel:(LogLevel)level;
+ (NSString *)getIpWithHost:(NSString *)hostName;
- (void)write:(LogLevel)level
         type:(LogType)type
          tag:(NSString *)tag
         keys:(NSString *)keys, ... NS_FORMAT_FUNCTION(4, 5);

@end
