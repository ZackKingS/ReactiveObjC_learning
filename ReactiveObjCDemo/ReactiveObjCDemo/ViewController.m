//
//  ViewController.m
//  ReactiveObjCDemo
//
//  Created by zack on 2021/1/18.
//

#import "ViewController.h"
#import "SMDB.h"
#import "SMNetManager.h"
#import "XMGFileTool.h"

 
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <UIImageView+WebCache.h>
#import <ReactiveCocoa/RACEXTScope.h>

#import "SMLagButton.h"
#import "SMStackViewController.h"
#import "SMClsCallViewController.h"
#import "Masonry.h"

#import "SMCallStack.h"
#import "SMCallStackModel.h"
#import "SMLagDB.h"
#import "SMCallStack.h"

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *feeds;
@property (nonatomic) NSUInteger fetchingCount;
//monitor
@property (nonatomic, strong) SMLagButton *stackBt;
@property (nonatomic, strong) SMLagButton *clsCallBt;

@property (nonatomic, assign) int age;

@end
 
  
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self addUI];
 
//    [self crashCase];
    
//    [self lagCase];
    
//    [self testBlockTest];
    
    [self testContinue];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.age = 20;
}

- (void)addUI{
    
    [self.view addSubview:self.stackBt];
    [self.view addSubview:self.clsCallBt];
    
    [self.clsCallBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(120);
        make.right.equalTo(self.view).offset(-10);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [self.stackBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.clsCallBt.mas_top);
        make.right.equalTo(self.clsCallBt.mas_left).offset(-10);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
}

- (void)testContinue{
    
    NSArray *list = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8"];
    for (NSString *num in list) {
        if ([num isEqualToString:@"6"]) continue;
//        if ([num isEqualToString:@"6"]) break;
        NSLog(@"num: %@",num);
    }
}

- (void)testBlockTest{
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    [XMGFileTool getFileSize:path completion:^(NSInteger size) {
        NSLog(@"getFileSize size: %ld KB",(long)size/1024);
    }];
    
}


-(void)lagCase{
    while (1) {
        
    }
}

- (void)crashCase{
    NSArray *arr = @[@(0),@(1)];
    NSLog(@"%@",arr[2]);//模拟越界异常
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
        [self fetchAllFeeds];
    }];
}

- (void)fetchAllFeeds {
    
    self.fetchingCount = 0; //统计抓取数量
    
    @weakify(self);
    [[[[[[SMNetManager shareInstance] fetchAllFeedWithModelArray:self.feeds] map:^id(NSNumber *value) {
       
        @strongify(self);
        NSUInteger index = [value integerValue];
        return self.feeds[index];
        
    }] doCompleted:^{
        
        //抓完所有的feeds
//        @strongify(self);
        self.fetchingCount = 0;
        NSLog(@"fetch complete");
        
    }] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id value) {
       
        //抓完一个
//        @strongify(self);
        self.fetchingCount += 1;
        NSString* text = [NSString stringWithFormat:@"正在获取...(%lu/%lu)",(unsigned long)self.fetchingCount,(unsigned long)self.feeds.count];
        NSLog(@"%@",text);
         
    }];
}

- (SMLagButton *)stackBt{
    if (!_stackBt) {
        _stackBt = [[SMLagButton alloc] initWithStr:@"堆栈" size:16 backgroundColor:[UIColor blackColor]];
        [[_stackBt click] subscribeNext:^(id x) {
            SMStackViewController *vc = [[SMStackViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }
    return _stackBt;
}

- (SMLagButton *)clsCallBt {
    if (!_clsCallBt) {
        _clsCallBt = [[SMLagButton alloc] initWithStr:@"频次" size:16 backgroundColor:[UIColor blackColor]];
        [[_clsCallBt click] subscribeNext:^(id x) {
            SMClsCallViewController *vc = [[SMClsCallViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }
    return _clsCallBt;
}



- (void)basicUseage{
    
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
