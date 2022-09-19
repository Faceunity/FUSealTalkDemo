//
//  RCDLoginManager.h
//  SealTalk
//
//  Created by LiFei on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCDLoginAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDLoginManager : NSObject

// 用户登录
+ (void)loginWithPhone:(NSString *)phone
              password:(NSString *)password
                region:(NSString *)region
               success:(void (^)(NSString *token, NSString *userId))successBlock
                 error:(void (^)(RCDLoginErrorCode errorCode))errorBlock;

+ (void)loginWithPhone:(NSString *)phone
      verificationCode:(NSString *)verificationCode
                region:(NSString *)region
               success:(void (^)(NSString *token, NSString *userId, NSString *nickName))successBlock
                 error:(void (^)(RCDLoginErrorCode errorCode))errorBlock;

// 当前用户注销
+ (void)logout:(void (^)(BOOL success))completeBlock;

+ (BOOL)openDB:(NSString *)currentUserId;


// 向手机发送验证码(云片服务)
+ (void)getVerificationCode:(NSString *)phoneCode
                phoneNumber:(NSString *)phoneNumber
                    success:(void (^)(BOOL success))successBlock
                      error:(void (^)(RCDLoginErrorCode errorCode, NSString *errorMsg))errorBlock;

// 验证验证码(云片服务)
+ (void)verifyVerificationCode:(NSString *)phoneCode
                   phoneNumber:(NSString *)phoneNumber
              verificationCode:(NSString *)verificationCode
                       success:(void (^)(BOOL success, NSString *codeToken))successBlock
                         error:(void (^)(RCDLoginErrorCode errorCode))errorBlock;

// 获取所有区域信息
+ (void)getRegionlist:(void (^)(NSArray *countryArray))completeBlock;

// 获取融云 Token
+ (void)getToken:(void (^)(BOOL success, NSString *token, NSString *userId))completeBlock;

@end

NS_ASSUME_NONNULL_END
