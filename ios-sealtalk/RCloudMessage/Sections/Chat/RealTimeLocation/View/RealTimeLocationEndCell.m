//
//  RealTimeLocationEndCell.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/8/13.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RealTimeLocationEndCell.h"
#import "RealTimeLocationDefine.h"

@implementation RealTimeLocationEndCell
+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CGFloat __messagecontentview_height = 35.0f;
    __messagecontentview_height += extraHeight;

    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tipMessageLabel = [RCTipLabel greyTipLabel];
        self.tipMessageLabel.backgroundColor = [RCKitUtility generateDynamicColor:[UIColor colorWithWhite:0 alpha:0.1]
                                                                        darkColor:UIColorFromRGB(0x232323, 1.0)];
        self.tipMessageLabel.textColor =
            [RCKitUtility generateDynamicColor:UIColorFromRGB(0xffffff, 1.0) darkColor:UIColorFromRGB(0x707070, 1.0)];
        [self.baseContentView addSubview:self.tipMessageLabel];
        // self.tipMessageLabel.marginInsets = UIEdgeInsetsMake(0.5f, 0.5f, 0.5f,
        // 0.5f);
    }
    return self;
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];

    //    RCMessageContent *content = model.content;

    CGFloat maxMessageLabelWidth = self.baseContentView.bounds.size.width - 30 * 2;
    [self.tipMessageLabel setText:RTLLocalizedString(@"share_location_finished") dataDetectorEnabled:NO];

    NSString *__text = self.tipMessageLabel.text;
    CGSize __textSize = [RCKitUtility getTextDrawingSize:__text
                                                    font:[UIFont systemFontOfSize:14.0f]
                                         constrainedSize:CGSizeMake(maxMessageLabelWidth, MAXFLOAT)];
    __textSize = CGSizeMake(ceilf(__textSize.width), ceilf(__textSize.height));
    CGSize __labelSize = CGSizeMake(__textSize.width + 10, __textSize.height + 6);

    self.tipMessageLabel.frame = CGRectMake((self.baseContentView.bounds.size.width - __labelSize.width) / 2.0f, 10,
                                            __labelSize.width, __labelSize.height);
}

@end
