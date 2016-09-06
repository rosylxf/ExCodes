//
//  EOCNetworkFetcher.m
//  EofBlock
//
//  Created by ricky on 8/27/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import "EOCNetworkFetcher.h"

@interface EOCNetworkFetcher ()

@property (nonatomic, strong, readwrite) NSURL *url;
@property (nonatomic, copy) EOCNetworkFetcherCompletionHandler completionHandler;
@property (nonatomic, strong) NSData *downloaderData;

@end

@implementation EOCNetworkFetcher

- (id)initWithUrl:(NSURL *)url {
    if(self = [super init]){
        _url = url;
    }
    return self;
}

- (void)startWithCompletionHandler:(EOCNetworkFetcherCompletionHandler)completion {

    self.completionHandler = completion;
    // start the request
    // request sets downloadeData property
    // when request is finished, p_requestcompleted is called
}

- (void)p_requestCompleted{

    if(_completionHandler){
        _completionHandler(_downloaderData);
    }
}

@end
