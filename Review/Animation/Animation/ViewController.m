//
//  ViewController.m
//  Animation
//
//  Created by ricky on 9/7/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIView *vLight;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.vLight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    self.vLight.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:self.vLight];
    
    UIPanGestureRecognizer * panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(doHandlePanAction:)];
    [self.vLight addGestureRecognizer:panGestureRecognizer];
    
}

- (void) doHandlePanAction:(UIPanGestureRecognizer *)paramSender{
    
    CGPoint point = [paramSender translationInView:self.view];
    NSLog(@"X:%f;Y:%f",point.x,point.y);
    
    paramSender.view.center = CGPointMake(paramSender.view.center.x + point.x, paramSender.view.center.y + point.y);
    [paramSender setTranslation:CGPointMake(0, 0) inView:self.view];
    
    
}

@end


// 为什么当 Core Animation 完成时，layer 又会恢复到原先的状态？
///*
// *因为这些产生的动画只是假象,并没有对layer进行改变.那么为什么会这样呢,这里要讲一下图层树里的呈现树.呈现树实际上是模型图层的复制,但是它的属性值表示了当前外观效果,动画的过程实际上只是修改了呈现树,并没有对图层的属性进行改变,所以在动画结束以后图层会恢复到原先状态
// */