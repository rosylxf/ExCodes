//
//  DownOperation.h
//  GCD&Operation
//
//  Created by ricky on 8/27/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DownOperation;

@protocol DownOperationDelegate <NSObject>

- (void)downloadOperation:(DownOperation *)operation image:(UIImage *)image;

@end

@interface DownOperation : NSOperation

@property (nonatomic, strong) NSString *url;  //需要传入的图片url
@property (nonatomic, weak) id<DownOperationDelegate> delegate;

@end
