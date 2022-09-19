//
//  RCDAddFriendListViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/7/9.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDAddFriendListViewController.h"
#import "RCDAddFriendListCell.h"
#import <Masonry/Masonry.h>
#import "UIColor+RCColor.h"
#import "RCDQRCodeController.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDSearchBar.h"
#import "RCDSearchFriendController.h"
#import "RCDScanQRCodeController.h"
#import "RCDSelectAddressBookViewController.h"
#import "RCDAddressBookFriendsViewController.h"
#import "UIView+MBProgressHUD.h"
#import "RCDMyQRCodeView.h"
#import "RCDForwardSelectedViewController.h"
#import "RCDTableView.h"
#define RCDAddFriendListCellIdentifier @"RCDAddFriendListCell"

@interface RCDAddFriendListViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, RCDMyQRCodeViewDelegate>

@property (nonatomic, strong) RCDSearchBar *searchBar;

@property (nonatomic, strong) UIView *myQRCodeView;
@property (nonatomic, strong) UILabel *myQRCodeLabel;
@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) RCDTableView *tableView;

@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *detailArray;

@property (nonatomic, strong) RCDMyQRCodeView *QRCodeView;

@end

@implementation RCDAddFriendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavi];
    [self setupUI];
    [self setupData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.imageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDAddFriendListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:RCDAddFriendListCellIdentifier];
    if (cell == nil) {
        cell = [[RCDAddFriendListCell alloc] init];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.headerImgView.image = [UIImage imageNamed:self.imageArray[indexPath.row]];
    cell.titleLabel.text = RCDLocalizedString(self.titleArray[indexPath.row]);
    cell.detailLabel.text = RCDLocalizedString(self.detailArray[indexPath.row]);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 49.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
    case 0: {
        RCDAddressBookFriendsViewController *vc = [[RCDAddressBookFriendsViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } break;
    case 1: {
        RCDScanQRCodeController *qrcodeVC = [[RCDScanQRCodeController alloc] init];
        [self.navigationController pushViewController:qrcodeVC animated:YES];
    } break;
    case 2: {
        RCDSelectAddressBookViewController *vc = [[RCDSelectAddressBookViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } break;
    default:
        break;
    }
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    RCDSearchFriendController *searchFirendVC = [[RCDSearchFriendController alloc] init];
    [self.navigationController pushViewController:searchFirendVC animated:YES];
    return NO;
}

#pragma mark - RCDMyQRCodeViewDelegate
- (void)myQRCodeViewShareSealTalk {
    RCDForwardSelectedViewController *forwardSelectedVC = [[RCDForwardSelectedViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:forwardSelectedVC];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:navi animated:YES completion:nil];
}

#pragma mark - Private Method
- (void)setupNavi {
    self.navigationItem.title = RCDLocalizedString(@"add_contacts");
}

- (void)setupUI {
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.myQRCodeView];
    [self.view addSubview:self.tableView];

    [self.myQRCodeView addSubview:self.myQRCodeLabel];
    [self.myQRCodeView addSubview:self.imgView];

    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.offset(44);
    }];

    [self.myQRCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(44);
        make.left.right.equalTo(self.view);
        make.height.offset(44);
    }];

    [self.myQRCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.myQRCodeView);
        make.height.offset(20);
    }];

    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.myQRCodeLabel.mas_right).offset(5);
        make.centerY.equalTo(self.myQRCodeLabel);
        make.height.width.offset(12);
    }];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(88);
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)setupData {
    self.imageArray = @[ @"add_phonebook", @"add_scan", @"add_invite_phonebook" ];
    self.titleArray = @[ @"Phonebook_Title", @"Scan_Title", @"Invite_Phonebook_Title" ];
    self.detailArray = @[ @"Phonebook_Detail", @"Scan_Detail", @"Invite_Phonebook_Detail" ];
}

#pragma mark - Target Action
- (void)tapMyQRCode {

    [self.QRCodeView show];

    [UIView animateWithDuration:0.2
                     animations:^{
                         self.QRCodeView.hidden = NO;
                     }];
}

#pragma mark - Setter && Getter
- (RCDSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[RCDSearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.placeholder = RCDLocalizedString(@"PhoneOrSTNumber");
    }
    return _searchBar;
}

- (UIView *)myQRCodeView {
    if (!_myQRCodeView) {
        _myQRCodeView = [[UIView alloc] init];
        _myQRCodeView.userInteractionEnabled = YES;

        UITapGestureRecognizer *tap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMyQRCode)];
        [_myQRCodeView addGestureRecognizer:tap];
    }
    return _myQRCodeView;
}

- (UILabel *)myQRCodeLabel {
    if (!_myQRCodeLabel) {
        _myQRCodeLabel = [[UILabel alloc] init];
        _myQRCodeLabel.font = [UIFont systemFontOfSize:14];
        _myQRCodeLabel.textColor = RCDDYCOLOR(0x333333, 0x9f9f9f);
        _myQRCodeLabel.text = RCDLocalizedString(@"My_QR");
    }
    return _myQRCodeLabel;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.image = [UIImage imageNamed:@"add_qr_code"];
    }
    return _imgView;
}

- (RCDTableView *)tableView {
    if (!_tableView) {
        _tableView = [[RCDTableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        [_tableView setSectionIndexColor:[UIColor darkGrayColor]];
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

- (RCDMyQRCodeView *)QRCodeView {
    if (!_QRCodeView) {
        _QRCodeView = [[RCDMyQRCodeView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.frame];
        _QRCodeView.hidden = YES;
        _QRCodeView.delegate = self;
    }
    return _QRCodeView;
}

@end
