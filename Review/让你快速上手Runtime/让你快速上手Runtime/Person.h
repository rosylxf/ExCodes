//
//  Person.h
//  让你快速上手Runtime
//
//  Created by ricky on 8/24/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject <NSCoding>

@property (nonatomic, assign) int age;
@property (nonatomic, assign) int height;
@property (nonatomic, copy) NSString *name;

- (void)eat;
+ (void)eat;

@end
