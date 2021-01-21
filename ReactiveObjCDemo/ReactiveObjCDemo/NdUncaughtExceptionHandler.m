//
//  NdUncaughtExceptionHandler.m
//  ReactiveObjCDemo
//
//  Created by zack on 2021/1/20.
//

#import "NdUncaughtExceptionHandler.h"
#import "SMCallStack.h"
#import "SMCallStackModel.h"
#import "SMLagDB.h"
#import "SMCallStack.h"

NSString *applicationDocumentsDirectory() {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
 
void UncaughtExceptionHandler(NSException *exception) {

    NSArray *callStackSymbolsArr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];

    NSString *errorInfo = [NSString stringWithFormat:@"=============异常崩溃报告=============\nname:\n%@\nreason:\n%@\ncallStackSymbols:\n%@",
                           name,reason,[callStackSymbolsArr componentsJoinedByString:@"\n"]];
    NSString *path = [applicationDocumentsDirectory() stringByAppendingPathComponent:@"Exception.txt"];
    [errorInfo writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"errorInfo: %@",errorInfo);

}


@implementation NdUncaughtExceptionHandler


-(NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
 
+ (void)setDefaultHandler
{
     NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
}
 
+ (NSUncaughtExceptionHandler*)getHandler
{
     return NSGetUncaughtExceptionHandler();
}


@end
