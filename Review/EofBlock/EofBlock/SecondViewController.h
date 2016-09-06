//
//  SecondViewController.h
//  EofBlock
//
//  Created by ricky on 8/26/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MyBlock)(NSString*);

@interface SecondViewController : UIViewController

@property (nonatomic, copy) MyBlock myBlock;

@end
