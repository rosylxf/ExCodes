//
//  ViewController.m
//  KVO_KVC
//
//  Created by ricky on 9/2/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "PersonObserver.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

    [self testMethod];
}

- (void)testMethod {
    Person *aPerson = [[Person alloc] init];

    PersonObserver *aPersonObserver = [[PersonObserver alloc] init];

    [aPerson addObserver:aPersonObserver forKeyPath:@"name" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:@"this is a context"];

    //设置key的value值,aPersonObserver接到通知
    [aPerson setValue:@"lilei" forKey:@"name"];
    NSLog(@"name: %@", [aPerson valueForKey:@"name"]);

    //移除观察者
    [aPerson removeObserver:aPersonObserver forKeyPath:@"name"];
}

@end
