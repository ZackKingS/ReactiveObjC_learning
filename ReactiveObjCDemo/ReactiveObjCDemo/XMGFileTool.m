//
//  XMGFileTool.m
//  ReactiveObjCDemo
//
//  Created by zack on 2021/1/26.
//

#import "XMGFileTool.h"

@implementation XMGFileTool

+ (void)getFileSize:(NSString *)directoryPath completion:(void(^)(NSInteger size))completion{
    
    // 获取文件管理者
    NSFileManager *mgr = [NSFileManager defaultManager];
    BOOL isDirectory;
    BOOL isExist = [mgr fileExistsAtPath:directoryPath isDirectory:&isDirectory];
    if (!isExist || !isDirectory) {
       NSException *excp = [NSException exceptionWithName:@"pathError" reason:@"笨蛋 需要传入的是文件夹路径,并且路径要存在" userInfo:nil];
        [excp raise];
    }
    //切换到子线程
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 获取文件夹下所有的子路径
        NSArray *subPaths = [mgr subpathsAtPath:directoryPath];
        NSInteger totalSize = 0;
        //处理耗时操作
        for (NSString *subPath in subPaths) {
            NSString *fileFullPath = [directoryPath stringByAppendingPathComponent:subPath];
            //忽略.DS
            if ([fileFullPath containsString:@".DS"]) continue;
            BOOL isDirectory;
            BOOL isExist = [mgr fileExistsAtPath:fileFullPath isDirectory:&isDirectory];
            if (!isExist || isDirectory) continue;
            NSDictionary *attr = [mgr attributesOfItemAtPath:fileFullPath error:nil];
            // 获取文件尺寸
            NSInteger fileSize = [attr fileSize];
            totalSize += fileSize;
        }
        //切换主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(totalSize);
            }
        });
    });
}

@end
