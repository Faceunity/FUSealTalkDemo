//
//  RCDUGSettingsController.m
//  SealTalk
//
//  Created by RobinCui on 2022/8/1.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDUGSettingsController.h"
#import "RCDUGListView.h"
#import "RCDUGSelectListViewController.h"
#import "RCDUnreadCountViewController.h"
#import "RCDUGMentionedViewController.h"
#import "RCDDebugUltraGroupListController.h"
#import "RCDDebugComChatListController.h"
#import "RCDDotterViewController.h"
#import "RCDLocalMessagesViewController.h"
#import "RCDStickerTest.h"

NSString *const RCDUGSettingsControllerCellIdentifier = @"RCDUGSettingsControllerCellIdentifier";
NSString *const RCDUGSettingsTitle = @"RCDUGSettingsTitle";
NSString *const RCDUGSettingsRows = @"RCDUGSettingsRows";
NSString *const RCDUGSettingsCategory = @"RCDUGSettingsCategory";

typedef NS_ENUM(NSInteger, RCDUGSettingsBlockType) {
    RCDUGSettingsBlockTypeUltraGroup, // 超级群
    RCDUGSettingsBlockTypeGroup,  // 普通
    CDUGSettingsBlockTypeLocalMessages,  // 普通
};

typedef NS_ENUM(NSInteger, RCDUnreadCoutType) {
    RCDUnreadCoutTypeConversation, // 获取会话未读消息数
    RCDUnreadCoutTypeConversationMentioned, //获取会话未读 @消息数
    RCGUnreadCoutTypeUltraGroup, // 获取指定超级群会话的未读消息数（包括所有频道)
    RCGUnreadCoutTypeUltraGroupMentioned, // 获取指定超级群会话的未读@消息数（包括所有频道）
    RCGUnreadCoutTypeDegistList // 超级群获取未读 @消息列表(摘要列表)
};

typedef NS_ENUM(NSInteger, RCDUGSettingsOtherType) {
    RCDUGSettingsOtherTypeDot, // 打点测试
    RCDUGSettingsOtherTypeSticker, // 多线程访问sticker,
    RCDUGSettingsOtherTypeUserInfo, // 多线程访问userInfo
};

@interface RCDUGSettingsController()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) RCDUGListView *settingsView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *arrayNoDistribute;
@property (nonatomic, strong) NSArray *arrayUnreadCount;
@property (nonatomic, strong) NSArray *arrayOther;

@property (nonatomic, strong) NSDictionary *dicNoDistribute;
@property (nonatomic, strong) NSDictionary *dicUnreadCount;
@property (nonatomic, strong) NSDictionary *dicOther;
@end

@implementation RCDUGSettingsController

- (void)loadView {
    self.view = self.settingsView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ready];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - Private

- (void)ready {
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = btn;
    [self.settingsView.tableView reloadData];
}

- (void)dismiss {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showVC:(UIViewController *)vc {
    [self.navigationController pushViewController:vc animated:YES];
}

/// 免打扰VC
/// @param category 类别
- (void)showBlockVC:(RCDUGSettingsBlockType)category {
    switch (category) {
        case RCDUGSettingsBlockTypeUltraGroup: {
            RCDDebugUltraGroupListController *vc = [[RCDDebugUltraGroupListController alloc] init];
            [self showVC:vc];
        }
            
            break;
        case RCDUGSettingsBlockTypeGroup: {
            RCDDebugComChatListController *vc = [[RCDDebugComChatListController alloc] init];
            [self showVC:vc];
        }
            break;
        case CDUGSettingsBlockTypeLocalMessages: {
            RCDLocalMessagesViewController *vc = [[RCDLocalMessagesViewController alloc] init];
            [self showVC:vc];
        }
            break;
            
        default:
            break;
    }
}


/// 其他
/// @param category 类别
- (void)showOtherVC:(RCDUGSettingsOtherType)category {
    switch (category) {
        case RCDUGSettingsOtherTypeDot: {
            RCDDotterViewController *vc = [RCDDotterViewController new];
            [self showVC:vc];
        }
            break;
        case RCDUGSettingsOtherTypeSticker:
            [RCDStickerTest test];
            break;
        case RCDUGSettingsOtherTypeUserInfo:
            [self testCurrentUserInfo];
            break;
        default:
            break;
    }
}

/// 未读数VC
/// @param category 类别
- (void)showUnreadVC:(RCDUnreadCoutType)category {
    switch (category) {
        case RCDUnreadCoutTypeConversation: {
            RCDUnreadCountViewController *vc = [RCDUnreadCountViewController new];
            [self showVC:vc];
        }
            break;
        case RCDUnreadCoutTypeConversationMentioned:{
            RCDUnreadCountViewController *vc = [RCDUnreadCountViewController new];
            vc.mentioned = YES;
            [self showVC:vc];
        }
            break;
        case RCGUnreadCoutTypeUltraGroup:{
            RCDUnreadCountViewController *vc = [RCDUnreadCountViewController new];
            vc.ultraGroup = YES;
            [self showVC:vc];
        }
            break;
        case RCGUnreadCoutTypeUltraGroupMentioned:{
            RCDUnreadCountViewController *vc = [RCDUnreadCountViewController new];
            vc.ultraGroup = YES;
            vc.mentioned = YES;
            [self showVC:vc];
        }
            break;
        case RCGUnreadCoutTypeDegistList: {
            RCDUGMentionedViewController *vc = [RCDUGMentionedViewController new];
            [self showVC:vc];
        }
            break;
        default:
            break;
    }
}

- (void)testCurrentUserInfo {
    NSString *userId = [RCCoreClient sharedCoreClient].currentUserInfo.userId;
    for (int i = 0 ;i<20000; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            RCUserInfo *userInfo = [RCUserInfo new];
            userInfo.userId =  userId;
            userInfo.name = @"223";
            [[RCCoreClient sharedCoreClient] setCurrentUserInfo:userInfo];
//            NSLog(@"[VO] userID : %@", userId);
        });
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            RCUserInfo *userInfo = [RCCoreClient sharedCoreClient].currentUserInfo;
            NSString *userId = userInfo.userId;
//            NSLog(@"[VO] userID : %@", userId);
        });
    }
}
#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.dataSource[indexPath.section];
    NSDictionary *rows = dic[RCDUGSettingsRows];
    NSArray *array = dic[RCDUGSettingsCategory];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RCDUGSettingsControllerCellIdentifier forIndexPath:indexPath];
    NSNumber *category = array[indexPath.row];
    cell.textLabel.text = rows[category];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = self.dataSource[indexPath.section];
    NSArray *array = dic[RCDUGSettingsCategory];
    
    switch (indexPath.section) {
        case 0:
            [self showBlockVC:[array[indexPath.row] integerValue]];
            break;
        case 1:
            [self showUnreadVC:[array[indexPath.row] integerValue]];
            break;
        case 2:
            [self showOtherVC:[array[indexPath.row] integerValue]];
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *dic = self.dataSource[section];
    return dic[RCDUGSettingsTitle];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dic = self.dataSource[section];
    NSArray *array = dic[RCDUGSettingsCategory];
    return [array count];
}

#pragma mark - Property

- (RCDUGListView *)settingsView {
    if (!_settingsView) {
        _settingsView = [RCDUGListView new];
        _settingsView.tableView.delegate = self;
        _settingsView.tableView.dataSource = self;
        [_settingsView.tableView registerClass:[UITableViewCell class]
                        forCellReuseIdentifier:RCDUGSettingsControllerCellIdentifier];
    }
    return _settingsView;
}

- (NSArray *)dataSource {
    if (!_dataSource) {
        _dataSource = @[@{RCDUGSettingsTitle : @"免打扰设置",
                          RCDUGSettingsRows : self.dicNoDistribute,
                          RCDUGSettingsCategory: self.arrayNoDistribute
                        },
                        @{RCDUGSettingsTitle : @"未读数",
                          RCDUGSettingsRows : self.dicUnreadCount,
                          RCDUGSettingsCategory: self.arrayUnreadCount
                        },
                        @{RCDUGSettingsTitle : @"其他",
                          RCDUGSettingsRows : self.dicOther,
                          RCDUGSettingsCategory: self.arrayOther
                        }
        ];
    }
    return _dataSource;
}

- (NSArray *)arrayNoDistribute {
    if (!_arrayNoDistribute) {
        _arrayNoDistribute = @[
            @(RCDUGSettingsBlockTypeUltraGroup),
            @(RCDUGSettingsBlockTypeGroup),
            @(CDUGSettingsBlockTypeLocalMessages)
        ];
    }
    return _arrayNoDistribute;
}


- (NSDictionary *)dicNoDistribute {
    if (!_dicNoDistribute) {
        _dicNoDistribute = @{
            @(RCDUGSettingsBlockTypeUltraGroup) : @"超级群",
            @(RCDUGSettingsBlockTypeGroup) : @"普通群",
            @(CDUGSettingsBlockTypeLocalMessages) :@"本地消息"
        };
    }
    return _dicNoDistribute;
}

- (NSArray *)arrayUnreadCount {
    if (!_arrayUnreadCount) {
        _arrayUnreadCount = @[
            @(RCDUnreadCoutTypeConversation),
            @(RCDUnreadCoutTypeConversationMentioned),
            @(RCGUnreadCoutTypeUltraGroup),
            @(RCGUnreadCoutTypeUltraGroupMentioned),
            @(RCGUnreadCoutTypeDegistList)
        ];
    }
    return _arrayUnreadCount;
}

- (NSArray *)arrayOther {
    if (!_arrayOther) {
        _arrayOther = @[
            @(RCDUGSettingsOtherTypeDot),
            @(RCDUGSettingsOtherTypeSticker),
            @(RCDUGSettingsOtherTypeUserInfo)
        ];
    }
    return _arrayOther;
}
- (NSDictionary *)dicUnreadCount {
    if (!_dicUnreadCount) {
        _dicUnreadCount = @{
            @(RCDUnreadCoutTypeConversation) : @"获取会话未读消息数",
            @(RCDUnreadCoutTypeConversationMentioned) : @"获取会话未读 @消息数",
            @(RCGUnreadCoutTypeUltraGroup) : @"获取指定超级群会话的未读消息数（包括所有频道)",
            @(RCGUnreadCoutTypeUltraGroupMentioned) : @"获取指定超级群会话的未读@消息数（包括所有频道）",
            @(RCGUnreadCoutTypeDegistList) : @"超级群获取未读 @消息列表(摘要列表)"
        };
    }
    return _dicUnreadCount;
}

- (NSDictionary *)dicOther {
    
    if (!_dicOther) {
        _dicOther = @{
            @(RCDUGSettingsOtherTypeDot) : @"打点测试",
            @(RCDUGSettingsOtherTypeSticker) : @"Sticker测试",
            @(RCDUGSettingsOtherTypeUserInfo) : @"UserInfo测试"

        };
    }
    return _dicOther;
}
@end
