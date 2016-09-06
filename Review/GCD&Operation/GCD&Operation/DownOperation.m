//
//  DownOperation.m
//  GCD&Operation
//
//  Created by ricky on 8/27/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import "DownOperation.h"

@implementation DownOperation

- (void)main {
    @autoreleasepool {
        NSURL *url = [NSURL URLWithString:self.url];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"图片下载完成....");
            if([self.delegate respondsToSelector:@selector(downloadOperation:image:)]){
                [self.delegate downloadOperation:self image:image];
            }
        }];
    }

}

@end
