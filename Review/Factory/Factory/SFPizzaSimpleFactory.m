//
//  SFPizzaSimpleFactory.m
//  Factory
//
//  Created by ricky on 9/21/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import "SFPizzaSimpleFactory.h"
#import "SFCheesePizza.h"
#import "SFClamPizza.h"

@implementation SFPizzaSimpleFactory

- (SFPizza*)createPizza:(PizzaType)pizzaType{
    
    SFPizza *pizza = nil;
    
    if (pizzaType == Cheese) {
        pizza = [[SFCheesePizza alloc] init];
    } else if (pizzaType == Clam) {
        pizza = [[SFClamPizza alloc] init];
    }
    
    return pizza;
}

@end
