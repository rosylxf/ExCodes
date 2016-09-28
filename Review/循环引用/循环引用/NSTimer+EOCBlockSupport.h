//
//  NSTimer+EOCBlockSupport.h
//  循环引用
//
//  Created by ricky on 9/26/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (EOCBlockSupport)

+ (NSTimer*)eoc_scheduledTimeInterval:(NSTimeInterval)interval
                               block:(void(^)())block
                             repeats:(BOOL)repeats;

@end
