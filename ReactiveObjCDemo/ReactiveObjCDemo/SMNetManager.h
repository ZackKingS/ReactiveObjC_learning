//
//  SMNetManager.h
//  ReactiveObjCDemo
//
//  Created by zack on 2021/1/19.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

NS_ASSUME_NONNULL_BEGIN

@interface SMNetManager : NSObject
+ (SMNetManager *)shareInstance;
 
- (RACSignal *)fetchAllFeedWithModelArray:(NSArray *)modelArray;
@end

NS_ASSUME_NONNULL_END
