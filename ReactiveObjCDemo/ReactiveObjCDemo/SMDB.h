//
//  SMDB.h
//  ReactiveObjCDemo
//
//  Created by zack on 2021/1/19.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC.h>

NS_ASSUME_NONNULL_BEGIN

@interface SMDB : NSObject
+ (SMDB *)shareInstance;

  
- (RACSignal *)selectAllFeeds; //读取所有feeds
 
 
@end

NS_ASSUME_NONNULL_END
