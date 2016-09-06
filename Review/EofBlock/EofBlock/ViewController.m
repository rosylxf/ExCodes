//
//  ViewController.m
//  EofBlock
//
//  Created by ricky on 8/26/16.
//  Copyright © 2016 ricky. All rights reserved.
//

#import "ViewController.h"
#import "SecondViewController.h"
#import "EOCNetworkFetcher.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ViewController {
    // 网络请求
    EOCNetworkFetcher *_networkFetcher;
    NSData *_fetchedData;
}

- (void)viewDidLoad {
    [super viewDidLoad];

//    void (^someBlock)() = ^{
//        NSLog(@"some block");
//    };
//    
//    someBlock();
}

- (void)downloadData{

    NSURL *url = [[NSURL alloc] initWithString:@"http://www.example.com/something.dat"];
    _networkFetcher = [[EOCNetworkFetcher alloc] initWithUrl:url];

    [_networkFetcher startWithCompletionHandler:^(NSData *data){
        NSLog(@"Request URL %@ Finished", _networkFetcher.url);
        _fetchedData = data;
    }];
}


- (IBAction)BlockButtonAction:(id)sender {
  
    __block int additional = 5;
    int (^addBlock)(int a, int b) = ^(int a, int b){

        additional = 0;
        return a+b+additional;
    };

    int add = addBlock(2, 5);
    
    NSLog(@"%d", add);
}



- (IBAction)nextAction:(id)sender {
    
    SecondViewController *sec = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SecondViewController"];
    
    sec.myBlock = ^(NSString *greeting){
        NSLog(@"===%@", greeting);
    };
    
    [self.navigationController pushViewController:sec animated:YES];
    
}

@end
