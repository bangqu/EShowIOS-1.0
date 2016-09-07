//
//  MusicView.h
//  EShowIOS
//
//  Created by 王迎军 on 16/8/19.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicView : UIView
@property (nonatomic, strong) UIImageView *imageView;

- (void)setRotatingViewLayoutWithFrame:(CGRect)frame;

// 添加动画
- (void)addAnimation;
// 停止
-(void)pauseLayer;
// 恢复
-(void)resumeLayer;
// 移除动画
- (void)removeAnimation;
@end
