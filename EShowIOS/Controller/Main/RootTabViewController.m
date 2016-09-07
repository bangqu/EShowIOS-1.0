//
//  RootTabViewController.m
//  EShowIOS
//
//  Created by 金璟 on 16/4/19.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import "RootTabViewController.h"
#import "ContentViewController.h"
#import "SideMenuViewController.h"
#import "AudioPlayerViewController.h"
@interface RootTabViewController ()

@end

@implementation RootTabViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViewControllers];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}
- (BOOL) canBecomeFirstResponder {
    return YES;
}
- (void) remoteControlReceivedWithEvent:(UIEvent *) receivedEvent{
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlPause:
                //点击了暂停
                [[AudioPlayerViewController audioPlayerController] playerStatus];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                //点击了下一首
                [[AudioPlayerViewController audioPlayerController] theNextSong];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                //点击了上一首
                [[AudioPlayerViewController audioPlayerController] inASong];
                break;
            case UIEventSubtypeRemoteControlPlay:
                //点击了播放
                [[AudioPlayerViewController audioPlayerController] playerStatus];
                break;
            default:
                break;
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupViewControllers {
    
    self.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[ContentViewController alloc]init]];
    self.leftPanel = [[SideMenuViewController alloc] init];
    
}

@end
