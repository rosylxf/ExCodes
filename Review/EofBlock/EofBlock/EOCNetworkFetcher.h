//
//  EOCNetworkFetcher.h
//  EofBlock
//
//  Created by ricky on 8/27/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^EOCNetworkFetcherCompletionHandler)(NSData *data);

@interface EOCNetworkFetcher : NSObject

@property (nonatomic, strong, readonly) NSURL *url;

- (id)initWithUrl:(NSURL*)url;
- (void)startWithCompletionHandler:(EOCNetworkFetcherCompletionHandler)completion;

@end
