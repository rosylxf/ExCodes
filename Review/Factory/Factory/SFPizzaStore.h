//
//  SFPizzaStore.h
//  Factory
//
//  Created by ricky on 9/21/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFPizza.h"

@interface SFPizzaStore : NSObject

- (SFPizza *) orderPizza:(PizzaType)pizzaType;

@end
