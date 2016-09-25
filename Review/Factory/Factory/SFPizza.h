//
//  FMPizza.h
//  Factory
//
//  Created by ricky on 9/21/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PizzaType){
    Cheese = 0,
    Clam   = 1
};

@interface SFPizza : NSObject

- (void)prepare;
- (void)bake;
- (void)cut;
- (void)box;

@end
