//
//  ViewController.m
//  让你快速上手Runtime
//
//  Created by ricky on 8/24/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import <objc/message.h>
#import "UIImage+image.h"
#import "NSObject+property.h"

@interface ViewController ()

@property (nonatomic, assign) int flag;

@property (nonatomic, retain) Person *person;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _flag = 0;
    
    //遍历成员变量
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([Person class], &count);
    for (int i = 0; i<count; i++) {
        Ivar ivar = ivars[i];
        
        const char *name = ivar_getName(ivar);
        NSLog(@"%s", name);
    }
    
//    [self sendMsg];
//    [self swapMethod];
//    [self dynamicAddMethod];
    [self addCategoryProperty];

}

//1. 发送消息
- (void)sendMsg{
    // 创建person对象
    Person *p = [[Person alloc] init];
    
    // 调用对象方法
    [p eat];
    
    // 本质：让对象发送消息
    objc_msgSend(p, @selector(eat));
    
    // 调用类方法的方式：两种
    // 第一种通过类名调用
    [Person eat];
    // 第二种通过类对象调用
    [[Person class] eat];
    
    // 用类名调用类方法，底层会自动把类名转换成类对象调用
    // 本质：让类对象发送消息
    objc_msgSend([Person class], @selector(eat));
}

// 2. 交换方法
- (void)swapMethod{
    
    // Do any additional setup after loading the view, typically from a nib.
    // 需求：给imageNamed方法提供功能，每次加载图片就判断下图片是否加载成功。
    // 步骤一：先搞个分类，定义一个能加载图片并且能打印的方法+ (instancetype)imageWithName:(NSString *)name;
    // 步骤二：交换imageNamed和imageWithName的实现，就能调用imageWithName，间接调用imageWithName的实现。
    UIImage *image = [UIImage imageNamed:@"123"];
    NSLog(@"%@", image);
}

/*
 * 3.动态添加方法
 *   开发使用场景：如果一个类方法非常多，加载类到内存的时候也比较耗费资源，需要给每个方法生成映射表，可以使用动态给某个类，添加方法解决。
 *   经典面试题：有没有使用performSelector，其实主要想问你有没有动态添加过方法。
 */
- (void)dynamicAddMethod{

    Person *p = [[Person alloc] init];

    // 默认person，没有实现drink方法，可以通过performSelector调用，但是会报错。
    // 动态添加方法就不会报错
    [p performSelector:@selector(drink)];
}

// 用performSelector可能会导致内存泄露
- (void)testPerformSelectorMemoryLeak{
    
    SEL selector;
    
    if (_flag == 0) {
        
        selector = @selector(newObject);
        
    }else if (_flag == 1) {
        
        selector = @selector(copyObject);
        
    }else {
        selector = @selector(someProperty);
    }
    //Arc 环境下编译器不知道不知道该不该释放ret对象，所以编译采取保守的做法，就是不释放ret，但若是前两种情况就会导致内存泄露
    id ret = [self performSelector:selector];
}

- (void)newObject{
    self.person = [[Person alloc] init];
    self.person.age = 18;
    self.person.height = 178;
}

- (void)copyObject{
    self.person = [[Person alloc] init];
    self.person.age = 18;
    self.person.height = 178;
}

- (void)someProperty{
    NSLog(@"xxx");
}

/*
 * 4. 给分类添加属性
 * 原理:给一个类声明属性，其实本质就是给这个类添加关联，并不是直接把这个值的内存空间添加到类存空间。
 */
- (void)addCategoryProperty{
    // 给系统NSObject类动态添加属性name
    
    NSObject *objc = [[NSObject alloc] init];
    objc.name = @"小码哥";
    NSLog(@"%@",objc.name);
}

/*
 * 5. 字典转模型
 */



@end
