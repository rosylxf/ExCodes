//
//  ViewController.m
//  GCD&Operation
//
//  Created by ricky on 8/27/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import "ViewController.h"
#import "DownOperation.h"

@interface ViewController () <DownOperationDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.queue = [[NSOperationQueue alloc] init];

//    [self testNSInvocationOperation];

//    [self testNSBlockOperation];

//    [self testCustomOperation];

//    [self testAddDependency];
}

// 1. NSInvocationOperation
- (void)testNSInvocationOperation{

    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(download) object:nil];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    //添加操作到队列中,会自动异步执行 // 若要进行同步操作 调用[operation start]
    [queue addOperation:operation];

}

- (void)download{
    NSLog(@"download----%@", [NSThread currentThread]);
}

// 2. NSBlockOperation 用于将代码块封装成NSOperation,能够并发地执行一个或多个block对象,所有相关的block代码都执行完之后,操作才算完成
- (void)testNSBlockOperation{

    NSBlockOperation *operation = [[NSBlockOperation alloc] init];

    [operation addExecutionBlock:^{
        NSLog(@"----下载图片----1----%@", [NSThread currentThread]);
    }];

    [operation addExecutionBlock:^{
        NSLog(@"----下载图片----2----%@", [NSThread currentThread]);
    }];

    [operation addExecutionBlock:^{
        NSLog(@"----下载图片----3----%@", [NSThread currentThread]);
    }];

    //这里虽然执行的是start,但是operation添加的3个block是并发执行的,因此,党同一个操作的任务大于1时,该操作会实现异步执行
    [operation start];
}

/*
 * 3.自定义NSOperation
 * 定义非并发的NSOperation只需重载main方法,在这个方法里面执行主任务,并正确地相应取消事件
 * 对于并发的NSOperation操作,必须重写NSOperation的多个基本方法进行实现
 */

- (void)testCustomOperation{

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    DownOperation *operation = [[DownOperation alloc] init];
    operation.delegate = self;
    operation.url = @"http://www.itcast.cn/images/logo.png";

    [queue addOperation:operation];

}

- (void)downloadOperation:(DownOperation *)operation image:(UIImage *)image {
   
    self.imageView.image = image;
}

/*
 * 4. 对NSOperation操作设置依赖关系
 */
- (void)testAddDependency{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
       NSLog(@"执行第1次操作, 线程: %@", [NSThread currentThread]);
    }];

    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"执行第2次操作, 线程: %@", [NSThread currentThread]);
    }];

    NSBlockOperation *operation3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"执行第3次操作, 线程: %@", [NSThread currentThread]);
    }];

    //添加依赖
    [operation1 addDependency:operation2];
    [operation2 addDependency:operation3];

    //将操作添加到队列中去
    [queue addOperation:operation1];
    [queue addOperation:operation2];
    [queue addOperation:operation3];
}

/*
 * 5. 模拟暂停和继续操作
 * 表视图开启线程下载远程的网络界面,滚动页面时势必会有影响,降低用户的体验,针对这种情况,当用户滚动屏幕时,暂停队列,
 * 当用户停止滚动时,继续恢复队列
 */

- (IBAction)addOperation:(id)sender {

    self.queue.maxConcurrentOperationCount = 1;

    for (int i = 0; i < 20; ++i) {
        [self.queue addOperationWithBlock:^{
            //模拟休眠
            [NSThread sleepForTimeInterval:1.0f];
            NSLog(@"正在下载%@ %d", [NSThread currentThread], i);
        }];
    }
}

- (IBAction)pause:(id)sender {

    //判断队列中是否有操作
    if(self.queue.operationCount == 0){
        NSLog(@"没有操作");
        return;
    }
    //如果没有被挂起,才需要暂停
    if(self.queue.isSuspended){
        NSLog(@"暂停");
        [self.queue setSuspended:YES];
    } else{
        NSLog(@"已经暂停");
    }
}

- (IBAction)resume:(id)sender {
    //判断队列中是否有操作
    if(self.queue.operationCount == 0){
        NSLog(@"没有操作");
        return;
    }
    //
    if(self.queue.isSuspended){
        NSLog(@"继续");
        [self.queue setSuspended:NO];
    } else{
        NSLog(@"正在执行");
    }
}

@end
