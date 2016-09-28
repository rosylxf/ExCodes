//
//  NSTimer+EOCBlockSupport.m
//  循环引用
//
//  Created by ricky on 9/26/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import "NSTimer+EOCBlockSupport.h"

@implementation NSTimer (EOCBlockSupport)

+ (NSTimer*)eoc_scheduledTimeInterval:(NSTimeInterval)interval block:(void (^)())block repeats:(BOOL)repeats {
    
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(eoc_blockInvoke:) userInfo:[block copy] repeats:repeats];
    
}

+ (void)eoc_blockInvoke:(NSTimer*)timer {
    void (^block)() = timer.userInfo;
    if (block) {
        block();
    }
}

@end
