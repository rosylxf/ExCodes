//
//  ViewController.m
//  内存管理
//
//  Created by ricky on 9/10/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, copy, nonnull) NSString *title;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [self printSomething];
}


- (void)printSomething {
    
    for (long i = 0; i <1000000; i++) {
        self.title = [NSString stringWithFormat:@"这是第%lu个title", i];
    }
    
    printf("=====");
    
    
    printf("------");
    
}


@end
