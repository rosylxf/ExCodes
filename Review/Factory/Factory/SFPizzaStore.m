//
//  SFPizzaStore.m
//  Factory
//
//  Created by ricky on 9/21/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import "SFPizzaStore.h"
#import "SFPizzaSimpleFactory.h"

@interface SFPizzaStore (){
    
    SFPizzaSimpleFactory *_simpleFactory;
}

@end

@implementation SFPizzaStore

- (instancetype)init{
    self = [super init];
    
    if (self) {
        _simpleFactory = [[SFPizzaSimpleFactory alloc]init];
    }
    
    return self;
}

- (SFPizza *)orderPizza:(PizzaType)pizzaType{
    SFPizza *pizza = [_simpleFactory createPizza:pizzaType];
    
    [pizza prepare];
    [pizza bake];
    [pizza cut];
    [pizza box];
    
    return pizza;
}

@end
