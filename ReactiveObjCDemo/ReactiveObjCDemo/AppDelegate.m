//
//  AppDelegate.m
//  ReactiveObjCDemo
//
//  Created by zack on 2021/1/18.
//

#import "AppDelegate.h"
#import "SMLagMonitor.h"

#import "NdUncaughtExceptionHandler.h"

#import <CocoaLumberjack/CocoaLumberjack.h>


#ifdef DEBUG
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

 

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    [[SMLagMonitor shareInstance] beginMonitor];
//        
//    [NdUncaughtExceptionHandler setDefaultHandler];
//    
    
    //#####
     
    //配置DDLog
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
     
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
 

    
    DDLogDebug(@"####### :%d",27);
    
//    DDLogDebug(@"Debug");
 
   
//    sleep(3);
//    int i = 0;
//    while (i++<10000) {
//
//        DDLogDebug(@"Debug");
//        sleep(0.1);
//
//    }
    
//    DDLogDebug(@"#######");
    sleep(3);
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
