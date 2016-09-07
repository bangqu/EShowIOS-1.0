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

#import "GeTuiSdk.h"     // GetuiSdk头文件，需要使用的地方需要添加此代码
#import <AudioToolbox/AudioToolbox.h>//系统震动
/// 个推开发者网站中申请App时，注册的AppId、AppKey、AppSecret
#define kGtAppId           @"8UGpkIpo9P81RKeopgT7B9"
#define kGtAppKey          @"WKnc5Q0tXn8SFi0eS0GYy9"
#define kGtAppSecret       @"RZ99JsNCwX6jlOCaP9gWV8"
@interface AppDelegate ()<GeTuiSdkDelegate>{
    NSMutableArray *messageArr;//通知消息
}

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
    
    //个推
    // 通过个推平台分配的appId、 appKey 、appSecret 启动SDK，注：该方法需要在主线程中调用
    [GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret delegate:self];
    //[1-2]:设置是否后台运行开关
    [GeTuiSdk runBackgroundEnable:YES];
    //[1-3]:设置电子围栏功能，开启LBS定位服务 和 是否允许SDK 弹出用户定位请求
    [GeTuiSdk lbsLocationEnable:YES andUserVerify:YES];
    // 注册APNS
    [self registerUserNotification];
    // 绑定别名
    [GeTuiSdk bindAlias:@"王意"];
    messageArr = [NSMutableArray array];


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
/** 注册APNS */
- (void)registerUserNotification{
#ifdef __IPHONE_8_0
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        UIUserNotificationType types = (UIUserNotificationTypeAlert |
                                        UIUserNotificationTypeSound |
                                        UIUserNotificationTypeBadge);
        
        UIUserNotificationSettings *settings;
        settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
    } else {
        UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert |
                                                                       UIRemoteNotificationTypeSound |
                                                                       UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
    }
#else
    UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert |
                                                                   UIRemoteNotificationTypeSound |
                                                                   UIRemoteNotificationTypeBadge);
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
#endif
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
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"token----%@", token);
    
    //向个推服务器注册deviceToken
    [GeTuiSdk registerDeviceToken:token];
    //---------------//
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EMClient sharedClient] bindDeviceToken:deviceToken];
    });
}
/** SDK遇到错误回调 */
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    //个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    NSLog(@"\n>>>[GexinSdk error]:%@\n\n", [error localizedDescription]);
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    /// Background Fetch 恢复SDK 运行
    [GeTuiSdk resume];
    completionHandler(UIBackgroundFetchResultNewData);
}
/** SDK收到透传消息回调 */
- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId {
    //收到个推消息
    NSString *payloadMsg = nil;
    if (payloadData) {
        payloadMsg = [[NSString alloc] initWithBytes:payloadData.bytes
                                              length:payloadData.length
                                            encoding:NSUTF8StringEncoding];
    }
    //[[NSString alloc]initWithData:payloadData encoding:NSUTF8StringEncoding];
    [messageArr addObject:payloadMsg];
    NSLog(@"消息:%@", payloadMsg);
    NSUserDefaults *userd = [NSUserDefaults standardUserDefaults];
    [userd setObject:messageArr forKey:@"messageArray"];
    
    if ([[userd objectForKey:@"MusicRemind"] isEqualToString:@"NO"]) {
        //[userd setObject:@"YES" forKey:@"MusicRemind"];
    }else{
        AudioServicesPlaySystemSound(1007);
    }
    
    /**
     *汇报个推自定义事件
     *actionId：用户自定义的actionid，int类型，取值90001-90999。
     *taskId：下发任务的任务ID。
     *msgId： 下发任务的消息ID。
     *返回值：BOOL，YES表示该命令已经提交，NO表示该命令未提交成功。注：该结果不代表服务器收到该条命令
     **/
    NSLog(@"taskiD:%@",taskId);
    [GeTuiSdk sendFeedbackMessage:90001 andTaskId:taskId andMsgId:msgId];
}


/** APP已经接收到“远程”通知(推送) - 透传推送消息*/
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    // 处理APNs代码，通过userInfo可以取到推送的信息（包括内容，角标，自定义参数等）。如果需要弹窗等其他操作，则需要自行编码。
    NSLog(@"消息:%@",userInfo[@"aps"][@"alert"][@"body"]);
    
    NSUserDefaults *userd = [NSUserDefaults standardUserDefaults];
    [userd setObject:@"NO" forKey:@"MusicRemind"];
    completionHandler(UIBackgroundFetchResultNewData);
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
