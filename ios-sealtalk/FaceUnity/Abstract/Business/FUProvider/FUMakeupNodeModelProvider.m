//
//  FUMakeUpProducer.m
//  BeautifyExample
//
//  Created by Chen on 2021/4/25.
//  Copyright © 2021 Agora. All rights reserved.
//

#import "FUMakeupNodeModelProvider.h"
#import "FUBaseModel.h"
#import "FUManager.h"


@implementation FUMakeupNodeModelProvider
@synthesize dataSource = _dataSource;
- (id)dataSource {
    if (!_dataSource) {
        _dataSource = [self producerDataSource];
    }
    return _dataSource;
}

- (NSArray *)producerDataSource {
    
    NSMutableArray *source = [NSMutableArray arrayWithCapacity:4];
    if ([FUManager shareManager].makeupParams && [FUManager shareManager].makeupParams.count > 0) {
        
        source = [FUManager shareManager].makeupParams;
        
    }else{
        
        NSArray *prams = @[@"makeup_noitem",@"chaoA",@"dousha",@"naicha",];
        NSDictionary *titelDic = @{@"chaoA" : @"超A", @"dousha": @"豆沙", @"naicha" : @"奶茶",  @"makeup_noitem":@"卸妆"};
        for (NSUInteger i = 0; i < prams.count; i ++) {
            NSString *str = [prams objectAtIndex:i];
            FUBaseModel *model = [[FUBaseModel alloc] init];
            model.imageName = str;
            model.mTitle = [titelDic valueForKey:str];
            model.indexPath = [NSIndexPath indexPathForRow:i inSection:FUDataTypeMakeup];
            model.mValue = @0.7;
            [source addObject:model];
        }
    }

    return [NSArray arrayWithArray:source];
}

- (void)cacheData{
    
    [FUManager shareManager].makeupParams = [NSMutableArray arrayWithArray:self.dataSource];
}

@end
