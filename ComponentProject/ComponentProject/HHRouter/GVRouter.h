//
//  GVRouter.h
//  GVRouterExample
//
//  Created by Gavin on 16/10/14.
//  Copyright © 2016年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, GVRouteType) {
    GVRouteTypeNone = 0,
    GVRouteTypeViewController = 1,
    GVRouteTypeBlock = 2
};
typedef NS_ENUM(NSUInteger) {
    
    InterfaceBuilderTypeXib = 0,
    InterfaceBuilderTypeStoryBoard
    
}InterfaceBuilderType;

@class GVRouterOption;

typedef id (^GVRouterBlock)(NSDictionary *params);

@interface GVRouter : NSObject

+ (instancetype)shared;

- (void)map:(NSString *)route toControllerClass:(Class)controllerClass;
- (UIViewController *)matchController:(NSString *)route;
- (void)map:(NSString *)route toBlock:(GVRouterBlock)block;
- (GVRouterBlock)matchBlock:(NSString *)route;
- (id)callBlock:(NSString *)route;

- (GVRouteType)canRoute:(NSString *)route;
/**
 *  注册rout 以xib方式初始化controller
 *
 *  @param route           url
 *  @param controllerClass controller 类名
 *  @param nibName         xib 文件名
 *  @param bundle          xib 所在的 bundle
 *  @param nibIndex        xib 中的index
 */
- (void)map:(NSString *)route toControllerClass:(Class)controllerClass nib:(NSString*)nibName bundle:(NSBundle*)bundle index:(NSUInteger)nibIndex;
/**
 *  注册rout 以StoryBoard方式初始化controller
 *
 *  @param route           url
 *  @param controllerClass controller 类名
 *  @param storyBoardName  storyBoard文件名
 *  @param bundle          storyBoard 所在的 bundle
 *  @param identifier      storyBoard中controller的identifier
 */
- (void)map:(NSString *)route toControllerClass:(Class)controllerClass storyBoard:(NSString*)storyBoardName bundle:(NSBundle *)bundle identifier:(NSString*)identifier;
/**
 *  注册rout 直接提供option
 *
 *  @param route           url
 *  @param controllerClass controller 类名
 *  @param option          option 实例
 */
- (void)map:(NSString *)route toControllerClass:(Class)controllerClass option:(GVRouterOption*)option;


@end

@interface  GVRouterOption: NSObject
@property(nonatomic,copy)NSString *storyBoard;// storyBoard文件名
@property(nonatomic,copy)NSString *nib; // xib 文件名
@property(nonatomic,assign)NSUInteger nibIndex; //xib 中的index
@property(nonatomic,strong)NSBundle *bundle; //xib 所在的 bundle
@property(nonatomic,copy)NSString *identifier; //storyBoard种controller的identifier

@property(nonatomic,assign)InterfaceBuilderType type; //类型
@end

@interface UIViewController (GVRouter)

@property (nonatomic, strong) NSDictionary *params;

@end


