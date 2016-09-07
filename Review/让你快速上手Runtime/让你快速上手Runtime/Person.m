//
//  Person.m
//  让你快速上手Runtime
//
//  Created by ricky on 8/24/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import "Person.h"
#import <objc/message.h>
#import <objc/runtime.h>

@implementation Person

//runtime用于解归档
- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; ++i) {
        Ivar ivar = ivars[i];
        const char *name = ivar_getName(ivar);

        //归档
        NSString *key = [NSString stringWithUTF8String:name];
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
    free(ivars);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super init]){
        unsigned int count = 0;
        Ivar *ivars = class_copyIvarList([self class], &count);
        for (int i = 0; i < count; ++i) {
            Ivar ivar = ivars[i];
            const char *name = ivar_getName(ivar);

            //解档
            NSString *key = [NSString stringWithUTF8String:name];
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
        free(ivars);
    }
    return self;
}

- (void)eat{
    NSLog(@"eat is called");
}

+ (void)eat{
    NSLog(@"++eat is called");
}

// void(*)()
// 默认方法都有两个隐式参数，
void drink(id self,SEL sel)
{
    NSLog(@"%@ %@",self,NSStringFromSelector(sel));
}

//Method resolution
//3. 当一个对象调用未实现的方法，会调用这个方法处理,并且会把对应的方法列表传过来.
// 刚好可以用来判断，未实现的方法是不是我们想要动态添加的方法
+ (BOOL)resolveInstanceMethod:(SEL)sel
{

    if (sel == @selector(drink)) {
        // 动态添加eat方法

        // 第一个参数：给哪个类添加方法
        // 第二个参数：添加方法的方法编号
        // 第三个参数：添加方法的函数实现（函数地址）
        // 第四个参数：函数的类型，(返回值+参数类型) v:void @:对象->self :表示SEL->_cmd
        class_addMethod(self, sel, (IMP)drink, "v@:");

    }

    return [super resolveInstanceMethod:sel];
}

/*
 * Fast forwarding
 */
//- (id)forwardingTargetForSelector:(SEL)aSelector{
//
//}


@end
