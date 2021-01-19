//
//  ViewController.m
//  ReactiveObjCDemo
//
//  Created by zack on 2021/1/18.
//

#import "ViewController.h"
#import <ReactiveObjC.h>

#import "SMDB.h"
 
@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *feeds;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self RACObserve];
}

 

- (void)RACObserve{
    
    @weakify(self);
    RAC(self, feeds) = [[[SMDB shareInstance] selectAllFeeds]
                        map:^id(NSMutableArray *feedsArray) {
                            if (feedsArray.count > 0) {
                                NSLog(@"count > 0");
                            } else {
                                NSLog(@"count <= 0");
                            }
                            return feedsArray;
                        }];
    
    //监听列表数据变化进行列表更新
    [RACObserve(self, feeds) subscribeNext:^(id x) {
        @strongify(self);
//        [self fetchAllFeeds];
        NSLog(@"fetchAllFeeds");
    }];
}

- (void)subscribe{
    
    //1、创建订阅者
    RACSignal * signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        //3、发送信号，发送信号之前一定要先订阅信号
        [subscriber sendNext:@"1"];
        [subscriber sendCompleted];
        return nil;
    }];
    //2、订阅信号
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
}

 
- (void)RACSubject{
    
    RACSubject *subject = [RACSubject subject];
    [subject subscribeNext:^(id x) {
        NSLog(@"第一个订阅者%@",x);
    }];
    [subject subscribeNext:^(id x) {
        NSLog(@"第二个订阅者%@",x);
    }];
    //3.发送信号
    [subject sendNext:@"1"];
}

- (void)concat{
    
    RACSignal *signalA =[RACSignal createSignal:^RACDisposable*(id subscriber) {
        NSLog(@"上半部分的请求");
        [subscriber sendNext:@"上半部分数据"];
        sleep(4);
        //加上后就可以上部分发送完毕后发送下半部分信号，这个必须要把信号A这个关闭，要不信号B就无法触发
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signalB =[RACSignal createSignal:^RACDisposable*(id subscriber) {
        NSLog(@"下半部分的请求");
        [subscriber sendNext:@"下半部分数据"];
        return nil;
    }];

    // contact：按顺序去连接（组合）
    //注意：第一个信号必须调用sendCompleted
    RACSignal *contactSignal = [signalA concat: signalB]; //signalA  signalB
    [contactSignal subscribeNext:^(id x) {
        //按顺序触发，当A信号触发完后，才可使走信号B中的方法，输出结果可以出结果
        NSLog(@"%@",x);
    }];
 
}

- (void)testTmer{
    [[RACSignal interval:1 onScheduler:[RACScheduler schedulerWithPriority:(RACSchedulerPriorityHigh) name:@" com.ReactiveCocoa.RACScheduler.mainThreadScheduler"]] subscribeNext:^(NSDate * _Nullable x) {
        NSLog(@"%@",[NSThread currentThread]);
    }];
}

- (void)testNoti{
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"%@",x);
    }];
}



@end