//
//  GVRouter.m
//  GVRouterExample
//
//  Created by Gavin on 16/10/14.
//  Copyright © 2016年 Gavin. All rights reserved.
//

#import "GVRouter.h"
#import <objc/runtime.h>

@interface GVRouter ()
@property (strong, nonatomic) NSMutableDictionary *routes;
@end

@implementation GVRouter

+ (instancetype)shared
{
    static GVRouter *router = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (!router) {
            router = [[self alloc] init];
        }
    });
    return router;
}
- (void)map:(NSString *)route toBlock:(GVRouterBlock)block
{
    NSMutableDictionary *subRoutes = [self subRoutesToRoute:route];
    
    subRoutes[@"_"] = [block copy];
}
- (UIViewController *)matchController:(NSString *)route
{
    NSDictionary *params = [self paramsInRoute:route];
    Class controllerClass = params[@"controller_class"];
    GVRouterOption *option = params[@"option"];
    UIViewController *viewController = nil;
    if (option) {
        switch (option.type) {
            case InterfaceBuilderTypeXib:
            {
                viewController = [[option.bundle loadNibNamed:option.nib owner:self options:nil] objectAtIndex:option.nibIndex];
            }
                break;
            case InterfaceBuilderTypeStoryBoard:
            {
                viewController = [[UIStoryboard storyboardWithName:option.storyBoard bundle:option.bundle] instantiateViewControllerWithIdentifier:option.identifier];
            }
                break;
            default:
                viewController = [[controllerClass alloc] init];
                break;
        }
        
    }else{
        viewController = [[controllerClass alloc] init];
    }
    if ([viewController respondsToSelector:@selector(setParams:)]) {
        [viewController performSelector:@selector(setParams:)
                             withObject:[params copy]];
    }
    return viewController;
}

- (UIViewController *)match:(NSString *)route
{
    return [self matchController:route];
}

- (GVRouterBlock)matchBlock:(NSString *)route
{
    NSDictionary *params = [self paramsInRoute:route];
    
    if (!params){
        return nil;
    }
    
    GVRouterBlock routerBlock = [params[@"block"] copy];
    GVRouterBlock returnBlock = ^id(NSDictionary *aParams) {
        if (routerBlock) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:params];
            [dic addEntriesFromDictionary:aParams];
            return routerBlock([NSDictionary dictionaryWithDictionary:dic].copy);
        }
        return nil;
    };
    
    return [returnBlock copy];
}

- (id)callBlock:(NSString *)route
{
    NSDictionary *params = [self paramsInRoute:route];
    GVRouterBlock routerBlock = [params[@"block"] copy];
    
    if (routerBlock) {
        return routerBlock([params copy]);
    }
    return nil;
}

// extract params in a route
- (NSDictionary *)paramsInRoute:(NSString *)route
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    params[@"route"] = [self stringFromFilterAppUrlScheme:route];
    
    NSDictionary *subRoutes = self.routes;
    NSArray *pathComponents = [self pathComponentsFromRoute:params[@"route"]];
    for (NSString *pathComponent in pathComponents) {
        BOOL found = NO;
        NSArray *subRoutesKeys = subRoutes.allKeys;
        for (NSString *key in subRoutesKeys) {
            if ([subRoutesKeys containsObject:pathComponent]) {
                found = YES;
                subRoutes = subRoutes[pathComponent];
                break;
            } else if ([key hasPrefix:@":"]) {
                found = YES;
                subRoutes = subRoutes[key];
                params[[key substringFromIndex:1]] = pathComponent;
                break;
            }
        }
        if (!found) {
            return nil;
        }
    }
    
    // Extract Params From Query.
    NSRange firstRange = [route rangeOfString:@"?"];
    if (firstRange.location != NSNotFound && route.length > firstRange.location + firstRange.length) {
        NSString *paramsString = [route substringFromIndex:firstRange.location + firstRange.length];
        NSArray *paramStringArr = [paramsString componentsSeparatedByString:@"&"];
        for (NSString *paramString in paramStringArr) {
            NSArray *paramArr = [paramString componentsSeparatedByString:@"="];
            if (paramArr.count > 1) {
                NSString *key = [paramArr objectAtIndex:0];
                NSString *value = [paramArr objectAtIndex:1];
                params[key] = value;
            }
        }
    }
    
    Class class = subRoutes[@"_"];
    if (class_isMetaClass(object_getClass(class))) {
        if ([class isSubclassOfClass:[UIViewController class]]) {
            params[@"controller_class"] = subRoutes[@"_"];
        } else {
            return nil;
        }
    } else {
        if (subRoutes[@"_"]) {
            params[@"block"] = [subRoutes[@"_"] copy];
        }
    }
    if (subRoutes[@"#"]) {
        params[@"option"] = subRoutes[@"#"];
    }
    return [NSDictionary dictionaryWithDictionary:params];
}

#pragma mark - Private

- (NSMutableDictionary *)routes
{
    if (!_routes) {
        _routes = [[NSMutableDictionary alloc] init];
    }
    
    return _routes;
}

- (NSArray *)pathComponentsFromRoute:(NSString *)route
{
//    NSMutableArray *pathComponents = [NSMutableArray array];
//    NSURL *url = [NSURL URLWithString:[route stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//
//    for (NSString *pathComponent in url.path.pathComponents) {
//        if ([pathComponent isEqualToString:@"/"]) continue;
//        if ([[pathComponent substringToIndex:1] isEqualToString:@"?"]) break;
//        [pathComponents addObject:[pathComponent stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    }
//
//    return [pathComponents copy];
    
    NSMutableArray *pathComponents = [NSMutableArray array];
    for (NSString *pathComponent in route.pathComponents) {
        if ([pathComponent isEqualToString:@"/"]) continue;
        if ([[pathComponent substringToIndex:1] isEqualToString:@"?"]) break;
        [pathComponents addObject:pathComponent];
    }
    
    return [pathComponents copy];
}

- (NSString *)stringFromFilterAppUrlScheme:(NSString *)string
{
    // filter out the app URL compontents.
    for (NSString *appUrlScheme in [self appUrlSchemes]) {
        if ([string hasPrefix:[NSString stringWithFormat:@"%@:", appUrlScheme]]) {
            return [string substringFromIndex:appUrlScheme.length + 2];
        }
    }
    
    return string;
}

- (NSArray *)appUrlSchemes
{
    NSMutableArray *appUrlSchemes = [NSMutableArray array];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    for (NSDictionary *dic in infoDictionary[@"CFBundleURLTypes"]) {
        NSString *appUrlScheme = dic[@"CFBundleURLSchemes"][0];
        [appUrlSchemes addObject:appUrlScheme];
    }
    
    return [appUrlSchemes copy];
}

- (NSMutableDictionary *)subRoutesToRoute:(NSString *)route
{
    NSArray *pathComponents = [self pathComponentsFromRoute:route];
    
    NSInteger index = 0;
    NSMutableDictionary *subRoutes = (NSMutableDictionary*)self.routes;
    
    while (index < pathComponents.count) {
        NSString *pathComponent = pathComponents[index];
        if (![subRoutes objectForKey:pathComponent]) {
            subRoutes[pathComponent] = [[NSMutableDictionary alloc] init];
        }
        subRoutes = subRoutes[pathComponent];
        index++;
    }
    
    return subRoutes;
}

- (void)map:(NSString *)route toControllerClass:(Class)controllerClass
{
    NSMutableDictionary *subRoutes = [self subRoutesToRoute:route];
    
    subRoutes[@"_"] = controllerClass;
    
}

- (GVRouteType)canRoute:(NSString *)route
{
    NSDictionary *params = [self paramsInRoute:route];
    
    if (params[@"controller_class"]) {
        return GVRouteTypeViewController;
    }
    
    if (params[@"block"]) {
        return GVRouteTypeBlock;
    }
    
    return GVRouteTypeNone;
}


-(void)map:(NSString *)route toControllerClass:(Class)controllerClass nib:(NSString *)nibName bundle:(NSBundle *)bundle index:(NSUInteger)nibIndex
{
    GVRouterOption *option = [[GVRouterOption alloc] init];
    option.nib = nibName;
    option.nibIndex = nibIndex;
    option.bundle = bundle;
    [self map:route toControllerClass:controllerClass option:option];
    
}
-(void)map:(NSString *)route toControllerClass:(Class)controllerClass storyBoard:(NSString *)storyBoardName bundle:(NSBundle *)bundle identifier:(NSString *)identifier{
    GVRouterOption *option = [[GVRouterOption alloc] init];
    option.storyBoard = storyBoardName;
    option.identifier = identifier;
    option.bundle = bundle;
    [self map:route toControllerClass:controllerClass option:option];
}
- (void)map:(NSString *)route toControllerClass:(Class)controllerClass option:(GVRouterOption *)option
{
    NSMutableDictionary *subRoutes = [self subRoutesToRoute:route];
    subRoutes[@"_"] = controllerClass;
    subRoutes[@"#"] = option;
}
@end

@implementation GVRouterOption

-(void)setNib:(NSString *)nib
{
    _nib = nib;
    _type = InterfaceBuilderTypeXib;
}
-(void)setStoryBoard:(NSString *)storyBoard
{
    _storyBoard = storyBoard;
    _type = InterfaceBuilderTypeStoryBoard;
}


@end

#pragma mark - UIViewController Category

@implementation UIViewController (GVRouter)

static char kAssociatedParamsObjectKey;

- (void)setParams:(NSDictionary *)paramsDictionary
{
    objc_setAssociatedObject(self, &kAssociatedParamsObjectKey, paramsDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)params
{
    return objc_getAssociatedObject(self, &kAssociatedParamsObjectKey);
}

@end



