//
//  ViewController.m
//  内存管理
//
//  Created by ricky on 9/10/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, copy, nonnull) NSString *mTitle;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
//    [self printSomething];
}


- (void)printSomething {
    
    for (long i = 0; i <(unsigned long)-1; i++) {
        self.mTitle = [NSString stringWithFormat:@"这是第%lu个title", i];   //内存会持续增长
    }
    
    printf("=====");
    
    printf("------");
    
}


@end
