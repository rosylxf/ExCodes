//
//  MMTimeLineMgr.m
//  WeChatPlugin
//
//  Created by nato on 2017/1/22.
//  Copyright © 2017年 github:natoto. All rights reserved.
//

#import "MMTimeLineMgr.h"
#import "NSObject+ObjectMap.h"
#import "SnsTimeLineRequest2.h"
@interface MMTimeLineMgr () <MMCGIDelegate>

@property (nonatomic, assign, getter=isRequesting) BOOL requesting;
@property (nonatomic, strong) NSString *firstPageMd5;
@property (nonatomic, strong) SKBuiltinBuffer_t *session;
@property (nonatomic, strong) NSMutableArray *statuses;
@property (nonatomic, assign) BOOL isFetchNextTenData;

@end

@implementation MMTimeLineMgr{
    
    dispatch_source_t _timer;
}

//+ (id)sharedInstance {
//    static MMTimeLineMgr *instance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        instance = [[self alloc] init];
//    });
//
//    return instance;
//}

#pragma mark - Network

- (void)updateTimeLineHead {
    [self requestTimeLineDataAfterItemID:0];
}

- (void)updateTimeLineTail {
    MMStatus *status = [self.statuses lastObject];
    [self requestTimeLineDataAfterItemID:status.statusId];
}

- (void)requestUserPageTimeLineDataAfterItemID:(unsigned long long)itemID username:(NSString *)username{
    if (self.isRequesting) {
        return;
    }
    self.requesting = true;
    SnsUserPageRequest *request = [[CBGetClass(SnsUserPageRequest) alloc] init];
    request.username = username;
    request.baseRequest = [CBGetClass(MMCGIRequestUtil) InitBaseRequestWithScene:0];
//    request.clientLatestId = 0;
    request.firstPageMd5 = itemID == 0 ? self.firstPageMd5 : @"";
    request.lastRequestTime = 0;
    request.maxId = itemID;
    request.minFilterId = 0;
//    request.session = self.session;
    MMCGIWrap *cgiWrap = [[CBGetClass(MMCGIWrap) alloc] init];
    cgiWrap.m_requestPb = request;
    cgiWrap.m_functionId = kMMCGIWrapHomePageFunctionId;
    
    MMCGIService *cgiService = [[CBGetClass(MMServiceCenter) defaultCenter] getService:CBGetClass(MMCGIService)];
    [cgiService RequestCGI:cgiWrap delegate:self];
    
}

- (void)requestTimeLineDataAfterItemID:(unsigned long long)itemID {
    if (self.isRequesting) {
        return;
    }
    if (self.userName) {//去拉取个人主页
        [self requestUserPageTimeLineDataAfterItemID:itemID username:self.userName];
        return;
    }
    self.requesting = true;
    SnsTimeLineRequest *request = [[CBGetClass(SnsTimeLineRequest) alloc] init];
    request.baseRequest = [CBGetClass(MMCGIRequestUtil) InitBaseRequestWithScene:0];
    request.clientLatestId = 0;
    request.firstPageMd5 = itemID == 0 ? self.firstPageMd5 : @"";
    request.lastRequestTime = 0;
    request.maxId = itemID;
    request.minFilterId = 0;
    request.session = self.session;
    MMCGIWrap *cgiWrap = [[CBGetClass(MMCGIWrap) alloc] init];
    cgiWrap.m_requestPb = request;
    cgiWrap.m_functionId = kMMCGIWrapTimeLineFunctionId;
    
    MMCGIService *cgiService = [[CBGetClass(MMServiceCenter) defaultCenter] getService:CBGetClass(MMCGIService)];
    [cgiService RequestCGI:cgiWrap delegate:self];
    
}

- (NSMutableArray *)jsonlist {
    if (!_jsonlist) {
        _jsonlist = [[NSMutableArray alloc] init];
    }
    return _jsonlist;
}
#pragma mark - MMCGIDelegate
 -(void)OnResponseCGIFailedWithSessionId:(unsigned int)arg1 cgiWrap:(MMCGIWrap *)cgiWra errType:(int)arg2 errCode:(int)errcode
{
    NSLog(@"错误： %s",__func__);
    
}

- (void)TimeLineOnResponseCGI:(BOOL)arg1 sessionId:(unsigned int)arg2 cgiWrap:(MMCGIWrap *)cgiWrap {
    NSLog(@"%d %d %@", arg1, arg2, cgiWrap);
    SnsTimeLineRequest *request = (SnsTimeLineRequest *)cgiWrap.m_requestPb;
    SnsTimeLineResponse *response = (SnsTimeLineResponse *)cgiWrap.m_responsePb;
    
    self.session = response.session;
    NSMutableArray *statuses = [NSMutableArray new];
    NSString * jsonstr = @"";
    for (SnsObject *snsObject in response.objectList) {
        MMStatus *status = [MMStatus new];
        [status updateWithSnsObject:snsObject];
        [statuses addObject:status];
        
        MMStatusSimple *st = [MMStatusSimple new];
        [st updateWithSnsObject:snsObject];
        NSString * stajson = [st JSONString];
        jsonstr = [jsonstr stringByAppendingFormat:@"%@,",stajson];
    }
    jsonstr = [jsonstr stringByAppendingFormat:@""];
    NSLog(@"\n\njson:\n%@\n\n",jsonstr);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL isRefresh = request.maxId == 0;
        if (isRefresh) {
            self.firstPageMd5 = response.firstPageMd5;
            if (statuses.count) {
                self.statuses = statuses;
            }else{
                [self.statuses removeAllObjects];
            }
            self.jsonlist = [@[jsonstr] mutableCopy];
        }
        else {
            [self.statuses addObjectsFromArray:statuses];
            [self.jsonlist addObject:jsonstr];
        }
        self.requesting = false;
        
        [self saveTimeLineDataOnDesktop];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onTimeLineStatusChange)]) {
            [self.delegate onTimeLineStatusChange];
        }
    });
}

- (void)saveTimeLineDataOnDesktop{
    
    NSFileManager *fm = [NSFileManager defaultManager];//创建NSFileManager实例
    //获得文件路径，第一个参数是要定位的路径 NSApplicationDirectory-获取应用程序路径，NSDocumentDirectory-获取文档路径
    //第二个参数是要定义的文件系统域
    NSArray *paths = [fm URLsForDirectory:NSDesktopDirectory inDomains:NSUserDomainMask];
    //沙盒路径
    NSURL *path = [paths objectAtIndex:0];
    //要查找的文件
    
    NSString *myFiledFolder = [path.relativePath stringByAppendingFormat:@"/wechatTimeLine"];
    
    NSString *myFiled = [myFiledFolder stringByAppendingFormat:@"/timeline.json"];

    //判断文件是否存在
    BOOL result = [fm fileExistsAtPath:myFiled];
    
    [self.jsonlist enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj hasSuffix:@","]) {
            obj = [obj stringByReplacingCharactersInRange:NSMakeRange(obj.length-1, 1) withString:@""];
            [self.jsonlist replaceObjectAtIndex:idx withObject:obj];
        }
    }];
    
    NSString *content = [NSString stringWithFormat:@"[%@]",[self.jsonlist componentsJoinedByString:@","]];
    //如果文件不存在
    if (!result) {
        
        //创建文件夹
        [fm createDirectoryAtPath:myFiledFolder withIntermediateDirectories:YES attributes:nil error:nil];
        //文件
        BOOL isCreate = [fm createFileAtPath:myFiled contents:[content dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
        if (isCreate) {
            
            _isFetchNextTenData = NO;
            NSLog(@"创建成功");
            NSError * error;
            //            [string writeToFile:myFiled atomically:YES encoding:NSUTF8StringEncoding error:&error];
            
            if (error) {
                NSLog(@"save error:%@",error.description);
            }
        }
        else{
            NSLog(@"🌺 创建失败");
        }
    }else{
        
        NSData *data = [NSData dataWithContentsOfFile:myFiled];
        
        //将JSON数据转为NSArray或NSDictionary
        NSMutableArray *localJsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSNumber *latestStatusId = [[localJsonArray firstObject] objectForKey:@"statusId"];
        
        NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSArray *jsonListArr = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        __block BOOL isLoadedAll = NO;
        [jsonListArr enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([latestStatusId isEqualToNumber:[dict objectForKey:@"statusId"]]) {
                
                if (idx > 0) {
                    NSIndexSet *insertIndex = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, idx)];
                    [localJsonArray insertObjects:[jsonListArr subarrayWithRange:NSMakeRange(0, idx)] atIndexes:insertIndex];
//                    BOOL ret = [localJsonArray writeToFile:myFiled atomically:YES];
                    
                    NSData *tempData = [self toJSONData:localJsonArray];
                    NSString *jsonString =  [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
                    [jsonString writeToFile:myFiled atomically:YES encoding:NSUTF8StringEncoding error:NULL];
                }

                
//                NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:myFiled];
//                [fileHandle seekToFileOffset:0];
//                NSData *insertData = [NSJSONSerialization dataWithJSONObject:[jsonListArr subarrayWithRange:NSMakeRange(0, idx+1)] options:NSJSONWritingPrettyPrinted error:nil];
//                [fileHandle writeData:insertData];
//                [fileHandle synchronizeFile];
//                [fileHandle closeFile];
                isLoadedAll = YES;
                *stop = YES;
            }
            
        }];
        
        if (isLoadedAll) {
            
            _isFetchNextTenData = NO;
            
        }else{
            [self updateTimeLineTail];
        }

        
    }
    
    NSLog(@"OUTPUT:%@",myFiled);
    
}

- (NSData *)toJSONData:(id)theData{
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        return jsonData;
    }else{
        return nil;
    }
}

- (void)UserPageOnResponseCGI:(BOOL)arg1 sessionId:(unsigned int)arg2 cgiWrap:(MMCGIWrap *)cgiWrap {
    NSLog(@"%d %d %@", arg1, arg2, cgiWrap);
    SnsUserPageRequest *request = (SnsUserPageRequest *)cgiWrap.m_requestPb;
    SnsTimeLineResponse *response = (SnsTimeLineResponse *)cgiWrap.m_responsePb;
//    self.session = response.session;
    NSMutableArray *statuses = [NSMutableArray new];
    NSString * jsonstr = @"";
    for (SnsObject *snsObject in response.mutableObjectListList) {
        MMStatus *status = [MMStatus new];
        [status updateWithSnsObject:snsObject];
        [statuses addObject:status];
        
        MMStatusSimple *st = [MMStatusSimple new];
        [st updateWithSnsObject:snsObject];
        NSString * stajson = [st JSONString];
        jsonstr = [jsonstr stringByAppendingFormat:@"%@,",stajson];
    }
    jsonstr = [jsonstr stringByAppendingFormat:@""];
    NSLog(@"\n\njson:\n%@\n\n",jsonstr);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL isRefresh = request.maxId == 0;
        if (isRefresh) {
            self.firstPageMd5 = response.firstPageMd5;
            if (statuses.count) {
                self.statuses = statuses;
            }else{
                [self.statuses removeAllObjects];
            }
            self.jsonlist = [@[jsonstr] mutableCopy];
        }
        else {
            [self.statuses addObjectsFromArray:statuses];
            [self.jsonlist addObject:jsonstr];
        }
        self.requesting = false;
        if (self.delegate && [self.delegate respondsToSelector:@selector(onTimeLineStatusChange)]) {
            [self.delegate onTimeLineStatusChange];
        }
    });
}


//NSDictionary * dictionaryWithJsonString (NSString *jsonString)
//{
//    if (jsonString == nil) {
//        return nil;
//    }
//
//    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//    NSError *err;
//    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
//                                                        options:NSJSONReadingMutableContainers
//                                                          error:&err];
//    if(err)
//    {
//        NSLog(@"json解析失败：%@",err);
//        return nil;
//    }
//    return dic;
//}


- (void)OnResponseCGI:(BOOL)arg1 sessionId:(unsigned int)arg2 cgiWrap:(MMCGIWrap *)cgiWrap {
   
    SnsTimeLineRequest *request = (SnsTimeLineRequest *)cgiWrap.m_requestPb;
    SnsTimeLineResponse *response = (SnsTimeLineResponse *)cgiWrap.m_responsePb;
 
    if ([NSStringFromClass([response class]) isEqualToString:@"SnsTimeLineResponse"]) {
        [self TimeLineOnResponseCGI:arg1 sessionId:arg2 cgiWrap:cgiWrap];
    }
    else if ([NSStringFromClass([response class]) isEqualToString:@"SnsUserPageResponse"]) {
        [self UserPageOnResponseCGI:arg1 sessionId:arg2 cgiWrap:cgiWrap];
    }
}

#pragma mark - 

- (NSUInteger)getTimeLineStatusCount {
    return [self.statuses count];
}

- (MMStatus *)getTimeLineStatusAtIndex:(NSUInteger)index {
    if (index >= self.statuses.count) {
        return nil;
    }
    else {
        return self.statuses[index];
    }
}

#pragma mark - timer

- (void)fireTimer{
    
    [self initData];
    

    NSTimeInterval period = 10; //设置时间间隔
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        //在这里执行事件
        
        if (_isFetchNextTenData) {
            
        }else{
            [self updateTimeLineHead];
        }
        
    });
    dispatch_resume(_timer);
    
}


- (void)initData{
    _isFetchNextTenData = NO;
}












@end
