//
//  RCDUserGroupChannelBelongView.h
//  SealTalk
//
//  Created by RobinCui on 2023/1/12.
//  Copyright © 2023 RongCloud. All rights reserved.
//

#import "RCDUserGroupBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDUserGroupChannelBelongView : RCDUserGroupBaseView
@property(nonatomic, strong, readonly) UITableView *tableView;
@property(nonatomic, strong, readonly) UIButton *btnEdit;
@end

NS_ASSUME_NONNULL_END
