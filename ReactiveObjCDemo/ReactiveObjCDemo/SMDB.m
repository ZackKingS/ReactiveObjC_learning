//
//  SMDB.m
//  ReactiveObjCDemo
//
//  Created by zack on 2021/1/19.
//

#import "SMDB.h"


@implementation SMDB
#pragma mark - Life Cycle
+ (SMDB *)shareInstance {
    static SMDB *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SMDB alloc] init];
    });
    return instance;
}

//本地读取首页订阅源数据
- (RACSignal *)selectAllFeeds {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        NSMutableArray *feedsArray = [NSMutableArray array];
        [feedsArray addObject:@"1"];
        [feedsArray addObject:@"2"];
        [subscriber sendNext:feedsArray];
        [subscriber sendCompleted];
        return nil;
    }];
}
@end
