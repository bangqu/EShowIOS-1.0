//
//  AppDelegate.h
//  EShowIOS
//
//  Created by 金璟 on 16/4/1.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentViewController.h"
#import "ApplyViewController.h"
@class JASidePanelController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, EMChatManagerDelegate>
{
    EMConnectionState _connectionState;
}
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) JASidePanelController *viewController;
@property (strong, nonatomic) ContentViewController *mainController;


- (void)setupTabViewController;
- (void)setupIntroductionViewController;

@end

