//
//  AudioPlayerViewController.h
//  EShowIOS
//
//  Created by 王迎军 on 16/8/19.
//  Copyright © 2016年 王迎军. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MusicModel.h"
#import "UIImage+ImageEffects.h" // 模糊效果
#import "MusicView.h"   // 旋转View
static CGFloat topHeight = 64.0+20.0;
static CGFloat downHeight = 100.0+16.0;
/**
 *  AudioPlayerMode 播放模式
 */
typedef NS_ENUM(NSInteger, AudioPlayerMode) {
    /**
     *  顺序播放
     */
    AudioPlayerModeOrderPlay,
    /**
     *  随机播放
     */
    AudioPlayerModeRandomPlay,
    /**
     *  单曲循环
     */
    AudioPlayerModeSinglePlay,
};
@interface AudioPlayerViewController : UIViewController


+(AudioPlayerViewController *)audioPlayerController;

/**
 *  旋转View
 */
@property (strong, nonatomic) MusicView *rotatingView;
/**
 *  背景模糊图
 */
@property (strong, nonatomic) UIImageView *underImageView;
/**
 *  第三方提示MBProgressHUD
 */
@property (strong, nonatomic) MBProgressHUD *HUD;

/**
 *  播放器数据传入
 *
 *  @param array 传入所有数据model数组
 *  @param index 传入当前model在数组的下标
 */
- (void)initWithArray:(NSArray *)array index:(NSInteger)index;

/**
 *  开始播放
 */
- (void)play;

/**
 *  暂停播放
 */
- (void)stop;

/**
 *  播放/暂停按钮点击事件执行的方法
 */
- (void)playerStatus;

/**
 *  上一曲
 */
- (void)inASong;

/**
 *  下一曲
 */
- (void)theNextSong;
@end
