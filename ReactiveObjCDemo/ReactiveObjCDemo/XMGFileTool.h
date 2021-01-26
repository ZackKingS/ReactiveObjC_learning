//
//  XMGFileTool.h
//  ReactiveObjCDemo
//
//  Created by zack on 2021/1/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XMGFileTool : NSObject

+ (void)getFileSize:(NSString *)directoryPath completion:(void(^)(NSInteger size))completion;

@end

NS_ASSUME_NONNULL_END
