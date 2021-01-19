//
//  SMNetManager.m
//  ReactiveObjCDemo
//
//  Created by zack on 2021/1/19.
//

#import "SMNetManager.h"

@implementation SMNetManager

+ (SMNetManager *)shareInstance {
    static SMNetManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SMNetManager new];
    });
    return instance;
}

- (RACSignal *)fetchAllFeedWithModelArray:(NSMutableArray *)modelArray {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //创建并行队列
        dispatch_queue_t fetchFeedQueue = dispatch_queue_create("com.starming.fetchfeed.fetchfeed", DISPATCH_QUEUE_CONCURRENT);
        dispatch_group_t group = dispatch_group_create();
        
        for (int i =0; i<5; i++) {
            //创建并行队列
           
            dispatch_group_enter(group);
             
            dispatch_async(fetchFeedQueue, ^{
                 
                NSLog(@"begin task %d",i);
                sleep(1);
                NSLog(@"end task %d",i);
                [subscriber sendNext:@(i)];
                dispatch_group_leave(group);
                 
            });//end dispatch async
             
        }
         
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            [subscriber sendCompleted];
        });
        
        return nil;
    }];
}

@end
