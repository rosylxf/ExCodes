//
//  ViewController.m
//  NSURLSession
//
//  Created by ricky on 9/6/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray *imageArr = @[@"https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/logo_white_fe6da1ec.png", @"afdsahttps://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/logo_white_fe6da1ecaa.png"];
    
    
    [self test:imageArr block:^(NSArray *arr) {
        
        NSLog(@"===%@", arr);
        
    }];
    
}

//- (void)testGet {
//    
//    NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
//    
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    
//    NSURLSession *session = [NSURLSession sharedSession];
//    
//    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        
//        NSLog(@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
//    }];
//    
//    [task resume];
//    
//}

- (void)test:(NSArray*)arr block:(void(^)(NSArray *))completeblock {
    
    
    NSMutableArray *failArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        
        dispatch_group_async(group, queue, ^{
            
            NSURL *url = [NSURL URLWithString:obj];
            
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            
            NSURLSession *session = [NSURLSession sharedSession];
            
            NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                if (error) {
                    [failArr addObject:obj];
                }else{
                    
                    
                    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"LaunchImage"];
                    NSLog(@"%@",path);
                    
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    BOOL isDir = FALSE;
                    BOOL isDirExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
                    
                    if (!isDirExist) {
                        
                        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
                        
                    }
                    
                    NSString *dataDir = [NSString stringWithFormat:@"%@/%lu.png", path, idx];
                    
                    [data writeToFile:dataDir atomically:YES];
                    
                    
                }
                
            }];
            
            [task resume];
        });
        
        
        
        
        
        
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //更新UI界面
        
        completeblock(failArr);
        
        
    });
    
    
    
}


@end
