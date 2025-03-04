//
//  RCDGroupQRCodeController.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/17.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDQRCodeController.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "DefaultPortraitView.h"
#import "RCDQRCodeManager.h"
#import "RCDUIBarButtonItem.h"
#import "RCDGroupManager.h"
#import "RCDUserInfoManager.h"
#import "UIView+MBProgressHUD.h"
#import "RCDForwardSelectedViewController.h"
#import "RCDForwardManager.h"
#import "NormalAlertView.h"
@interface RCDQRCodeController ()
@property (nonatomic, strong) UIView *qrBgView;
@property (nonatomic, strong) UIImageView *portraitImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIImageView *qrCodeImageView;
@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic, strong) UIView *shareBgView;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *shareSealTalkBtn;

@property (nonatomic, strong) NSString *targetId;
@property (nonatomic, assign) RCConversationType type;
@property (nonatomic, strong) RCDGroupInfo *group;
@end

@implementation RCDQRCodeController
#pragma mark - life cycle
- (instancetype)initWithTargetId:(NSString *)targetId conversationType:(RCConversationType)type {
    if (self = [super init]) {
        self.targetId = targetId;
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.group = [RCDGroupManager getGroupInfo:self.targetId];
    [self setDataInfo];
    [self setNaviItem];
    [self addSubViews];
}

#pragma mark - helper
- (void)setDataInfo {
    NSString *portraitUri, *name, *countInfo, *info, *qrInfo;
    if (self.type == ConversationType_GROUP) {
        portraitUri = self.group.portraitUri;
        name = self.group.groupName;
        if (!self.group.needCertification) {
            countInfo = [NSString stringWithFormat:@"%@ %@", self.group.number, RCDLocalizedString(@"Person")];
            info = RCDLocalizedString(@"GroupScanQRCodeInfo");
            qrInfo = [NSString stringWithFormat:@"%@?key=sealtalk://group/join?g=%@&u=%@", RCDQRCodeContentInfoUrl,
                                                self.targetId, [RCCoreClient sharedCoreClient].currentUserInfo.userId];
            self.countLabel.text = countInfo;
            self.qrCodeImageView.image = [RCDQRCodeManager getQRCodeImage:qrInfo];
        }
    } else {
        RCUserInfo *user = [RCDUserInfoManager getUserInfo:self.targetId];
        portraitUri = user.portraitUri;
        name = [RCKitUtility getDisplayName:user];
        info = RCDLocalizedString(@"MyScanQRCodeInfo");
        qrInfo = [NSString stringWithFormat:@"%@?key=sealtalk://user/info?u=%@", RCDQRCodeContentInfoUrl,
                                            [RCCoreClient sharedCoreClient].currentUserInfo.userId];
        self.qrCodeImageView.image = [RCDQRCodeManager getQRCodeImage:qrInfo];
    }
    if (![portraitUri isEqualToString:@""]) {
        [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:portraitUri]
                                  placeholderImage:[UIImage imageNamed:@"contact"]];
    }
    if (!self.portraitImageView.image) {
        self.portraitImageView.image = [DefaultPortraitView portraitView:self.targetId name:name];
    }
    self.nameLabel.text = name;
    self.infoLabel.text = info;
}

- (void)setNaviItem {
    if (self.type == ConversationType_GROUP) {
        self.navigationItem.title = RCDLocalizedString(@"GroupQR");
    } else {
        self.navigationItem.title = RCDLocalizedString(@"My_QR");
    }

    self.navigationItem.leftBarButtonItems = [RCDUIBarButtonItem getLeftBarButton:RCDLocalizedString(@"back") target:self action:@selector(clickBackBtn)];
}

- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didClickSaveAction {
    [self saveImageToPhotos:[self captureCurrentView:self.qrBgView]];
}

- (void)didShareSealTalkAction {
    UIImage *image = [self captureCurrentView:self.qrBgView];
    RCImageMessage *msg = [RCImageMessage messageWithImage:image];
    msg.full = YES;
    RCMessage *message = [[RCMessage alloc] initWithType:self.type
                                                targetId:self.targetId
                                               direction:(MessageDirection_SEND)
                                               messageId:-1
                                                 content:msg];
    [[RCDForwardManager sharedInstance]
        setWillForwardMessageBlock:^(RCConversationType type, NSString *_Nonnull targetId) {
            [[RCIM sharedRCIM] sendMediaMessage:type
                targetId:targetId
                content:msg
                pushContent:nil
                pushData:nil
                progress:^(int progress, long messageId) {

                }
                success:^(long messageId) {

                }
                error:^(RCErrorCode errorCode, long messageId) {

                }
                cancel:^(long messageId){

                }];
        }];
    [RCDForwardManager sharedInstance].isForward = YES;
    [RCDForwardManager sharedInstance].isMultiSelect = NO;
    [RCDForwardManager sharedInstance].selectedMessages = @[ [RCMessageModel modelWithMessage:message] ];
    RCDForwardSelectedViewController *forwardSelectedVC = [[RCDForwardSelectedViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:forwardSelectedVC];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:navi animated:YES completion:nil];
}

- (UIImage *)captureCurrentView:(UIView *)view {
    CGRect frame = view.frame;
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, [UIScreen mainScreen].scale);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:contextRef];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)saveImageToPhotos:(UIImage *)image {
    [RCDUtilities savePhotosAlbumWithImage:image authorizationStatusBlock:^{
        [RCAlertView showAlertController:RCLocalizedString(@"AccessRightTitle")
                                 message:RCLocalizedString(@"photoAccessRight")
                             cancelTitle:RCLocalizedString(@"OK")
                        inViewController:self];
    } resultBlock:^(BOOL success) {
        [self showHUDWithSuccess:success];
    }];
}

- (void)showHUDWithSuccess:(BOOL)success {
    if (success) {
        [self.view showHUDMessage:RCLocalizedString(@"SavePhotoSuccess")];
    } else {
        [self.view showHUDMessage:RCLocalizedString(@"SavePhotoFailed")];
    }
}

- (void)addSubViews {
    [self.view addSubview:self.qrBgView];
    [self.view addSubview:self.shareBgView];
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = RCDDYCOLOR(0xd8d8d8, 0x373737);
    [self.view addSubview:lineView];
    [self.qrBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.offset(320);
        make.height.offset(440);
        make.top.equalTo(self.view).offset(58.5);
    }];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.qrBgView);
        make.height.offset(0.5);
        make.bottom.equalTo(self.qrBgView.mas_bottom).offset(-46);
    }];
    [self.shareBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.qrBgView);
        make.height.offset(46);
        make.top.equalTo(lineView.mas_bottom);
    }];

    if (self.type == ConversationType_GROUP && self.group.needCertification) {
        UILabel *label = [[UILabel alloc] init];
        label.text = RCDLocalizedString(@"GroupQrCodeCerTip");
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = RCDDYCOLOR(0x333333, 0xaaaaaa);
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.qrBgView);
            make.centerX.equalTo(self.qrBgView);
            make.width.equalTo(self.qrBgView);
        }];
    }

    [self addQrBgViewSubviews];
    [self addShareBgViewSubviews];
}

- (void)addShareBgViewSubviews {
    [self.shareBgView addSubview:self.saveButton];
    [self.shareBgView addSubview:self.shareSealTalkBtn];
    UIView *lineView1 = [[UIView alloc] init];
    lineView1.backgroundColor = RCDDYCOLOR(0xd8d8d8, 0x373737);
    [self.shareBgView addSubview:lineView1];
    UIView *lineView2 = [[UIView alloc] init];
    lineView2.backgroundColor = RCDDYCOLOR(0xd8d8d8, 0x373737);
    [self.shareBgView addSubview:lineView2];

    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self.shareBgView);
        make.width.offset(320 / 2);
    }];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.shareBgView);
        make.left.equalTo(self.saveButton.mas_right).offset(-0.5);
        make.width.offset(0.5);
    }];
    [self.shareSealTalkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.shareBgView);
        make.left.equalTo(self.saveButton.mas_right);
        make.right.equalTo(self.shareBgView);
    }];
}

- (void)addQrBgViewSubviews {
    [self.qrBgView addSubview:self.portraitImageView];
    [self.qrBgView addSubview:self.nameLabel];
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = RCDDYCOLOR(0xd8d8d8, 0x373737);
    [self.qrBgView addSubview:lineView];

    [self.portraitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.qrBgView).offset(16);
        make.width.height.offset(50);
    }];

    if (self.type == ConversationType_GROUP) {
        if (self.group.needCertification) {
            [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.portraitImageView.mas_right).offset(12);
                make.right.equalTo(self.qrBgView.mas_right).offset(-12);
                make.centerY.equalTo(self.portraitImageView);
                make.height.offset(24);
            }];

        } else {
            [self.qrBgView addSubview:self.qrCodeImageView];
            [self.qrBgView addSubview:self.countLabel];
            [self.qrBgView addSubview:self.infoLabel];
            [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.portraitImageView.mas_right).offset(12);
                make.right.equalTo(self.qrBgView.mas_right).offset(-12);
                make.top.equalTo(self.qrBgView).offset(17);
                make.height.offset(24);
            }];

            [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.portraitImageView.mas_right).offset(12);
                make.right.equalTo(self.qrBgView.mas_right).offset(-12);
                make.bottom.equalTo(self.portraitImageView.mas_bottom);
                make.height.offset(20);
            }];
        }
    } else {
        [self.qrBgView addSubview:self.qrCodeImageView];
        [self.qrBgView addSubview:self.infoLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.portraitImageView.mas_right).offset(12);
            make.right.equalTo(self.qrBgView.mas_right).offset(-12);
            make.centerY.equalTo(self.portraitImageView);
            make.height.offset(24);
        }];
    }

    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.qrBgView);
        make.top.equalTo(self.qrBgView).offset(90);
        make.width.offset(280);
        make.height.offset(0.5);
    }];
    if (!self.group.needCertification) {
        [self.qrCodeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.qrBgView);
            make.top.equalTo(self.qrBgView).offset(76);
            make.width.height.offset(280);
        }];
        [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.qrBgView);
            make.bottom.equalTo(self.qrBgView).offset(-72);
            make.height.offset(20);
            make.width.equalTo(self.qrBgView);
        }];
        [self setQrImageBorderView];
    }
}

- (void)setQrImageBorderView{
    UIView *topView = [self getQrImageBorderView];
    UIView *bottomView = [self getQrImageBorderView];
    UIView *leftView = [self getQrImageBorderView];
    UIView *rightView = [self getQrImageBorderView];
    [self.qrCodeImageView addSubview:topView];
    [self.qrCodeImageView addSubview:bottomView];
    [self.qrCodeImageView addSubview:leftView];
    [self.qrCodeImageView addSubview:rightView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.qrCodeImageView);
        make.height.offset(15);
    }];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.qrCodeImageView);
        make.height.offset(15);
    }];
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self.qrCodeImageView);
        make.width.offset(15);
    }];
    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self.qrCodeImageView);
        make.width.offset(15);
    }];
}

- (UIView *)getQrImageBorderView{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = RCDDYCOLOR(0xffffff, 0x2c2c2c);
    return view;
}

#pragma mark - getter
- (UIView *)qrBgView {
    if (!_qrBgView) {
        _qrBgView = [[UIView alloc] init];
        _qrBgView.backgroundColor = RCDDYCOLOR(0xffffff, 0x2c2c2c);
        _qrBgView.layer.masksToBounds = YES;
        _qrBgView.layer.cornerRadius = 8;
    }
    return _qrBgView;
}

- (UIImageView *)portraitImageView {
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] init];
        _portraitImageView.layer.masksToBounds = YES;
        if (RCKitConfigCenter.ui.globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
            RCKitConfigCenter.ui.globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
            _portraitImageView.layer.cornerRadius = 25;
        }else{
            _portraitImageView.layer.cornerRadius = 4;
        }
    }
    return _portraitImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0x111f2c) darkColor:[HEXCOLOR(0xffffff) colorWithAlphaComponent:0.9]];
        _nameLabel.font = [UIFont boldSystemFontOfSize:17];
    }
    return _nameLabel;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.textColor = RCDDYCOLOR(0xA0A5AB, 0xaaaaaa);
        _countLabel.font = [UIFont systemFontOfSize:14];
    }
    return _countLabel;
}

- (UIImageView *)qrCodeImageView {
    if (!_qrCodeImageView) {
        _qrCodeImageView = [[UIImageView alloc] init];
    }
    return _qrCodeImageView;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.textColor = HEXCOLOR(0x939393);
        _infoLabel.font = [UIFont systemFontOfSize:13];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _infoLabel;
}

- (UIView *)shareBgView {
    if (!_shareBgView) {
        _shareBgView = [[UIView alloc] init];
        _shareBgView.backgroundColor = RCDDYCOLOR(0xffffff, 0x2c2c2c);
        _shareBgView.layer.masksToBounds = YES;
        _shareBgView.layer.cornerRadius = 8;
    }
    return _shareBgView;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [[UIButton alloc] init];
        [_saveButton setTitleColor:HEXCOLOR(0x0099ff) forState:(UIControlStateNormal)];
        _saveButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_saveButton setTitle:RCDLocalizedString(@"SaveImage") forState:(UIControlStateNormal)];
        [_saveButton addTarget:self
                        action:@selector(didClickSaveAction)
              forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _saveButton;
}

- (UIButton *)shareSealTalkBtn {
    if (!_shareSealTalkBtn) {
        _shareSealTalkBtn = [[UIButton alloc] init];
        [_shareSealTalkBtn setTitleColor:HEXCOLOR(0x0099ff) forState:(UIControlStateNormal)];
        _shareSealTalkBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_shareSealTalkBtn setTitle:RCDLocalizedString(@"ShareToST") forState:(UIControlStateNormal)];
        [_shareSealTalkBtn addTarget:self
                              action:@selector(didShareSealTalkAction)
                    forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _shareSealTalkBtn;
}

@end
