//
//  RCDLocalMessagesView.m
//  SealTalk
//
//  Created by RobinCui on 2022/9/23.
//  Copyright © 2022 RongCloud. All rights reserved.
//

#import "RCDLocalMessagesView.h"
#import "RCDUGListView.h"
#import "RCDLocalMessagesQueryView.h"

#import <Masonry/Masonry.h>
@interface RCDLocalMessagesView()
@property (nonatomic, strong, readwrite) UIButton *btnQuery;
@property (nonatomic, strong, readwrite) UITextField *txtTargetID;
@property (nonatomic, strong, readwrite) UITextField *txtChannelID;
@property (nonatomic, strong, readwrite) UITextField *txtTime;
@property (nonatomic, strong, readwrite) UITextField *txtCount;
@property (nonatomic, strong, readwrite) UITableView *tableView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) RCDLocalMessagesQueryView *queryView;
@property (nonatomic, strong) RCDUGListView *listView;
@property (nonatomic, strong, readwrite) UITextField *txtMessageUID;

@end

@implementation RCDLocalMessagesView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.queryView = [RCDLocalMessagesQueryView new];
    self.listView = [RCDUGListView new];
    
    UIView *containerView = [UIView new];
    [self addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [containerView addSubview:self.listView];
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(containerView);
    }];
    
    [containerView addSubview:self.queryView];
    [self.queryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(containerView);
    }];
    
    self.btnQuery = self.queryView.btnQuery;
    self.txtTargetID = self.queryView.txtTargetID;
    self.txtChannelID = self.queryView.txtChannelID;
    self.txtTime = self.queryView.txtTime;
    self.txtCount = self.queryView.txtCount;
    self.tableView = self.listView.tableView;
    self.txtMessageUID = self.queryView.txtMessageUID;
}

- (void)showResult:(BOOL)show {
    UIViewAnimationOptions options = show ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.queryView hideKeyboardIfNeed];
        [UIView transitionWithView:self.queryView duration:0.5 options:options animations:^{
            self.queryView.alpha = show ? 0 : 1;
        } completion:^(BOOL finished) {
            
        }];
    });
}

- (void)showTips:(NSString *)tips {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *text = self.queryView.labTips.text;
        text = [NSString stringWithFormat:@"%@ \n -> %@", text, tips];
        self.queryView.labTips.text = text;
        [self.queryView.labTips sizeToFit];
    });
}

- (void)cleanTips {
    self.queryView.labTips.text = @"";
    [self.queryView.labTips sizeToFit];

}
- (void)hideKeyboardIfNeed {
    [self.queryView hideKeyboardIfNeed];
}
@end
