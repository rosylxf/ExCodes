//
//  ZGPopUpView.m
//  ZGPopUpView
//
//  Created by Zong on 16/1/28.
//  Copyright © 2016年 Zong. All rights reserved.
//

#import "ZGPopUpView.h"



static CGFloat contentViewLeftInset = 10;
static CGFloat contentViewTopInset = 10;
static CGFloat arrowRadius = 15;
static CGFloat cornerRadius = 10;
static CGFloat rightExtendDistance = 10;
static CGFloat popUpViewInset = 3;

static ZGPopUpView *_popUpView_;

@implementation ZGContentView

- (void)setSize:(CGSize)size
{
    _size = size;
    
    // 设置contentView frame
    ZGPopUpView *popUpView = (ZGPopUpView *)self.superview;
    ZGPopUpViewArrowDirection arrowDirection =  [[popUpView valueForKeyPath:@"arrowDirection"] integerValue];
    if (arrowDirection == ZGPopUpViewArrowDirectionUp) {
        self.frame = CGRectMake(contentViewLeftInset + popUpViewInset, arrowRadius + contentViewTopInset, size.width, size.height);
    }else if(arrowDirection == ZGPopUpViewArrowDirectionDown ){
        self.frame = CGRectMake(contentViewLeftInset + popUpViewInset, popUpViewInset + contentViewTopInset, size.width, size.height);
    }
}

@end

@interface ZGPopUpView ()

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, weak) UIView *popUpView;

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, assign) CGPoint arrowPoint;

@property (nonatomic, assign) ZGPopUpViewArrowDirection arrowDirection;

@end

@implementation ZGPopUpView

+ (void)showMessage:(NSString *)message attributes:(NSDictionary *)attributes inView:(UIView *)view rect:(CGRect)rect
{

    if (message.length > 0) {
        
        if (_popUpView_.window) return;

        /** 以下，是使用ZGPopUpView最基本步骤
         *  当然你还可以在此基础上再设置popUpView的各种属性，达到你要的效果
        */
        /** 特别注意，创建时,可以指定箭头指向的方向：向上或向下
         *  创建时候不指定箭头指向，默认是向上
         * ZGPopUpView *popUpView = [[self alloc] initWithArrowDirection:ZGPopUpViewArrowDirectionDown];
         */
        ZGPopUpView *popUpView = [[self alloc] init];
        
        [popUpView showMessage:message attributes:attributes inView:view rect:rect];
    }
    
}

- (void)showMessage:(NSString *)message attributes:(NSDictionary *)attributes inView:(UIView *)view rect:(CGRect)rect
{
    if (message.length > 0) {
        
        if (_popUpView_.window) return;
        
        if (rect.origin.y+rect.size.height/2 < view.frame.size.height/2) {
            self.arrowDirection = ZGPopUpViewArrowDirectionUp;
        }else{
            self.arrowDirection = ZGPopUpViewArrowDirectionDown;
        }
        
        UIColor *textColor = nil;
        UIFont *textFont = nil;
        if (attributes) {
            textColor = (UIColor *)attributes[NSForegroundColorAttributeName];
            textFont = (UIFont *)attributes[NSFontAttributeName];
        }
        textFont = textFont ? textFont : self.defaultFont;
        // 算出传入文字rect
        CGRect textRect = [message boundingRectWithSize:CGSizeMake(300, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : textFont} context:nil];
        
        CGSize contentViewSize = textRect.size;
        
        // 设置label 属性
        UILabel *messageLabel = [[UILabel alloc] init];
        messageLabel.numberOfLines = 0;
        messageLabel.text = message;
        messageLabel.frame = textRect;
        if (textColor) {
            messageLabel.textColor = textColor;
        }
        messageLabel.font = textFont;
        
        // 把内容控件添加到容器视图，在这里要显示的内容是文字Label，但也可以是其他任何控件
        [self.contentView addSubview:messageLabel];
        
        // 设置contentView的size
        self.contentView.size = contentViewSize;
        
        // 调用showInView:rect:
        [self showInView:view rect:rect];
    }
}

- (void)showInView:(UIView *)view rect:(CGRect)rect
{
    if (self.window) return;
    
    _popUpView_ = self;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(popUpViewWillShow:)]) {
        [self.delegate popUpViewWillShow:self];
    }
    CGRect popUpViewFrame = [self popUpViewFrameWithView:view rect:rect];
    
    switch (self.showAnimationType) {
        case ZGPopUpViewShowAnimationTypeDefault:{
//            self.frame = CGRectMake(self.arrowPoint.x, self.arrowPoint.y, 0.01, 0.01);
            CGPoint startPoint = CGPointMake(popUpViewFrame.size.width - arrowRadius - rightExtendDistance - cornerRadius - popUpViewInset, 0);
            self.frame = popUpViewFrame;
            CGFloat anchorPointY = 0;
            if (self.arrowDirection == ZGPopUpViewArrowDirectionDown) {
                anchorPointY = 1;
            }
            self.layer.anchorPoint = CGPointMake(startPoint.x / self.frame.size.width, anchorPointY);
            self.frame = popUpViewFrame;

            self.transform = CGAffineTransformScale(self.transform, 0.1, 0.1);
            [UIView animateWithDuration:0.25 animations:^{
                //                self.frame = popUpViewFrame;
                self.transform = CGAffineTransformScale(self.transform, 10, 10);
                self.frame = popUpViewFrame;
            }completion:^(BOOL finished) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(popUpViewDidShow:)]) {
                    [self.delegate popUpViewDidShow:self];
                }
            }];
            break;
        }
        case ZGPopUpViewShowAnimationTypeAlpha:{
            self.frame = popUpViewFrame;
            self.alpha = 0;
            [UIView animateWithDuration:0.25 animations:^{
                self.alpha = 1.0;
            }completion:^(BOOL finished) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(popUpViewDidShow:)]) {
                    [self.delegate popUpViewDidShow:self];
                }
            }];
            break;
        }
        default:
            break;
    }
}


- (CGRect)popUpViewFrameWithView:(UIView *)view rect:(CGRect)rect
{
    CGFloat popUpViewWidth = self.contentView.frame.size.width + 2*(contentViewLeftInset +popUpViewInset);
    CGFloat popUpViewHeight = self.contentView.frame.size.height + arrowRadius + 2 * (contentViewTopInset) + popUpViewInset;
    
    CGFloat arrowPointX = rect.origin.x + rect.size.width * 0.5;
    CGFloat arrowPointY = 0.0;
    CGFloat popUpViewY = 0.0;
    if (self.arrowDirection == ZGPopUpViewArrowDirectionUp) {
        arrowPointY = rect.origin.y + rect.size.height;
        popUpViewY = arrowPointY;
    }else if(self.arrowDirection == ZGPopUpViewArrowDirectionDown){
        arrowPointY = rect.origin.y;
        popUpViewY = arrowPointY - popUpViewHeight;
    }
    
    CGPoint arrowPoint = CGPointMake(arrowPointX, arrowPointY);

    // rightExtendDistance
    CGFloat rightSpace = view.bounds.size.width - arrowPoint.x;
    if (rightSpace == view.bounds.size.width / 2.0) {
        rightExtendDistance = (popUpViewWidth - 2 * (arrowRadius + cornerRadius)) / 2.0;
    }else if (rightSpace > view.bounds.size.width / 2.0){
        rightExtendDistance = popUpViewWidth - 2 * (arrowRadius + cornerRadius) - 20;
        if (rightSpace < rightExtendDistance) {
            rightExtendDistance = rightSpace - arrowRadius - cornerRadius - 10;
        }
    }else {
        rightExtendDistance = 10;
        if (rightSpace > rightExtendDistance) {
            rightExtendDistance = rightSpace - arrowRadius - cornerRadius - 10;
        }
    }
    
    CGRect popUpViewFrame = CGRectMake(arrowPoint.x - (popUpViewWidth - arrowRadius - rightExtendDistance - cornerRadius  - popUpViewInset) , popUpViewY, popUpViewWidth, popUpViewHeight);
    
    
    self.arrowPoint = arrowPoint;
    self.maskView.frame = view.bounds;
    [view addSubview:self.maskView];
    [view addSubview:self];
    
    return popUpViewFrame;
}

+ (UIFont *)defaultFont
{
    return [UIFont systemFontOfSize:15];
}

- (UIFont *)defaultFont
{
    return [UIFont systemFontOfSize:15];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initialize];
}

- (instancetype)initWithArrowDirection:(ZGPopUpViewArrowDirection)arrowDirection
{
    if (self = [super init]) {
        self.arrowDirection = arrowDirection;
    }
    return self;
}

- (void)initialize
{
    ZGContentView *contentView = [[ZGContentView alloc] init];
    [self addSubview:contentView];
    self.contentView = contentView;
    contentView.frame = self.bounds;
    self.backgroundColor = [UIColor clearColor];
//    self.clipsToBounds = YES;
    self.opaque = NO;
    
    self.popUpViewBackgroundColor = [UIColor whiteColor];

}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {

    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetRGBStrokeColor(context,1,0,0,1);
    UIColor *strokeColor = [UIColor redColor];
    if (self.borderColor) {
        strokeColor = self.borderColor;
    }
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGSize  rectSize = CGSizeMake(rect.size.width - 2*popUpViewInset, rect.size.height -arrowRadius - popUpViewInset);
    
    CGFloat leftExtendDistance = rectSize.width  - rightExtendDistance - 2*(cornerRadius + arrowRadius);
    CGSize arrowSize = CGSizeMake(arrowRadius, arrowRadius);
    
    if (self.arrowDirection == ZGPopUpViewArrowDirectionUp) {
        
        CGPoint startPoint = CGPointMake((rectSize.width + 2*popUpViewInset) - arrowRadius - rightExtendDistance - cornerRadius - popUpViewInset, 0);
        CGPoint leftEndPoint = CGPointMake(startPoint.x - arrowSize.width, startPoint.y + arrowSize.height);
        
        
        // 箭头左边弧线
        CGContextMoveToPoint(context,startPoint.x,startPoint.y);//圆弧的起始点
        CGContextAddArcToPoint(context, startPoint.x, leftEndPoint.y, leftEndPoint.x, leftEndPoint.y, arrowRadius);
        
        // 向左延伸直线
        CGContextAddLineToPoint(context, leftEndPoint.x - leftExtendDistance, leftEndPoint.y);
        
        CGPoint leftCornerPoint = CGPointMake(leftEndPoint.x - leftExtendDistance - cornerRadius, leftEndPoint.y);
        // 矩形左上角圆弧corner
        CGContextAddArcToPoint(context, leftCornerPoint.x, leftCornerPoint.y, leftCornerPoint.x, leftCornerPoint.y + cornerRadius, cornerRadius);
        
        // 矩形左边向下延伸
        CGContextAddLineToPoint(context, leftCornerPoint.x, leftCornerPoint.y + cornerRadius + (rectSize.height - 2*cornerRadius));
        
        // 矩形左下角corner
        CGContextAddArcToPoint(context, leftCornerPoint.x, leftCornerPoint.y + rectSize.height, leftCornerPoint.x + cornerRadius, leftCornerPoint.y + rectSize.height, cornerRadius);
        
        
        
        CGPoint rightCornerPoint = CGPointMake(startPoint.x + arrowRadius + rightExtendDistance + cornerRadius, leftCornerPoint.y);
        
        // 延伸矩形底边
        CGContextAddLineToPoint(context, rightCornerPoint.x - cornerRadius, rightCornerPoint.y + rectSize.height);
        
        // 矩形右下角
        CGContextAddArcToPoint(context, rightCornerPoint.x, rightCornerPoint.y + rectSize.height, rightCornerPoint.x, rightCornerPoint.y + rectSize.height - cornerRadius, cornerRadius);
        
        // 延伸矩形右边线
        CGContextAddLineToPoint(context, rightCornerPoint.x, rightCornerPoint.y + cornerRadius);
        
        // 矩形右上角
        CGContextAddArcToPoint(context, rightCornerPoint.x, rightCornerPoint.y, rightCornerPoint.x - cornerRadius, rightCornerPoint.y, cornerRadius);
        
        // 延伸arrow右边延伸
        CGContextAddLineToPoint(context, rightCornerPoint.x - cornerRadius - rightExtendDistance, rightCornerPoint.y);
        
        // arrow右边弧形
        CGContextAddArcToPoint(context, startPoint.x , rightCornerPoint.y, startPoint.x, startPoint.y, arrowRadius);
        
    }else if (self.arrowDirection == ZGPopUpViewArrowDirectionDown){
        
        CGPoint startPoint = CGPointMake((rectSize.width + 2*popUpViewInset) - arrowRadius - rightExtendDistance - cornerRadius - popUpViewInset, rectSize.height + arrowRadius + popUpViewInset);
        CGPoint leftEndPoint = CGPointMake(startPoint.x - arrowSize.width, startPoint.y - arrowSize.height);
        
        // 箭头左边弧线
        CGContextMoveToPoint(context,startPoint.x,startPoint.y);//圆弧的起始点
        CGContextAddArcToPoint(context, startPoint.x, leftEndPoint.y, leftEndPoint.x, leftEndPoint.y, arrowRadius);
        
        // 向左延伸直线
        CGContextAddLineToPoint(context, leftEndPoint.x - leftExtendDistance, leftEndPoint.y);
        
        CGPoint leftCornerPoint = CGPointMake(leftEndPoint.x - leftExtendDistance - cornerRadius, leftEndPoint.y);
        // 矩形左下角圆弧corner
        CGContextAddArcToPoint(context, leftCornerPoint.x, leftCornerPoint.y, leftCornerPoint.x, leftCornerPoint.y - cornerRadius, cornerRadius);
        
        // 矩形左边向上延伸
        CGContextAddLineToPoint(context, leftCornerPoint.x, leftCornerPoint.y - cornerRadius - (rectSize.height - 2*cornerRadius));
        
        // 矩形左上角corner
        CGContextAddArcToPoint(context, leftCornerPoint.x, leftCornerPoint.y - rectSize.height, leftCornerPoint.x + cornerRadius, leftCornerPoint.y - rectSize.height, cornerRadius);
        
        
        
        CGPoint rightCornerPoint = CGPointMake(startPoint.x + arrowRadius + rightExtendDistance + cornerRadius, leftCornerPoint.y);
        
        // 延伸矩形底部边线
        CGContextAddLineToPoint(context, rightCornerPoint.x - cornerRadius, rightCornerPoint.y - rectSize.height);
        
        // 矩形右上角
        CGContextAddArcToPoint(context, rightCornerPoint.x, rightCornerPoint.y - rectSize.height, rightCornerPoint.x, rightCornerPoint.y - rectSize.height + cornerRadius, cornerRadius);
        
        // 延伸矩形右边线
        CGContextAddLineToPoint(context, rightCornerPoint.x, rightCornerPoint.y - cornerRadius);
        
        // 矩形右下角
        CGContextAddArcToPoint(context, rightCornerPoint.x, rightCornerPoint.y, rightCornerPoint.x - cornerRadius, rightCornerPoint.y, cornerRadius);
        
        // 延伸arrow右边延伸
        CGContextAddLineToPoint(context, rightCornerPoint.x - cornerRadius - rightExtendDistance, rightCornerPoint.y);
        
        // arrow右边弧形
        CGContextAddArcToPoint(context, startPoint.x , rightCornerPoint.y, startPoint.x, startPoint.y, arrowRadius);
        
    }
    
    // 封闭矩形
    CGContextClosePath(context);
    
//    CGContextClip(context);
//    CGContextStrokePath(context);
    UIColor *bgColor = [UIColor blackColor];
    if (self.popUpViewBackgroundColor) {
        bgColor = self.popUpViewBackgroundColor;
    }
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    CGContextDrawPath(context, kCGPathEOFillStroke);
    
}


#pragma mark - dismiss
+ (void)dismiss
{
    [_popUpView_ dismiss];
}

- (void)dismiss
{
    if (self.window) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(popUpViewWillDismiss:)]) {
            [self.delegate popUpViewWillDismiss:self];
        }
        switch (self.showAnimationType) {
            case ZGPopUpViewShowAnimationTypeDefault:{

                [UIView animateWithDuration:0.25 animations:^(void)
                 {
//                     self.frame = CGRectMake(self.arrowPoint.x, self.arrowPoint.y, 0.01, 0.01);
                     self.transform = CGAffineTransformScale(self.transform, 0.1, 0.1);
                 }completion:^(BOOL finish)
                 {
                     [self.maskView removeFromSuperview];
                     [self removeFromSuperview];
                     if (self.delegate && [self.delegate respondsToSelector:@selector(popUpViewDidDismissed:)]) {
                         [self.delegate popUpViewDidDismissed:self];
                     }
                 }];
                break;
            }
            case ZGPopUpViewShowAnimationTypeAlpha:{
                
                [UIView animateWithDuration:0.25 animations:^{
                    self.alpha = 0;
                } completion:^(BOOL finished) {
                    [self.maskView removeFromSuperview];
                    [self removeFromSuperview];
                    if (self.delegate && [self.delegate respondsToSelector:@selector(popUpViewDidDismissed:)]) {
                        [self.delegate popUpViewDidDismissed:self];
                    }
                }];
                break;
            }
                
            default:
                break;
        }
        
        
    }
    
    
}


#pragma mark - tapMaskView
- (void)tapMaskView:(UITapGestureRecognizer *)tagGesture
{
    [self dismiss];
}

#pragma mark - lazyLoad
- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        UIColor *maskViewBGColor = [UIColor blackColor];
        if (self.maskViewBackgroundColor) {
            maskViewBGColor = self.maskViewBackgroundColor;
        }
        switch (self.popUpViewMaskStyle) {
            case ZGPopUpViewMaskStyleTranslucent:
                _maskView.backgroundColor = [maskViewBGColor colorWithAlphaComponent:0.5];
                break;
                
            case ZGPopUpViewMaskStyleOpaque:
                _maskView.backgroundColor = maskViewBGColor;
                break;
                
            case ZGPopUpViewMaskStyleNone:
                _maskView.hidden = YES;
                break;
                
            default:
                break;
        }
        
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMaskView:)];
        [_maskView addGestureRecognizer:tapGesture];
        
    }
    return _maskView;
}

@end
