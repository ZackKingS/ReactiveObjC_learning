//
//  SMLagMonitor.m
//
//  Created by DaiMing on 16/3/28.
//

#import "SMLagMonitor.h"
#import "SMCallStack.h"
#import "SMCallStackModel.h"
#import "SMCPUMonitor.h"
#import "SMLagDB.h"
#import <ReactiveCocoa/RACEXTScope.h>
 

@interface SMLagMonitor() {
//    int timeoutCount;
//    CFRunLoopObserverRef runLoopObserver;
//    @public
//    dispatch_semaphore_t dispatchSemaphore;
//    CFRunLoopActivity runLoopActivity;
}

@property (nonatomic, assign) CFRunLoopObserverRef     runLoopObserver;
@property (nonatomic, strong) dispatch_semaphore_t     dispatchSemaphore;
@property (nonatomic, assign) int                      timeoutCount;
@property (nonatomic, assign) CFRunLoopActivity        runLoopActivity;

@property (nonatomic, strong) NSTimer                  *cpuMonitorTimer;
@end

@implementation SMLagMonitor

#pragma mark - Interface
+ (instancetype)shareInstance {
    static id instance = nil;
    static dispatch_once_t dispatchOnce;
    dispatch_once(&dispatchOnce, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

/*
  
 typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
     kCFRunLoopEntry = (1UL << 0),
     kCFRunLoopBeforeTimers = (1UL << 1),    -> 2
     kCFRunLoopBeforeSources = (1UL << 2),   -> 4
     kCFRunLoopBeforeWaiting = (1UL << 5),   -> 32
     kCFRunLoopAfterWaiting = (1UL << 6),    -> 64
     kCFRunLoopExit = (1UL << 7),            -> 128
     kCFRunLoopAllActivities = 0x0FFFFFFFU
 };
 
 对于 iOS 开发来说，监控卡顿就是要去找到主线程上都做了哪些事儿。我们都知道，线程的消息事件是依赖于 NSRunLoop 的，所以从 NSRunLoop 入手，就可以知道主线程上都调用了哪些方法。我们通过监听 NSRunLoop 的状态，就能够发现调用方法是否执行时间过长，从而判断出是否会出现卡顿。
 */
- (void)beginMonitor {
    self.isMonitoring = YES;
    //监测 CPU 消耗
    self.cpuMonitorTimer = [NSTimer scheduledTimerWithTimeInterval:3
                                                             target:self
                                                           selector:@selector(updateCPUInfo)
                                                           userInfo:nil
                                                            repeats:YES];
    //监测卡顿
    if (self.runLoopObserver) {
        return;
    }
    self.dispatchSemaphore = dispatch_semaphore_create(0); //Dispatch Semaphore保证同步
    //创建一个观察者
    CFRunLoopObserverContext context = {0,(__bridge void*)self,NULL,NULL};
    self.runLoopObserver = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                              kCFRunLoopAllActivities,
                                              YES,
                                              0,
                                              &runLoopObserverCallBack,
                                              &context);
    //将观察者添加到主线程runloop的common模式下的观察中
    CFRunLoopAddObserver(CFRunLoopGetMain(), self.runLoopObserver, kCFRunLoopCommonModes);
    
    @weakify(self);
    //创建子线程监控
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @strongify(self);
        //子线程开启一个持续的loop用来进行监控
        while (YES) {
            long semaphoreWait = dispatch_semaphore_wait(self.dispatchSemaphore, dispatch_time(DISPATCH_TIME_NOW, STUCKMONITORRATE * NSEC_PER_MSEC));
            if (semaphoreWait != 0) {
                if (!self.runLoopObserver) {
                    self.timeoutCount = 0;
                    self.dispatchSemaphore = 0;
                    self.runLoopActivity = 0;
                    return;
                }
                //两个runloop的状态， BeforeSources(4)  和 AfterWaiting(64) 这两个状态区间时间能够检测到是否卡顿
                if (self.runLoopActivity == kCFRunLoopBeforeSources || self.runLoopActivity == kCFRunLoopAfterWaiting) {
                   
//                    NSLog(@"出现结果");
                    if (++self.timeoutCount < 3) {
                        continue;
                    }
//                  NSLog(@"monitor trigger ！");
                    
                    /*
                     将【堆栈信息】上报服务器的代码放到这里
                     */
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        
                        //获取主线程 堆栈信息
                        NSString *stackStr = [SMCallStack callStackWithType: SMCallStackTypeMain];
                        SMCallStackModel *model = [[SMCallStackModel alloc] init];
                        model.stackStr = stackStr;
                        model.isStuck = YES;
                        [[[SMLagDB shareInstance] increaseWithStackModel:model] subscribeNext:^(id x) {
                            
                        }];
                    });
                } //end activity
            }// end semaphore wait
            self.timeoutCount = 0;
        }// end while
    });
    
}

- (void)endMonitor {
    self.isMonitoring = NO;
    [self.cpuMonitorTimer invalidate];
    if (!self.runLoopObserver) {
        return;
    }
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), self.runLoopObserver, kCFRunLoopCommonModes);
    CFRelease(self.runLoopObserver);
    self.runLoopObserver = NULL;
}

#pragma mark - Private
- (void)updateCPUInfo {
    [SMCPUMonitor updateCPU];
}

static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    
    //获取当前类
    SMLagMonitor *lagMonitor = (__bridge SMLagMonitor*)info;
    
    //赋值当前的runLoopActivity
    lagMonitor.runLoopActivity = activity;
//    switch (activity) {
//        case kCFRunLoopEntry:
//            NSLog(@"kCFRunLoopEntry");
//            break;
//        case kCFRunLoopBeforeTimers:
//            NSLog(@"kCFRunLoopBeforeTimers");
//            break;
//        case kCFRunLoopBeforeSources:
//            NSLog(@"kCFRunLoopBeforeSources");
//            break;
//        case kCFRunLoopBeforeWaiting:
//            NSLog(@"kCFRunLoopBeforeWaiting");
//            break;
//        case kCFRunLoopAfterWaiting:
//            NSLog(@"kCFRunLoopAfterWaiting");
//            break;
//        case kCFRunLoopExit:
//            NSLog(@"kCFRunLoopAfterWaiting");
//            break;
//        default:
//            break;
//    }
    
    
    dispatch_semaphore_t semaphore = lagMonitor.dispatchSemaphore;
    dispatch_semaphore_signal(semaphore);
}

@end
