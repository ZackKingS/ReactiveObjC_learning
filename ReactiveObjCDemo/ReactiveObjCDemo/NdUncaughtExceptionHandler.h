//
//  NdUncaughtExceptionHandler.h
//  ReactiveObjCDemo
//
//  Created by zack on 2021/1/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NdUncaughtExceptionHandler : NSObject

+ (void)setDefaultHandler;
+ (NSUncaughtExceptionHandler*)getHandler;

@end

NS_ASSUME_NONNULL_END
