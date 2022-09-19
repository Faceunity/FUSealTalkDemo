//
//  RCDDebugUltraGroupChatViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2021/11/29.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RCDDebugUltraGroupChatViewController.h"
#import "RCDDebugChatSettingViewController.h"
#import "RCDUIBarButtonItem.h"
#import "NormalAlertView.h"
#import "RCDDebugUltraGroupDefine.h"
#import "UIView+MBProgressHUD.h"
#import "RCDUltraGroupManager.h"
#import "RCDUltraGroupNotificationMessage.h"
#import "RCDChooseUserController.h"
#import "RCDUGChannelSettingViewController.h"

@interface RCConversationViewController ()<RCDUGChannelTypeDelegate>
- (void)reloadRecalledMessage:(long)recalledMsgId;
- (void)didReceiveMessageNotification:(NSNotification *)notification;
@end

@interface RCDDebugUltraGroupChatViewController () <RCUltraGroupReadTimeDelegate, RCMessageBlockDelegate,RCUltraGroupTypingStatusDelegate, RCUltraGroupMessageChangeDelegate>
@property (nonatomic, strong) RCMessageModel *menuSelectModel;
@end

@implementation RCDDebugUltraGroupChatViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRCDDebugChatSettingNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addToolbarItems];
    [[RCChannelClient sharedChannelManager] setRCUltraGroupReadTimeDelegate:self];
    [[RCChannelClient sharedChannelManager] setRCUltraGroupTypingStatusDelegate:self];
    [[RCChannelClient sharedChannelManager] setRCUltraGroupMessageChangeDelegate:self];
    [RCCoreClient sharedCoreClient].messageBlockDelegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDDebugChatSettingViewControllerEvent:) name:kRCDDebugChatSettingNotification object:nil];
    
    [self setNavi];
    [self addOtherPluginBoard];
    
    [self syncReadStatus];
    
    [[RCChannelClient sharedChannelManager] clearMessagesUnreadStatus:ConversationType_ULTRAGROUP targetId:self.targetId channelId:self.channelId];
}

- (void)didReceiveMessageNotification:(NSNotification *)notification{
    [super didReceiveMessageNotification:notification];
    RCMessage *message = notification.object;
    if (message.conversationType == self.conversationType && [message.targetId isEqual:self.targetId] && [message.content isKindOfClass:[RCDUltraGroupNotificationMessage class]]) {
        RCDUltraGroupNotificationMessage *noti = (RCDUltraGroupNotificationMessage *)message.content;
        if ([noti.operation isEqualToString:RCDUltraGroupDismiss]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view showHUDMessage:@"此超级群已解散"];
                [NSThread sleepForTimeInterval:2];
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    }
}

- (void)addOtherPluginBoard {
    if (self.conversationType != ConversationType_APPSERVICE &&
        self.conversationType != ConversationType_PUBLICSERVICE) {
        //加号区域增加发送文件功能，Kit中已经默认实现了该功能，但是为了SDK向后兼容性，目前SDK默认不开启该入口，可以参考以下代码在加号区域中增加发送文件功能。
        RCPluginBoardView *pluginBoardView = self.chatSessionInputBarControl.pluginBoardView;
        [pluginBoardView insertItem:RCResourceImage(@"plugin_item_file")
                   highlightedImage:RCResourceImage(@"plugin_item_file_highlighted")
                              title:RCLocalizedString(@"File")
                            atIndex:3
                                tag:PLUGIN_BOARD_ITEM_FILE_TAG];
        [pluginBoardView insertItem:RCResourceImage(@"plugin_item_file")
                   highlightedImage:RCResourceImage(@"plugin_item_file_highlighted")
                              title:@"@All"
                                tag:100001];
        
        [pluginBoardView insertItem:RCResourceImage(@"plugin_item_file")
                   highlightedImage:RCResourceImage(@"plugin_item_file_highlighted")
                              title:@"图文消息"
                                tag:100002];
        [pluginBoardView insertItem:RCResourceImage(@"plugin_item_file")
                   highlightedImage:RCResourceImage(@"plugin_item_file_highlighted")
                              title:@"插入消息"
                                tag:100003];
    }
}

- (void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag {
    if (tag == 100001) {
        // @All 消息
        RCTextMessage *message = [RCTextMessage messageWithContent:@"这是测试@所有人的消息"];
        RCMentionedInfo *mentionedInfo = [[RCMentionedInfo alloc] initWithMentionedType:RC_Mentioned_All userIdList:@[] mentionedContent:nil];
        message.mentionedInfo = mentionedInfo;
        [self sendMessage:message pushContent:nil];
    } else if (tag == 100002) {
        // 图文消息
        RCRichContentMessage *message = [RCRichContentMessage messageWithTitle:@"图文消息标题" digest:@"图文消息内容详情" imageURL:@"www.rongcloud.cn" url:@"www.rongcloud.cn" extra:@""];
        [self sendMessage:message pushContent:nil];
    } else if (tag == 100003) {
        RCTextMessage *textMessage = [RCTextMessage messageWithContent:@"这是一条插入的消息"];
        RCMessage *message = [[RCChannelClient sharedChannelManager] insertOutgoingMessage:self.conversationType
                                                                                  targetId:self.targetId
                                                                                 channelId:self.channelId
                                                                                sentStatus:SentStatus_READ
                                                                                   content:textMessage
                                                                                  sentTime:0];
        [self appendAndDisplayMessage:message];
    } else {
        [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
    }
}

- (void)setNavi {
    if (self.isDebugEnter) {
        RCDUIBarButtonItem *rightBtn = [[RCDUIBarButtonItem alloc] initContainImage:[UIImage imageNamed:@"Setting"] target:self action:@selector(rightBarButtonItemClicked:)];
        self.navigationItem.rightBarButtonItem = rightBtn;
        self.title = [NSString stringWithFormat:@"%@【%@】",self.targetId,self.channelId];
    }else{
        [RCDUltraGroupManager getChannelName:self.targetId channelId:self.channelId complete:^(NSString *channelName) {
            self.title = [NSString stringWithFormat:@"%@",channelName];
        }];
        [self configureSetting];
    }
}

- (void)configureSetting {
    RCDUIBarButtonItem *rightBtn = [[RCDUIBarButtonItem alloc] initContainImage:[UIImage imageNamed:@"Setting"] target:self action:@selector(rightSettingBarButtonItemClicked:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

- (void)rightSettingBarButtonItemClicked:(id)sender {
    RCDUGChannelSettingViewModel *viewModel = [[RCDUGChannelSettingViewModel alloc]
                                               initWithGroupID:self.ultraGroup.groupId
                                               channelID:self.channelId
                                               isPrivate:self.isPrivate
                                               ownnerID:self.ultraGroup.creatorId];
    viewModel.typeDelegate = self;
    RCDUGChannelSettingViewController *settingVC = [[RCDUGChannelSettingViewController alloc] initWithViewModel:viewModel];;
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)rightBarButtonItemClicked:(id)sender {
    long long recordTime = 0;
    if (self.conversationDataRepository.count > 0) {
        RCMessageModel *model = self.conversationDataRepository.lastObject;
        recordTime = model.sentTime;
    }
    RCDDebugChatSettingViewController *settingVC = [[RCDDebugChatSettingViewController alloc] init];
    settingVC.targetId = self.targetId;
    settingVC.channelId = self.channelId;
    settingVC.type = self.conversationType;
    settingVC.recordTime = recordTime;
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)syncReadStatus {
    NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970]*1000;

    [[RCChannelClient sharedChannelManager] syncUltraGroupReadStatus:self.targetId channelId:self.channelId time:currentTimestamp success:^{
        [self showToastMsg:@"同步阅读时间成功"];
    } error:^(RCErrorCode errorCode) {
        [self showAlertTitle:nil message:[NSString stringWithFormat:@"同步阅读时间失败：%@", @(errorCode)]];
    }];
}

- (NSString *)getTimeString {
    NSDateFormatter *dateFormart = [[NSDateFormatter alloc]init];
    [dateFormart setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    dateFormart.timeZone = [NSTimeZone systemTimeZone];
    NSString *dateString = [dateFormart stringFromDate:[NSDate date]];
    return dateString;
}

#pragma mark - RCDUGChannelTypeDelegate

- (void)channelTypeDidChangedTo:(BOOL)isPrivate {
    self.isPrivate = isPrivate;
}

#pragma mark - RCUltraGroupReadTimeDelegate
- (void)onUltraGroupReadTimeReceived:(NSString *)targetId channelId:(NSString *)channelId readTime:(long long)readTime {
    [self showAlertTitle:nil message:[NSString stringWithFormat:@"超级群已读时间同步, targetId%@ channelId%@ readTime:%lld", targetId, channelId, readTime]];
}

#pragma mark - RCMessageBlockDelegate
- (void)messageDidBlock:(RCBlockedMessageInfo *)blockedMessageInfo {
    NSString *blockTypeName = [RCDUtilities getBlockTypeName:blockedMessageInfo.blockType];
    NSString *ctypeName = [RCDUtilities getConversationTypeName:blockedMessageInfo.type];
    NSString *sentTimeFormat = [RCDUtilities getDateString:blockedMessageInfo.sentTime];
    NSString *msg = [NSString stringWithFormat:@"会话类型: %@,\n会话ID: %@,\n消息ID:%@,\n消息时间戳:%@,\n频道ID: %@,\n附加信息: %@,\n拦截原因:%@(%@)", ctypeName, blockedMessageInfo.targetId, blockedMessageInfo.blockedMsgUId,sentTimeFormat, blockedMessageInfo.channelId, blockedMessageInfo.extra, @(blockedMessageInfo.blockType), blockTypeName];

    [self showAlertTitle:nil message:msg];
}


#pragma mark - 单条消息推送属性设置
- (void)sendMessage:(RCMessageContent *)messageContent pushContent:(NSString *)pushContent {
    [[RCChannelClient sharedChannelManager] sendUltraGroupTypingStatus:self.targetId
                                                             channelId:self.channelId
                                                          typingStatus:RCUltraGroupTypingStatusText success:^() {
        [self showToastMsg:@"发送正在输入的状态成功"];
    } error:^(RCErrorCode status) {
        [self showToastMsg:[NSString stringWithFormat:@"发送正在输入的状态失败：%@",@(status)]];
    }];
    
    RCMessagePushConfig *pushConfig = [self getPushConfig];
    RCMessageConfig *config = [self getConfig];
    if (self.targetId == nil) {
        return;
    }
    messageContent = [self willSendMessage:messageContent];
    if (messageContent == nil) {
        return;
    }
    RCMessage *message = [[RCMessage alloc] initWithType:self.conversationType targetId:self.targetId direction:MessageDirection_SEND messageId:-1 content:messageContent];
    message.messagePushConfig = pushConfig;
    message.messageConfig = config;
    message.channelId = self.channelId;
    
    if ([messageContent isKindOfClass:[RCMediaMessageContent class]]) {
        [[RCIM sharedRCIM] sendMediaMessage:message pushContent:pushContent pushData:nil progress:nil successBlock:nil errorBlock:^(RCErrorCode nErrorCode, RCMessage *errorMessage) {
            NSString *log = [NSString stringWithFormat:@"发送失败: %ld, sentStatus(失败为20): %lu", nErrorCode, (unsigned long)errorMessage.sentStatus];
            [self showToastMsg:log];
        } cancel:nil];
    } else {
        [[RCIM sharedRCIM] sendMessage:message pushContent:pushContent pushData:nil successBlock:^(RCMessage *successMessage) {
            if (message.sentTime != successMessage.sentTime) {
                [self appendAndDisplayMessage:successMessage];
            }
        } errorBlock:^(RCErrorCode nErrorCode, RCMessage *errorMessage) {
            NSString *log = [NSString stringWithFormat:@"发送失败: %ld", nErrorCode];
            [self showToastMsg:log];
        }];
    }
}

- (void)didSendMessage:(NSInteger)status content:(RCMessageContent *)messageContent {

}

- (RCMessagePushConfig *)getPushConfig {
    RCMessagePushConfig *pushConfig = [[RCMessagePushConfig alloc] init];
    pushConfig.disablePushTitle = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-disablePushTitle"] boolValue];
    pushConfig.pushTitle = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-title"];
    pushConfig.pushContent = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-content"];
    pushConfig.pushData = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-data"];
    pushConfig.forceShowDetailContent = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-forceShowDetailContent"] boolValue];
    pushConfig.templateId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-templateId"];
    
    pushConfig.iOSConfig.threadId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-threadId"];
    pushConfig.iOSConfig.apnsCollapseId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-apnsCollapseId"];
    pushConfig.iOSConfig.richMediaUri = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-richMediaUri"];
    pushConfig.iOSConfig.category = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-category"];
    
    pushConfig.androidConfig.notificationId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-id"];
    pushConfig.androidConfig.channelIdMi = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-mi"];
    pushConfig.androidConfig.channelIdHW = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-hw"];
    pushConfig.androidConfig.channelIdOPPO = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-oppo"];
    pushConfig.androidConfig.typeVivo = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-vivo"];
    pushConfig.androidConfig.fcmCollapseKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-fcm"];
    pushConfig.androidConfig.fcmImageUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-fcmImageUrl"];
    pushConfig.androidConfig.importanceHW = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-importanceHW"];
    pushConfig.androidConfig.hwImageUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-hwImageUrl"];
    pushConfig.androidConfig.miLargeIconUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-miLargeIconUrl"];
    pushConfig.androidConfig.fcmChannelId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-fcmChannelId"];
    return pushConfig;
}

- (RCMessageConfig *)getConfig {
    RCMessageConfig *config = [[RCMessageConfig alloc] init];
    config.disableNotification = [[[NSUserDefaults standardUserDefaults] objectForKey:@"config-disableNotification"] boolValue];
    return config;
}

- (void)showAlertTitle:(NSString *)title message:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [RCAlertView showAlertController:title message:msg cancelTitle:RCDLocalizedString(@"confirm")];
    });
}

- (void)showToastMsg:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
//        if (self.isDebugEnter) {
            [self.view showHUDMessage:msg];
//        }
    });
}

#pragma mark- 长安按钮拓展
- (NSArray<UIMenuItem *> *)getLongTouchMessageCellMenuList:(RCMessageModel *)model {
    NSArray<UIMenuItem *> *menuList = [[super getLongTouchMessageCellMenuList:model] mutableCopy];
    
    NSMutableArray *list = [NSMutableArray new];//menuList.mutableCopy;
    UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:@"修改"
    action:@selector(modifyUltraGroupMessage)];
    [list addObject:item1];
    
    UIMenuItem *item2 = [[UIMenuItem alloc] initWithTitle:@"撤回"
    action:@selector(recallUltraGroupMessage)];
    [list addObject:item2];
    
    item2 = [[UIMenuItem alloc] initWithTitle:@"撤回并删除"
    action:@selector(recallUltraGroupMessageAndRemoveRemote)];
    [list addObject:item2];
    
    UIMenuItem *item3 = [[UIMenuItem alloc] initWithTitle:@"更新KV"
    action:@selector(updateUltraGroupMessageExpansion)];
    [list addObject:item3];
    
    UIMenuItem *item4 = [[UIMenuItem alloc] initWithTitle:@"删除KV"
    action:@selector(removeUltraGroupMessageExpansion)];
    [list addObject:item4];
    
    UIMenuItem *item5 = [[UIMenuItem alloc] initWithTitle:@"批量消息"
    action:@selector(getBatchRemoteUltraGroupMessages)];
    [list addObject:item5];
    
    UIMenuItem *item6 = [[UIMenuItem alloc] initWithTitle:@"查看修改状态"
    action:@selector(checkMessageChangedStatus)];
    [list addObject:item6];

    [list addObjectsFromArray:menuList];
    
    return list.copy;
}

- (void)didLongTouchMessageCell:(RCMessageModel *)model inView:(UIView *)view {
    [super didLongTouchMessageCell:model inView:view];
    self.menuSelectModel = model;
}

/**
 消息修改
 */
- (void)modifyUltraGroupMessage {
    
    NSString *currentUserId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    NSString *senderUserId = self.menuSelectModel.senderUserId;

    if ([currentUserId isEqualToString:senderUserId]) {
        RCTextMessage *textMessage = [RCTextMessage messageWithContent:@"这是一条修改的消息"];

        [[RCChannelClient sharedChannelManager] modifyUltraGroupMessage:self.menuSelectModel.messageUId messageContent:textMessage success:^{
            [self showToastMsg:@"消息修改成功"];
            [self updateEditingMessage];
        } error:^(RCErrorCode status) {
            [self showToastMsg:[NSString stringWithFormat:@"消息修改失败%zd",status]];
        }];
    } else {
        [self showAlertTitle:@"" message:@"请测试自己发的文本消息"];
    }
}

/*!
 撤回消息
 */
- (void)recallUltraGroupMessage {
    
    RCMessage *message = [[RCCoreClient sharedCoreClient] getMessageByUId:self.menuSelectModel.messageUId];
    message.channelId = self.channelId;
    message.targetId = self.targetId;
    message.conversationType = ConversationType_ULTRAGROUP;
    
    NSString *currentUserId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    NSString *senderUserId = self.menuSelectModel.senderUserId;
    
    if ([currentUserId isEqualToString:senderUserId]) {
        [[RCChannelClient sharedChannelManager] recallUltraGroupMessage:message success:^(long messageId) {
            [self showToastMsg:@"消息撤回成功"];
            [self updateEditingMessage];
        } error:^(RCErrorCode status) {
            [self showToastMsg:[NSString stringWithFormat:@"消息撤回失败%zd",status]];
        }];
    } else {
        [self showAlertTitle:nil message:@"请测试自己发的消息"];
    }
}

/*!
 撤回消息, 移除远端
 */
- (void)recallUltraGroupMessageAndRemoveRemote {
    
    RCMessage *message = [[RCCoreClient sharedCoreClient] getMessageByUId:self.menuSelectModel.messageUId];
    message.channelId = self.channelId;
    message.targetId = self.targetId;
    message.conversationType = ConversationType_ULTRAGROUP;
    
    NSString *currentUserId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    NSString *senderUserId = self.menuSelectModel.senderUserId;
    
    if ([currentUserId isEqualToString:senderUserId]) {
        [[RCChannelClient sharedChannelManager] recallUltraGroupMessage:message
                                                               isDelete:YES
                                                                success:^(long messageId) {
            [self showToastMsg:@"撤回消息, 移除远端成功"];
            [self removeRecalledMessage];
        } error:^(RCErrorCode status) {
            [self showToastMsg:[NSString stringWithFormat:@"撤回消息, 移除远端失败%zd",status]];
        }];
    } else {
        [self showAlertTitle:nil message:@"请测试自己发的消息"];
    }
}

/**
 更新消息扩展信息
*/
- (void)updateUltraGroupMessageExpansion {
    
    NSString *currentUserId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    NSString *senderUserId = self.menuSelectModel.senderUserId;
    
    RCMessage *message = [[RCCoreClient sharedCoreClient] getMessageByUId:self.menuSelectModel.messageUId];

    if ([currentUserId isEqualToString:senderUserId] && message.canIncludeExpansion && message.expansionDic) {
        NSArray *allKeys = message.expansionDic.allKeys;
        NSMutableDictionary *dic = [NSMutableDictionary new];
        for (NSString *key in allKeys) {
            dic[key] = @"已修改的拓展";
        }
        [[RCChannelClient sharedChannelManager] updateUltraGroupMessageExpansion:message.messageUId expansionDic:dic success:^{
            [self showToastMsg:[NSString stringWithFormat:@"msgUid:%@的KV已改为%@",message.messageUId,dic]];
        } error:^(RCErrorCode status) {
            [self showToastMsg:[NSString stringWithFormat:@"msgUid:%@的KV更新失败%zd",message.messageUId,status]];
        }];
    } else {
        [self showAlertTitle:nil message:@"请确定是否是自己发的可扩展消息"];
    }
}

/**
 删除消息扩展信息中特定的键值对
*/
- (void)removeUltraGroupMessageExpansion {
    
    NSString *currentUserId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    NSString *senderUserId = self.menuSelectModel.senderUserId;
    
    RCMessage *message = [[RCCoreClient sharedCoreClient] getMessageByUId:self.menuSelectModel.messageUId];

    if([currentUserId isEqualToString:senderUserId] && message.canIncludeExpansion && message.expansionDic) {
        NSArray *allKeys = message.expansionDic.allKeys;
        [[RCChannelClient sharedChannelManager] removeUltraGroupMessageExpansion:message.messageUId keyArray:allKeys success:^{
            [self showToastMsg:[NSString stringWithFormat:@"msgUId:%@删除KV成功",message.messageUId]];
        } error:^(RCErrorCode status) {
            [self showToastMsg:[NSString stringWithFormat:@"msgUId:%@删除KV失败%zd",message.messageUId,status]];
        }];
    } else {
        [self showAlertTitle:nil message:@"请确定是否是自己发的可扩展消息"];
    }
}

#pragma mark- RCUltraGroupTypingStatusDelegate
- (void)onUltraGroupTypingStatusChanged:(NSArray<RCUltraGroupTypingStatusInfo*>*)infoArr {
    
    NSString *userId = [RCIM sharedRCIM].currentUserInfo.userId;
    NSString *messagetr = @"";
    for (RCUltraGroupTypingStatusInfo *model in infoArr) {
        if (![userId isEqualToString:model.userId]) {
            if (messagetr.length == 0) {
                messagetr = [NSString stringWithFormat:@"%zd个用户正在输入：%@",infoArr.count, model.userId];
            } else {
                messagetr = [NSString stringWithFormat:@"%@,%@",messagetr, model.userId];
            }
        }
    }
    
    if (messagetr.length > 0) {
        [self showToastMsg:messagetr];
    }
}

#pragma mark- RCUltraGroupMessageChangeDelegate
/*!
 消息扩展更新，删除
 */
- (void)onUltraGroupMessageExpansionUpdated:(NSArray<RCMessage*>*)messages {
    NSMutableArray * updateUids = [NSMutableArray new];
    NSMutableArray * deleteUids = [NSMutableArray new];
    for (RCMessage* msg in messages) {
        if (msg.expansionDic && msg.expansionDic.allKeys > 0) {
            [updateUids addObject:msg.messageUId];
        } else {
            [deleteUids addObject:msg.messageUId];
        }
    }

    NSString *tipString = @"";
    NSString *tipString2 = @"";
    if (updateUids.count > 0) {
        tipString = [NSString stringWithFormat:@"更新KV的mUId:%@",[updateUids componentsJoinedByString:@","]];
    }
    
    if (deleteUids.count > 0) {
        tipString2 = [NSString stringWithFormat:@"删除KV的mUId:%@",[deleteUids componentsJoinedByString:@","]];
    }
    
    [self showAlertTitle:tipString message:tipString2];
}

/*!
 消息内容发生变更
 */
- (void)onUltraGroupMessageModified:(NSArray<RCMessage*>*)messages {
    NSMutableArray * userids = [NSMutableArray new];
    NSString *currentUserId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;

    for (RCMessage* msg in messages) {
        if (![msg.senderUserId isEqualToString:currentUserId]) {
            [userids addObject:msg.messageUId];
        }
    }
    
    NSString *msgUIdStr = [userids componentsJoinedByString:@","];
    
    [self showAlertTitle:@"msgUId消息更新" message:msgUIdStr];
    [self updateListenerMessages:messages];
}

/*!
 消息撤回
 */
- (void)onUltraGroupMessageRecalled:(NSArray<RCMessage*>*)messages {
//    NSMutableArray * messageUids = [NSMutableArray new];
    for (RCMessage* msg in messages) {
//        [messageUids addObject:msg.messageUId];
        [[NSNotificationCenter defaultCenter] postNotificationName:RCKitDispatchRecallMessageNotification
                                                            object:@(msg.messageId)
                                                          userInfo:nil];
    }
//    NSString *msgUIdStr = [messageUids componentsJoinedByString:@","];
//    [self showAlertTitle:@"消息撤回的MsgUId" message:msgUIdStr];
    
}

/*!
 获取同一个超级群下的批量服务消息（含所有频道）
 */
- (void)getBatchRemoteUltraGroupMessages {
    RCHistoryMessageOption *option = [[RCHistoryMessageOption alloc] init];
    option.recordTime = 0;
    option.count = 5;
    option.order = RCHistoryMessageOrderDesc;
    [[RCChannelClient sharedChannelManager] getMessages:ConversationType_ULTRAGROUP targetId:self.targetId channelId:self.channelId option:option complete:^(NSArray *messages, RCErrorCode code) {
        [[RCChannelClient sharedChannelManager] getBatchRemoteUltraGroupMessages:messages success:^(NSArray *matchedMsgList, NSArray *notMatchMsgList) {
            NSString *successMsgId = @"获取成功的MsgUId:";
            for (RCMessage *message in matchedMsgList) {
                successMsgId = [successMsgId stringByAppendingString:message.messageUId];
            }
            
            NSString *faildMsgID = @"获取失败的MsgUId:";
            for (RCMessage *message in notMatchMsgList) {
                faildMsgID = [faildMsgID stringByAppendingString:message.messageUId];
            }
            [self showAlertTitle:successMsgId message:faildMsgID];
            
        } error:^(RCErrorCode status) {
            [self showAlertTitle:nil message:[NSString stringWithFormat:@"获取批量服务消息失败%zd",status]];
        }];
    }];
}

- (void)checkMessageChangedStatus{
    RCMessage *message = [[RCIMClient sharedRCIMClient] getMessage:self.menuSelectModel.messageId];
    [self showToastMsg:message.hasChanged?@"消息已被修改":@"消息未被修改"];
}

#pragma mark- NSNotification

- (void)handleDDebugChatSettingViewControllerEvent:(NSNotification *)notification {
    NSNumber *type = notification.object;
    if (!type) {
        return;
    }
    
    switch ([type integerValue]) {
        case RCDDebugNotificationTypeDelete:
            [self reloadData];
            break;
        case RCDDebugNotificationTypeSendMsgKV:
            [self sendKVTextMessage];
            break;
        default:
            break;
    }
}

- (void)sendKVTextMessage {
    
    RCTextMessage *messageContent = [RCTextMessage messageWithContent:@"携带KV的文本消息"];
    RCMessage *message = [[RCMessage alloc] initWithType:ConversationType_ULTRAGROUP targetId:self.targetId direction:MessageDirection_SEND messageId:-1 content:messageContent];
    message.messagePushConfig = [self getPushConfig];
    message.messageConfig = [self getConfig];
    message.channelId = self.channelId;
    message.canIncludeExpansion = YES;
    message.expansionDic = @{kRCDebugKVMessageKey:[self getTimeString]};
    
    __weak typeof(self) weakSelf = self;
    [[RCIMClient sharedRCIMClient] sendMessage:message pushContent:nil pushData:nil successBlock:^(RCMessage *successMessage) {
        [weakSelf appendAndDisplayMessage:successMessage];
        [self showToastMsg:@"发送携带KV的文本消息成功"];
    } errorBlock:^(RCErrorCode nErrorCode, RCMessage *errorMessage) {
        [self showAlertTitle:nil message:[NSString stringWithFormat:@"send message failed:%ld",(long)nErrorCode]];
    }];
}

- (void)reloadData {
    [self.conversationDataRepository removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.conversationMessageCollectionView reloadData];
    });
}

- (void)updateEditingMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger row = [self.conversationDataRepository indexOfObject:self.menuSelectModel];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];

        RCMessage *message = [[RCCoreClient sharedCoreClient] getMessageByUId:self.menuSelectModel.messageUId];
        RCMessageModel *model = [RCMessageModel modelWithMessage:message];
        [self.conversationDataRepository replaceObjectAtIndex:row withObject:model];

        //更新UI
        [self.conversationMessageCollectionView reloadItemsAtIndexPaths:@[ indexPath ]];
    });
}

- (void)removeRecalledMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.conversationDataRepository removeObject:self.menuSelectModel];
        //更新UI
        [self.conversationMessageCollectionView reloadData];
    });
}

- (void)updateListenerMessages:(NSArray <RCMessage *>*)messages {
    if (!self.conversationDataRepository || self.conversationDataRepository.count == 0) {
        return;
    }
    NSMutableArray *indexPaths = [NSMutableArray new];
    for (int j = 0; j<self.conversationDataRepository.count; j++) {
        RCMessageModel *model = self.conversationDataRepository[j];
        for (int i = 0; i < messages.count; i++) {
            RCMessage * msg = messages[i];
            if (model.messageId == msg.messageId) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:0];
                [indexPaths addObject:indexPath];
                RCMessage *message = [[RCCoreClient sharedCoreClient] getMessage:model.messageId];
                RCMessageModel *model = [RCMessageModel modelWithMessage:message];
                [self.conversationDataRepository replaceObjectAtIndex:j withObject:model];
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.conversationMessageCollectionView reloadItemsAtIndexPaths:indexPaths];
    });
}

#pragma mark - super
- (void)showChooseUserViewController:(void (^)(RCUserInfo *selectedUserInfo))selectedBlock
                              cancel:(void (^)(void))cancelBlock {
    RCDChooseUserController *userListVC = [[RCDChooseUserController alloc] initWithGroupId:self.targetId isUltraGroup:YES];
    userListVC.selectedBlock = selectedBlock;
    userListVC.cancelBlock = cancelBlock;
    UINavigationController *rootVC = [[UINavigationController alloc] initWithRootViewController:userListVC];
    rootVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:rootVC animated:YES completion:nil];
}

#pragma mark - helper
- (void)addToolbarItems {
    //删除按钮
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [deleteBtn setImage:RCResourceImage(@"delete_message")
               forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteMessages) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *deleteBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteBtn];
    //按钮间 space
    UIBarButtonItem *spaceItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self.messageSelectionToolbar
        setItems:@[ spaceItem, deleteBarButtonItem, spaceItem ]
        animated:YES];
}

- (void)deleteMessages {
    NSArray *tempArray = [self.selectedMessages mutableCopy];
    for (int i = 0; i < tempArray.count; i++) {
        [self deleteMessage:tempArray[i]];
    }
    self.allowsMessageCellSelection = NO;
}

@end
