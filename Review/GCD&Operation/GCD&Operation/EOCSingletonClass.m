//
//  EOCSingletonClass.m
//  GCD&Operation
//
//  Created by ricky on 8/27/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import "EOCSingletonClass.h"

@implementation EOCSingletonClass

+ (id)shareInstance {

    static EOCSingletonClass *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

@end
