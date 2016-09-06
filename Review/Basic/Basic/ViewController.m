//
//  ViewController.m
//  Basic
//
//  Created by ricky on 9/1/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import "ViewController.h"

NSString *const EOCStringConstant = @"VALUE";

static const NSTimeInterval kAnimationDuration = 0.3;

@interface ViewController ()

//@property (copy) NSMutableArray *mutableArray;  // 有问题，1、添加,删除,修改数组内的元素的时候,程序会因为找不到对应的方法而崩溃.因为 copy 就是复制一个不可变 NSArray 的对象；2、使用了 atomic 属性会严重影响性能 ；

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *someString = nil;
    if ([ someString rangeOfString:@"swift"].location != NSNotFound) {
        NSLog(@"Someone mentioned swift!");
    }
    // Do any additional setup after loading the view, typically from a nib.
    
//    UIView *view ;
//    CALayer
    
//    NSMutableArray *array = [NSMutableArray arrayWithObjects:@1, @2, nil];
//    self.mutableArray =  array;
//
//    [self.mutableArray removeObjectAtIndex:0];

    int  (^MyBlock)(NSArray *, NSString *, NSInteger) = ^(NSArray *array, NSString *string, NSInteger i) {

        return 0;
    };
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
