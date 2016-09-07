//
//  AppDelegate.m
//  EShowIOS
//
//  Created by 金璟 on 16/4/1.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import "AppDelegate.h"
#import "RootTabViewController.h"
#import "ContentViewController.h"
#import "SideMenuViewController.h"
#import "IntroductionViewController.h"  //启动页
#import "JASidePanelController.h"
//UM
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"
#import "UMSocial.h"

#import <objc/runtime.h>
#import "AppDelegate+UMeng.h"
#import "AppDelegate+Parse.h"
#import "ChatDemoHelper.h"
#import "MBProgressHUD.h"
//高德
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "Pingpp.h"

@interface AppDelegate ()

@end
#define EaseMobAppKey @"daoqun#eshowios"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    _connectionState = EMConnectionConnected;
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    //设置友盟AppKey
    [UMSocialData setAppKey:@"56ceca68e0f55a2ece000d68"];
    //友盟第三方登录
    [UMSocialQQHandler setQQWithAppId:@"1105423356" appKey:@"TdaUYNbEZM2AHdEM" url:@"http://www.umeng.com/social"];
    [UMSocialWechatHandler setWXAppId:@"wxe0304d6eff6e6307" appSecret:@"7c769ad88fcd6dd6b4a6f7c2a8f5426e" url:@"http://www.umeng.com/social"];
    //gaode
    [AMapServices sharedServices].apiKey = @"f912d3064492b7d1102a9bc6de5b77c1";
    //ping++ debug模式
    [Pingpp setDebugMode:YES];
    
    [self customizeInterface];
    

    
//    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
//        [[UINavigationBar appearance] setBarTintColor:RGBACOLOR(30, 167, 252, 1)];
//        [[UINavigationBar appearance] setTitleTextAttributes:
//         [NSDictionary dictionaryWithObjectsAndKeys:RGBACOLOR(245, 245, 245, 1), NSForegroundColorAttributeName, [UIFont fontWithName:@ "HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]];
//    }
    [self setupUMeng];
    
    // 环信UIdemo中有用到Parse，您的项目中不需要添加，可忽略此处。
    [self parseApplication:application didFinishLaunchingWithOptions:launchOptions];
    
#warning 初始化环信SDK，详细内容在AppDelegate+EaseMob.m 文件中
#warning SDK注册 APNS文件的名字, 需要与后台上传证书时的名字一一对应
    NSString *apnsCertName = nil;
#if DEBUG
    apnsCertName = @"development";
#else
    apnsCertName = @"";
#endif
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *appkey = [ud stringForKey:@"identifier_appkey"];
    if (!appkey) {
        appkey = EaseMobAppKey;
        [ud setObject:appkey forKey:@"identifier_appkey"];
    }
    
    [self easemobApplication:application
didFinishLaunchingWithOptions:launchOptions
                      appkey:appkey
                apnsCertName:apnsCertName
                 otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];

    
    
    [self configAppLaunch];
    [self.window makeKeyAndVisible];
    
    
    //设置启动图时间
    [NSThread sleepForTimeInterval:1.0];

    return YES;
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (_mainController) {
        [_mainController jumpToChatList];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (_mainController) {
        [_mainController didReceiveLocalNotification:notification];
    }
}
- (void)easemobApplication:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
                    appkey:(NSString *)appkey
              apnsCertName:(NSString *)apnsCertName
               otherConfig:(NSDictionary *)otherConfig
{
    //注册登录状态监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStateChange:)
                                                 name:KNOTIFICATION_LOGINCHANGE
                                               object:nil];
    
    [[EaseSDKHelper shareHelper] hyphenateApplication:application
                        didFinishLaunchingWithOptions:launchOptions
                                               appkey:appkey
                                         apnsCertName:apnsCertName
                                          otherConfig:nil];
    
    [ChatDemoHelper shareHelper];
    
    BOOL isAutoLogin = [EMClient sharedClient].isAutoLogin;
    if (isAutoLogin){
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
    }
}
#pragma mark - App Delegate

// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EMClient sharedClient] bindDeviceToken:deviceToken];
    });
}

// 注册deviceToken失败，此处失败，与环信SDK无关，一般是您的环境配置或者证书配置有误
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.failToRegisterApns", Fail to register apns)
                                                    message:error.description
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)configAppLaunch
{
    // 作App配置
#if kSupportNetReachablity
//    [[NetworkUtility sharedNetworkUtility] startCheckWifi];
#endif
}
- (BOOL)needRedirectConsole
{
    return NO;
}
- (void)loginStateChange:(NSNotification *)notification
{
    //判断是否登录
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *isLogin = [userDefault objectForKey:@"user.username"];
    
    if (isLogin == nil) {
        NSLog(@"%@",isLogin);
        [self setupIntroductionViewController];
        [self clearParse];
    }else{
        [self setupTabViewController];
        [self initParse];
        [[ChatDemoHelper shareHelper] asyncGroupFromServer];
        [[ChatDemoHelper shareHelper] asyncConversationFromDB];
        [[ChatDemoHelper shareHelper] asyncPushOptions];
    }
}
#pragma mark - Methods Private
- (void)setupTabViewController{
    RootTabViewController *root_vc = [[RootTabViewController alloc] init];
    [self.window setRootViewController:root_vc];
}
- (void)setupIntroductionViewController{
    IntroductionViewController *introductionVC = [[IntroductionViewController alloc] init];
    [self.window setRootViewController:introductionVC];
}
- (void)customizeInterface {
    //设置Nav的背景色和title色
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    [navigationBarAppearance setBackgroundColor:[UIColor whiteColor]];
    [navigationBarAppearance setTintColor:[UIColor colorWithRed:(247 / 255.0f) green:(105 / 255.0f) blue:(86 / 255.0f) alpha:1]];//返回按钮的箭头颜色
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName: [UIFont boldSystemFontOfSize:kNavTitleFontSize],
                                     NSForegroundColorAttributeName: [UIColor colorWithRed:(247 / 255.0f) green:(105 / 255.0f) blue:(86 / 255.0f) alpha:1],
                                     };
    [navigationBarAppearance setTitleTextAttributes:textAttributes];
}
// 打印收到的apns信息
-(void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo
                                                        options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *str =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.content", @"Apns content")
                                                    message:str
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
    
}
#pragma umSocial
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [UMSocialSnsService handleOpenURL:url];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return  [UMSocialSnsService handleOpenURL:url];
}

@end
