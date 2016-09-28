//
//  EOCClass.m
//  循环引用
//
//  Created by ricky on 9/26/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import "EOCClass.h"

#import "NSTimer+EOCBlockSupport.h"

@interface EOCClass ()

@end

@implementation EOCClass {
    
    NSTimer *_pollTimer;
    
}

- (id)init{
    return [super init];
}

- (void)startPolling{
    
//    _pollTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(p_doPoll) userInfo:nil repeats:YES];
    
    __weak EOCClass *weakSelf = self;
    
    _pollTimer = [NSTimer eoc_scheduledTimeInterval:5.0 block:^{
        
        EOCClass *strongSelf = weakSelf;
        [strongSelf p_doPoll];
        
    } repeats:YES];
    
}

- (void)stopPolling{
    [_pollTimer invalidate];
    _pollTimer = nil;
}

- (void)dealloc{
    [_pollTimer invalidate];
}

- (void)p_doPoll {
    
}

@end
