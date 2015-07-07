//
//  HamburgerButton.m
//  HamburgerButton
//
//  Created by Danis on 14/11/15.
//  Copyright (c) 2014年 danis. All rights reserved.
//

#import "HamburgerButton.h"

#pragma mark - CALayer Extension

@interface CALayer (Helper)

-(void)lld_applyAnimation:(CABasicAnimation *)animation;

@end

@implementation CALayer (Helper)

-(void)lld_applyAnimation:(CABasicAnimation *)animation{
    if (animation.fromValue == nil) {
        animation.fromValue = [[self presentationLayer] valueForKeyPath:animation.keyPath];
    }
    [self addAnimation:animation forKey:animation.keyPath];
    [self setValue:animation.toValue forKeyPath:animation.keyPath];
}

@end

static const CGFloat menuStrokeStart = 0.325;
static const CGFloat menuStrokeEnd = 0.9;
static const CGFloat hamburgerStrokeStart = 0.028;
static const CGFloat hamburgerStrokeEnd = 0.111;


@interface HamburgerButton (){
    CGMutablePathRef _shortStroke;
    CGMutablePathRef _outline;
    
}

@property (strong, nonatomic) CAShapeLayer *top;
@property (strong, nonatomic) CAShapeLayer *bottom;
@property (strong, nonatomic) CAShapeLayer *middle;

@end

@implementation HamburgerButton

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _shortStroke = CGPathCreateMutable();
        CGPathMoveToPoint(_shortStroke, nil, 2, 2);
        CGPathAddLineToPoint(_shortStroke, nil, 28, 2);
        
        _outline = CGPathCreateMutable();
        CGPathMoveToPoint(_outline, nil, 10, 27);
        CGPathAddCurveToPoint(_outline, nil, 12.00, 27.00, 28.02, 27.00, 40, 27);
        CGPathAddCurveToPoint(_outline, nil, 55.92, 27.00, 50.47,  2.00, 27,  2);
        CGPathAddCurveToPoint(_outline, nil, 13.16,  2.00,  2.00, 13.16,  2, 27);
        CGPathAddCurveToPoint(_outline, nil,  2.00, 40.84, 13.16, 52.00, 27, 52);
        CGPathAddCurveToPoint(_outline, nil, 40.84, 52.00, 52.00, 40.84, 52, 27);
        CGPathAddCurveToPoint(_outline, nil, 52.00, 13.16, 42.39,  2.00, 27,  2);
        CGPathAddCurveToPoint(_outline, nil, 13.16,  2.00,  2.00, 13.16,  2, 27);
        
        self.top = [[CAShapeLayer alloc]init];
        self.middle = [[CAShapeLayer alloc]init];
        self.bottom = [[CAShapeLayer alloc]init];
        
        self.top.path = _shortStroke;
        self.bottom.path = _shortStroke;
        self.middle.path = _outline;
        
        NSArray *arr = [NSArray arrayWithObjects:self.top,self.middle,self.bottom, nil];
        for (CAShapeLayer *layer in arr) {
            layer.fillColor = nil;
            layer.strokeColor = [UIColor whiteColor].CGColor;
            layer.lineWidth = 4;
            layer.miterLimit = 4;
            layer.lineCap = kCALineCapRound;
            layer.masksToBounds = true;
            
            CGPathRef strokingPath = CGPathCreateCopyByStrokingPath(layer.path, nil, 4, kCGLineCapRound, kCGLineJoinMiter, 4);
            layer.bounds = CGPathGetPathBoundingBox(strokingPath);
            
            layer.actions = @{@"strokeStart": [NSNull null],
                              @"strokeEnd":[NSNull null],
                              @"tranform":[NSNull null]};
            [self.layer addSublayer:layer];
        }
        self.top.anchorPoint = CGPointMake(28.0 / 30.0, 0.5);   //比例
        self.top.position = CGPointMake(40, 18);
        
        self.middle.position = CGPointMake(27, 27);
        self.middle.strokeStart = hamburgerStrokeStart; //从哪开始绘制路径 0.0~1.0 默认为0.0
        self.middle.strokeEnd = hamburgerStrokeEnd;     //从哪结束绘制路径 0.0~1.0 默认为1.0
        
        self.bottom.anchorPoint = CGPointMake(28.0 / 30.0, 0.5);
        self.bottom.position = CGPointMake(40, 36);
    }
    return self;
}

-(void)setShowMenu:(BOOL)showMenu{
    _showMenu = showMenu;
    
    CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    
    //为中间那根条进行的动画,分别对start和end两端的端点进行动画,也就是为start和end两个端点描述其运行的路径，然后分别让其运动
    if (showMenu) {
        strokeStartAnimation.toValue = [NSNumber numberWithFloat:menuStrokeStart];
        strokeStartAnimation.duration = .5;
        strokeStartAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.25 :0.4 :0.5 :1];
        
        strokeEndAnimation.toValue = [NSNumber numberWithFloat:menuStrokeEnd];
        strokeEndAnimation.duration = .6;
        strokeEndAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.25 :-0.4 :0.5 :1];
    }else{
        strokeStartAnimation.toValue = [NSNumber numberWithFloat:hamburgerStrokeStart];
        strokeStartAnimation.duration = .5;
        strokeStartAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.25 :0 :0.5 :1.2];
        strokeStartAnimation.beginTime = CACurrentMediaTime() + 0.1;
        strokeStartAnimation.fillMode = kCAFillModeBackwards;
        
        strokeEndAnimation.toValue = [NSNumber numberWithFloat:hamburgerStrokeEnd];
        strokeEndAnimation.duration = .6;
        strokeEndAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.25 :0.3 :0.5 :0.6];
    }
    [self.middle lld_applyAnimation:strokeStartAnimation];
    [self.middle lld_applyAnimation:strokeEndAnimation];
    
    CABasicAnimation *topTransformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    topTransformAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.5 :-0.8 :.5 :1.85];
    topTransformAnimation.duration = .4;
    topTransformAnimation.fillMode = kCAFillModeBackwards;
    
    CABasicAnimation *bottomTransformAnimation = [topTransformAnimation copy];
    if (showMenu) {
        CATransform3D translation = CATransform3DMakeTranslation(-4, 0, 0);
        //变换的叠加
        topTransformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(translation, -0.785375, 0, 0, 1)];
        topTransformAnimation.beginTime = CACurrentMediaTime() + 0.25;
        
        bottomTransformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(translation, 0.785375, 0, 0, 1)];
        bottomTransformAnimation.beginTime = CACurrentMediaTime() + 0.25;
    }else{
        topTransformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        topTransformAnimation.beginTime = CACurrentMediaTime() + 0.05;
        
        bottomTransformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        bottomTransformAnimation.beginTime = CACurrentMediaTime() + 0.05;
    }
    
    [self.top lld_applyAnimation:topTransformAnimation];
    [self.bottom lld_applyAnimation:bottomTransformAnimation];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
