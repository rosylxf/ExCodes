//
//  PersonObserver.m
//  KVO_KVC
//
//  Created by ricky on 9/2/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import "PersonObserver.h"

@implementation PersonObserver

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    NSLog(@"old: %@", [change objectForKey:NSKeyValueChangeOldKey]);
    NSLog(@"new: %@", [change objectForKey:NSKeyValueChangeNewKey]);
    NSLog(@"context: %@", context);
}

@end
