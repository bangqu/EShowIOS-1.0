//
//  AudioPlayerController+methods.m
//  AudioPlayer
//
//  Created by ClaudeLi on 16/4/1.
//  Copyright © 2016年 王迎军. All rights reserved.
//

#import "AudioPlayerViewController+methods.h"

@implementation AudioPlayerViewController (methods)

- (void)creatViews{
    self.rotatingView = [[MusicView alloc] init];
    self.rotatingView.imageView.image = [UIImage imageNamed:@"音乐_播放器_默认唱片头像"];
    [self.view addSubview:self.rotatingView];
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.HUD.mode = MBProgressHUDModeText;
    self.HUD.userInteractionEnabled = NO;
    [self.view addSubview:self.HUD];
}

- (void)progressHUDWith:(NSString *)string{
    self.HUD.label.text = string;
    [self.HUD showAnimated:YES];
    [self.HUD hideAnimated:YES afterDelay:2.0f];
}

- (void)setRotatingViewFrame{
    CGFloat height_i4 = ScreenHeight - topHeight - downHeight;
    if (ScreenHeight < 500) {
        self.rotatingView.frame = CGRectMake(0, 0, height_i4*0.8, height_i4*0.8);
    }else{
        self.rotatingView.frame = CGRectMake(0, 0, ScreenWidth *0.8, ScreenWidth*0.8);
    }
    self.rotatingView.center = CGPointMake(ScreenWidth/2, height_i4/2 + topHeight);
    [self.rotatingView setRotatingViewLayoutWithFrame:self.rotatingView.frame];
}


- (void)setImageWith:(MusicModel *)model{
    /**
     *  添加旋转动画
     */
    [self.rotatingView addAnimation];
    self.underImageView.image = [UIImage imageNamed:@"音乐_播放器_默认模糊背景"];
    [self.rotatingView.imageView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"音乐_播放器_默认唱片头像"] completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            self.underImageView.image = [image applyDarkEffect];
        }
    }];
}

@end
