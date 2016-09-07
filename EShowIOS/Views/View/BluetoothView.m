//
//  BluetoothView.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/17.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import "BluetoothView.h"

@implementation BluetoothView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [[UIColor clearColor] setFill];
    UIRectFill(rect);
    NSInteger pulsingCount = 5;
    double animationDuration = 3;
    CALayer * animationLayer = [CALayer layer];
    for (int i = 0; i < pulsingCount; i++) {
        CALayer * pulsingLayer = [CALayer layer];
        pulsingLayer.frame = CGRectMake(0, 0, 80, 80);
        pulsingLayer.borderColor = [UIColor whiteColor].CGColor;
        pulsingLayer.borderWidth = 3;
        pulsingLayer.cornerRadius = 80 / 2;
        
        CAMediaTimingFunction * defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        
        CAAnimationGroup * animationGroup = [CAAnimationGroup animation];
        animationGroup.fillMode = kCAFillModeBackwards;
        animationGroup.beginTime = CACurrentMediaTime() + (double)i * animationDuration / (double)pulsingCount;
        animationGroup.duration = animationDuration;
        animationGroup.repeatCount = HUGE;
        animationGroup.timingFunction = defaultCurve;
        
        CABasicAnimation * scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = @1.4;
        scaleAnimation.toValue = @3.0;
        CAKeyframeAnimation * opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.values = @[@1, @0.9, @0.8, @0.7, @0.6, @0.5, @0.4, @0.3, @0.2, @0.1, @0];
        opacityAnimation.keyTimes = @[@0, @0.1, @0.2, @0.3, @0.4, @0.5, @0.6, @0.7, @0.8, @0.9, @1];
        
        animationGroup.animations = @[scaleAnimation, opacityAnimation];
        [pulsingLayer addAnimation:animationGroup forKey:@"plulsing"];
        [animationLayer addSublayer:pulsingLayer];
    }
    [self.layer addSublayer:animationLayer];
}
@end
