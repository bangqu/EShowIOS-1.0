//
//  ContentViewController.m
//  EShowIOS
//
//  Created by 金璟 on 16/4/1.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import "ContentViewController.h"
#import "PopMenu.h"
#import "FRDLivelyButton.h"
#import "NetworkEngine.h"
#import "ImageListModel.h"
#import "MJExtension.h"
#import "MBProgressHUD.h"
#import "SDAutoLayout.h"
#import "LoginViewController.h"
#import "SigleLocationViewController.h"//地图
#import "PingPayWebViewController.h"//支付
#import "ShareViewController.h"//分享
#import "ScannerViewController.h" //扫一扫
#import "AddressPickerViewController.h"//城市选择
#import "PersonalInformationViewController.h"//个人信息页面
#import "ImageListViewController.h"//图片列表
#import "BluetoothViewController.h"//蓝牙
#import "MusicListViewController.h"//音乐播放
#import "DownloadViewController.h"//文件下载
#import "NewTaskViewController.h"//系统消息
#import "NewTweetViewController.h"//透传消息
#import "GeTuiSdk.h"//个推
#import <AudioToolbox/AudioToolbox.h>//系统声音
//#import "ContectViewController.h" //通讯录
#import "ConversationListController.h" //聊天列表
#import "ContactListViewController.h"
#import "ChatViewController.h"  //
#import "ApplyViewController.h"
#import "ChatDemoHelper.h"
#import "UserProfileManager.h"
/// 个推开发者网站中申请App时，注册的AppId、AppKey、AppSecret
#define kGtAppId           @"8UGpkIpo9P81RKeopgT7B9"
#define kGtAppKey          @"WKnc5Q0tXn8SFi0eS0GYy9"
#define kGtAppSecret       @"RZ99JsNCwX6jlOCaP9gWV8"
//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;
static NSString *kMessageType = @"MessageType";
static NSString *kConversationChatter = @"ConversationChatter";
static NSString *kGroupName = @"GroupName";

#if DEMO_CALL == 1
@interface ContentViewController () <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,EMCallManagerDelegate,GeTuiSdkDelegate>
#else
@interface ContentViewController () <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,GeTuiSdkDelegate>
#endif
{
    ConversationListController *_chatListVC;
    ContactListViewController *_contactsVC;
    NSInteger messageNum;//消息数
    NSMutableArray *messageArr;//通知消息
    BOOL isShowMessage;//是否在显示消息界面
}
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) UIImageView *imageLogo;
@property (nonatomic, strong) UISearchBar *mySearchBar;
@property (nonatomic, strong) PopMenu *myPopMenu;
@property (nonatomic, strong) FRDLivelyButton *rightNavBtn;
@property (strong, nonatomic) NSDate *lastPlaySoundDate;
@end

@implementation ContentViewController

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
    self.title = @"首页";
    self.view.backgroundColor = [UIColor whiteColor];
    [self createData];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    _myTableView = [UITableView new];
    _myTableView.backgroundColor = [UIColor whiteColor];
    _myTableView.dataSource = self;
    _myTableView.delegate = self;
    [self.view addSubview:_myTableView];
    _myTableView.sd_layout.leftEqualToView(self.view).rightEqualToView(self.view).topEqualToView(self.view).bottomEqualToView(self.view);
//    //初始化弹出菜单
//    NSArray *menuItems = @[
//                           [MenuItem itemWithTitle:@"扫一扫" iconName:@"ic_saoma" index:0],
//                           [MenuItem itemWithTitle:@"系统信息" iconName:@"ic_system" index:1],
//                           [MenuItem itemWithTitle:@"透传信息" iconName:@"ic_touchuan" index:2],
//                           ];
//    if (!_myPopMenu) {
//        _myPopMenu = [[PopMenu alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64) items:menuItems];
//        _myPopMenu.perRowItemCount = 3;
//        _myPopMenu.menuAnimationType = kPopMenuAnimationTypeSina;
//    }
//    __weak typeof(self) weakSelf = self;
//    @weakify(self);
//    _myPopMenu.didSelectedItemCompletion = ^(MenuItem *selectedItem){
//        [weakSelf.myPopMenu.realTimeBlurFooter disMiss];
//        @strongify(self);
//        //改下显示style
//        [self.rightNavBtn setStyle:kFRDLivelyButtonStylePlus animated:YES];
//        if (!selectedItem) return;
//        switch (selectedItem.index) {
//            case 0:
//                [self goToNewAVFoundationVC];
//                break;
//            case 1:
//                //                [self goToNewTaskVC];
//                break;
//            case 2:
//                //                [self goToNewTweetVC];
//                break;
//            default:
//                NSLog(@"%@",selectedItem.title);
//                break;
//        }
//    };
    
    [self setupNavBtn];
    
    //获取未读消息数，此时并没有把self注册为SDK的delegate，读取出的未读数是上次退出程序时的
    //    [self didUnreadMessagesCountChanged];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupUntreatedApplyCount) name:@"setupUntreatedApplyCount" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupUnreadMessageCount) name:@"setupUnreadMessageCount" object:nil];
    
    [self setupUnreadMessageCount];
    [self setupUntreatedApplyCount];
    
    [ChatDemoHelper shareHelper].contactViewVC = _contactsVC;
    [ChatDemoHelper shareHelper].conversationListVC = _chatListVC;
}
//初始化数据
-(void)createData{
    messageArr = [NSMutableArray array];
    NSUserDefaults *userd = [NSUserDefaults standardUserDefaults];
    messageArr = [NSMutableArray arrayWithArray:[userd objectForKey:@"messageArray"]];
    [GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret delegate:self];
}
- (void) setupNavBtn
{
    //变化按钮
    _rightNavBtn = [[FRDLivelyButton alloc] initWithFrame:CGRectMake(0,0,18.5,18.5)];
    [_rightNavBtn setOptions:@{ kFRDLivelyButtonLineWidth: @(1.0f),
                                kFRDLivelyButtonColor: [UIColor colorWithRed:(247 / 255.0f) green:(105 / 255.0f) blue:(86 / 255.0f) alpha:1]
                                }];
    [_rightNavBtn setStyle:kFRDLivelyButtonStylePlus animated:NO];
    [_rightNavBtn addTarget:self action:@selector(addItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightNavBtn];
    self.navigationItem.rightBarButtonItem = buttonItem;

//    UIBarButtonItem *search_btn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(searchItemClicked:)];
//    
//    NSArray *buttonArray = [[NSArray alloc] initWithObjects:_, search_btn, nil];
//    self.navigationItem.rightBarButtonItems = buttonArray;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"user.latitude"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"user.longitude"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"user.locationName"];
}

#pragma make VC
- (void)addItemClicked:(id)sender
{
    if (_rightNavBtn.buttonStyle == kFRDLivelyButtonStylePlus) {
        isShowMessage = YES;
        NSUserDefaults *userd = [NSUserDefaults standardUserDefaults];
        [userd setObject:@"YES" forKey:@"MusicRemind"];
        [self showAdd];
    } else{
        [_myPopMenu dismissMenu];
    }

}
//扫一扫和消息
-(void)showAdd{
    [_rightNavBtn setStyle:kFRDLivelyButtonStyleClose animated:YES];
    NSUserDefaults *userd = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [userd objectForKey:@"messageArray"];
    BOOL isHide;//是否隐藏
    messageNum = arr.count;
    if (messageNum == 0) {
        isHide = YES;
    }else{
        isHide = NO;
    }
    [GeTuiSdk setBadge:messageNum]; //同步本地角标值到服务器
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:messageNum]; //APP 显示角标需开发者调用系统方法进行设置
    
    //初始化弹出菜单
    NSArray *menuItems = @[
                           [MenuItem itemWithTitle:@"扫一扫" iconName:@"ic_saoma"  index:0],
                           [MenuItem itemWithTitle:@"系统消息" iconName:@"ic_system" glowColor:nil isMessage:isHide messageNum:messageNum index:1],
                           [MenuItem itemWithTitle:@"透传信息" iconName:@"ic_touchuan" index:2],
                           ];
    
    _myPopMenu = [[PopMenu alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64) items:menuItems];
    _myPopMenu.perRowItemCount = 3;
    _myPopMenu.menuAnimationType = kPopMenuAnimationTypeSina;
    [_myPopMenu showMenuAtView:kKeyWindow startPoint:CGPointMake(0, -100) endPoint:CGPointMake(0, -100)];
    __weak typeof(self) weakSelf = self;
    @weakify(self);
    _myPopMenu.didSelectedItemCompletion = ^(MenuItem *selectedItem){
        [weakSelf.myPopMenu.realTimeBlurFooter disMiss];
        @strongify(self);
        //改下显示style
        [self.rightNavBtn setStyle:kFRDLivelyButtonStylePlus animated:YES];
        if (!selectedItem) return;
        switch (selectedItem.index) {
            case 0:
                [self goToNewAVFoundationVC];
                break;
            case 1:
                [self goToNewTaskVC];
                break;
            case 2:
                [self goToNewTweetVC];
                break;
            default:
                NSLog(@"%@",selectedItem.title);
                break;
        }
    };
    
}
//系统消息
-(void)goToNewTaskVC{
    NewTaskViewController *vc = [[NewTaskViewController alloc]init];
    NSUserDefaults *userd = [NSUserDefaults standardUserDefaults];
    vc.messageArr = [NSMutableArray arrayWithArray:[userd objectForKey:@"messageArray"]];
    vc.clearBlock = ^(NSInteger index){
        [messageArr removeObjectAtIndex:index];
        NSUserDefaults *userd = [NSUserDefaults standardUserDefaults];
        [userd setObject:messageArr forKey:@"messageArray"];
    };
    isShowMessage = NO;
    [self.navigationController pushViewController:vc animated:YES];
}
//透传消息
-(void)goToNewTweetVC{
    NewTweetViewController *vc = [[NewTweetViewController alloc]init];
    isShowMessage = NO;
    [self.navigationController pushViewController:vc animated:YES];
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
    if (isShowMessage) {
        [_myPopMenu dismissMenu];
        [self showAdd];
    }else{
        
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
- (void)goToNewAVFoundationVC
{
    ScannerViewController *sanner = [[ScannerViewController alloc] init];
    sanner.title = @"扫一扫";
    [self.navigationController pushViewController:sanner animated:YES];
}

#pragma mark Search
- (void)searchItemClicked:(id)sender{
//    if (!_mySearchBar) {
//        _mySearchBar = ({
//            UISearchBar *searchBar = [[UISearchBar alloc] init];
//            searchBar.delegate = self;
//            [searchBar sizeToFit];
//            [searchBar setPlaceholder:@"搜索"];
//            [searchBar setTintColor:[UIColor orangeColor]];
//            searchBar;
//        });
//        [self.navigationController.view addSubview:_mySearchBar];
//        [_mySearchBar setY:20];
//    }
//    if (!_mySearchDisplayController) {
//        _mySearchDisplayController = ({
//            UISearchDisplayController *searchVC = [[UISearchDisplayController alloc] initWithSearchBar:_mySearchBar contentsController:self];
//            searchVC.searchResultsTableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(_mySearchBar.frame), 0, CGRectGetHeight(self.rdv_tabBarController.tabBar.frame), 0);
//            searchVC.searchResultsTableView.tableFooterView = [[UIView alloc] init];
//            searchVC.searchResultsDataSource = self;
//            searchVC.searchResultsDelegate = self;
//            if (kHigher_iOS_6_1) {
//                searchVC.displaysSearchBarInNavigationBar = NO;
//            }
//            searchVC;
//        });
//    }
//    [_mySearchBar becomeFirstResponder];
}

#pragma make - tableviewcell
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 160;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    _imageLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0 , 56, ScreenWidth, ScreenHeight/4)];
    _imageLogo.backgroundColor = [UIColor colorWithRed:(247.0 / 255.0) green:(247.0 / 255.0) blue:(240.0 / 255.0) alpha:1.0f];
    [_imageLogo setImage:[UIImage imageNamed:@"homeImageLogo"]];
    return _imageLogo;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    
    cell.backgroundColor = [UIColor clearColor];
    
    UIView *selectedBackground = [UIView new];
    selectedBackground.backgroundColor = [UIColor colorWithRed:(247/255) green:(247/255) blue:(240/255) alpha:0.2f];
    [cell setSelectedBackgroundView:selectedBackground];
    
    cell.imageView.image = [UIImage imageNamed:@[@"information", @"picture", @"dowenload", @"city", @"music",@"map",@"payment",@"share",@"chart",@"contect.jpg",@"information"][indexPath.row]];
    cell.textLabel.text = @[@"信息表单", @"图片列表", @"文件下载", @"城市选择", @"音乐播放", @"地图",@"支付",@"分享",@"聊天",@"通讯录",@"蓝牙"][indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)viewDidLayoutSubviews
{
    if ([_myTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_myTableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([_myTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_myTableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *userToken = [userDefault objectForKey:@"accessTokenLogin"];
        if (!(userToken.length > 0))   //如果没登录，跳转登录界面
        {
            LoginViewController *vc = [[LoginViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:_myTableView];
        [self.view addSubview:hud];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"正在加载数据...";
        [hud showAnimated:YES];
        [[NetworkEngine sharedManager] getThirdparty:@{
                                                        @"accessToken":userToken,
                                                      }
                                                 url:nil
                                        successBlock:^(id responseBody){
                                                NSLog(@"%@",responseBody);
                                                [hud removeFromSuperview];
                                            if ([responseBody[@"status"] intValue]  == 1)
                                            {
                                                PersonalInformationViewController *person = [[PersonalInformationViewController alloc] init];
                                                if ([responseBody[@"thirdPartyResponse"][@"qq"] intValue] == 1)
                                                {
                                                    person.ThirdpartyStr = @"qq";
                                                }
                                                else if ([responseBody[@"thirdPartyResponse"][@"weixin"] intValue] == 1)
                                                {
                                                    person.ThirdpartyStr = @"weixin";
                                                }
                                                else
                                                {
                                                    person.ThirdpartyStr = @"";
                                                }
                                                [self.navigationController pushViewController:person animated:YES];
                                            }
                                        }
                                        failureBlock:^(NSString *error){
                                                [hud removeFromSuperview];
                                        }];
    }
    else if (indexPath.row == 1)
    {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:_myTableView];
        [self.view addSubview:hud];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"正在加载数据...";
        [hud showAnimated:YES];
        [[NetworkEngine sharedManager] getImageListBySearch:@{
                                                              @"query.begin":@"2",
                                                              }
                                                        url:[NSString stringWithFormat:@"%@album/search.json",BaseUrl]
                                               successBlock:^(id responseBody){
                                                   NSLog(@"%@",responseBody);
                                                   NSMutableArray *NewArrList = [NSMutableArray new];
                                                   NewArrList=[NSMutableArray objectArrayWithKeyValuesArray:[responseBody objectForKey:@"albums"]];
                                                   [hud removeFromSuperview];
                                                   ImageListViewController *imagelist = [[ImageListViewController alloc] init];
                                                   imagelist.dateArr = [NewArrList copy];
                                                   [self.navigationController pushViewController:imagelist animated:YES];
                                               }
                                               failureBlock:^(NSString *error){
                                                   [hud removeFromSuperview];
                                               }];
    }
    else if (indexPath.row == 2){
        DownloadViewController *download_vc = [[DownloadViewController alloc]init];
        [self.navigationController pushViewController:download_vc animated:YES];
    }
    else if (indexPath.row == 3){
        AddressPickerViewController *addressPicker_vc = [[AddressPickerViewController alloc] init];
        [self.navigationController pushViewController:addressPicker_vc animated:YES];
    }
    else if (indexPath.row == 4){
        MusicListViewController *music = [[MusicListViewController alloc] init];
        music.title = @"音乐列表";
        [self.navigationController pushViewController:music animated:YES];
    }
    else if(indexPath.row == 5) {
        SigleLocationViewController *map_vc = [[SigleLocationViewController alloc] init];
        [self.navigationController pushViewController:map_vc animated:YES];
    
    }else if (indexPath.row == 6) {
        
        PingPayWebViewController *pay_vc = [[PingPayWebViewController alloc] init];
        pay_vc.title = @"支付";
        NSString *str = [NSString stringWithFormat:@"https://wap.koudaitong.com/v2/tag/w0dkel6i?reft=1473039949272&spm=sc1240852"];
        pay_vc.urlString = str;
        [self.navigationController pushViewController:pay_vc animated:YES];
        
    }else if (indexPath.row == 7) {
        
        ShareViewController *share_vc = [[ShareViewController alloc] init];
        [self.navigationController pushViewController:share_vc animated:YES];
        
    }else if (indexPath.row == 8){
        _chatListVC = [[ConversationListController alloc] init];
        [self.navigationController pushViewController:_chatListVC animated:YES];
       
    }else if (indexPath.row == 9){
        _contactsVC = [[ContactListViewController alloc] init];
        [self.navigationController pushViewController:_contactsVC animated:YES];
    }
    else if (indexPath.row == 10){
    
        BluetoothViewController *blue_vc = [[BluetoothViewController alloc] init];
        [self.navigationController pushViewController:blue_vc animated:YES];
        
    }
}
// 统计未读消息数
-(void)setupUnreadMessageCount
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    if (_chatListVC) {
        if (unreadCount > 0) {
            _chatListVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
        }else{
            _chatListVC.tabBarItem.badgeValue = nil;
        }
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadCount];
}

- (void)setupUntreatedApplyCount
{
    NSInteger unreadCount = [[[ApplyViewController shareController] dataSource] count];
    if (_contactsVC) {
        if (unreadCount > 0) {
            _contactsVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
        }else{
            _contactsVC.tabBarItem.badgeValue = nil;
        }
    }
}
- (void)networkChanged:(EMConnectionState)connectionState
{
    _connectionState = connectionState;
    [_chatListVC networkChanged:connectionState];
}
- (void)playSoundAndVibration{
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        //如果距离上次响铃和震动时间太短, 则跳过响铃
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
        return;
    }
    
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
    
    // 收到消息时，播放音频
    [[EMCDDeviceManager sharedInstance] playNewMessageSound];
    // 收到消息时，震动
    [[EMCDDeviceManager sharedInstance] playVibration];
}

- (void)showNotificationWithMessage:(EMMessage *)message
{
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    
    if (options.displayStyle == EMPushDisplayStyleMessageSummary) {
        EMMessageBody *messageBody = message.body;
        NSString *messageStr = nil;
        switch (messageBody.type) {
            case EMMessageBodyTypeText:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case EMMessageBodyTypeImage:
            {
                messageStr = NSLocalizedString(@"message.image", @"Image");
            }
                break;
            case EMMessageBodyTypeLocation:
            {
                messageStr = NSLocalizedString(@"message.location", @"Location");
            }
                break;
            case EMMessageBodyTypeVoice:
            {
                messageStr = NSLocalizedString(@"message.voice", @"Voice");
            }
                break;
            case EMMessageBodyTypeVideo:{
                messageStr = NSLocalizedString(@"message.video", @"Video");
            }
                break;
            default:
                break;
        }
        
        do {
            NSString *title = [[UserProfileManager sharedInstance] getNickNameWithUsername:message.from];
            if (message.chatType == EMChatTypeGroupChat) {
                NSDictionary *ext = message.ext;
                if (ext && ext[kGroupMessageAtList]) {
                    id target = ext[kGroupMessageAtList];
                    if ([target isKindOfClass:[NSString class]]) {
                        if ([kGroupMessageAtAll compare:target options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                            notification.alertBody = [NSString stringWithFormat:@"%@%@", title, NSLocalizedString(@"group.atPushTitle", @" @ me in the group")];
                            break;
                        }
                    }
                    else if ([target isKindOfClass:[NSArray class]]) {
                        NSArray *atTargets = (NSArray*)target;
                        if ([atTargets containsObject:[EMClient sharedClient].currentUsername]) {
                            notification.alertBody = [NSString stringWithFormat:@"%@%@", title, NSLocalizedString(@"group.atPushTitle", @" @ me in the group")];
                            break;
                        }
                    }
                }
                NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
                for (EMGroup *group in groupArray) {
                    if ([group.groupId isEqualToString:message.conversationId]) {
                        title = [NSString stringWithFormat:@"%@(%@)", message.from, group.subject];
                        break;
                    }
                }
            }
            else if (message.chatType == EMChatTypeChatRoom)
            {
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                NSString *key = [NSString stringWithFormat:@"OnceJoinedChatrooms_%@", [[EMClient sharedClient] currentUsername]];
                NSMutableDictionary *chatrooms = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:key]];
                NSString *chatroomName = [chatrooms objectForKey:message.conversationId];
                if (chatroomName)
                {
                    title = [NSString stringWithFormat:@"%@(%@)", message.from, chatroomName];
                }
            }
            
            notification.alertBody = [NSString stringWithFormat:@"%@:%@", title, messageStr];
        } while (0);
    }
    else{
        notification.alertBody = NSLocalizedString(@"receiveMessage", @"you have a new message");
    }
    
#warning 去掉注释会显示[本地]开头, 方便在开发中区分是否为本地推送
    //notification.alertBody = [[NSString alloc] initWithFormat:@"[本地]%@", notification.alertBody];
    
    notification.alertAction = NSLocalizedString(@"open", @"Open");
    notification.timeZone = [NSTimeZone defaultTimeZone];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
    } else {
        notification.soundName = UILocalNotificationDefaultSoundName;
        self.lastPlaySoundDate = [NSDate date];
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:message.chatType] forKey:kMessageType];
    [userInfo setObject:message.conversationId forKey:kConversationChatter];
    notification.userInfo = userInfo;
    
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    //    UIApplication *application = [UIApplication sharedApplication];
    //    application.applicationIconBadgeNumber += 1;
}
#pragma mark - 自动登录回调

- (void)willAutoReconnect{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSNumber *showreconnect = [ud objectForKey:@"identifier_showreconnect_enable"];
    if (showreconnect && [showreconnect boolValue]) {
        [self hideHud];
        [self showHint:NSLocalizedString(@"reconnection.ongoing", @"reconnecting...")];
    }
}

- (void)didAutoReconnectFinishedWithError:(NSError *)error{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSNumber *showreconnect = [ud objectForKey:@"identifier_showreconnect_enable"];
    if (showreconnect && [showreconnect boolValue]) {
        [self hideHud];
        if (error) {
            [self showHint:NSLocalizedString(@"reconnection.fail", @"reconnection failure, later will continue to reconnection")];
        }else{
            [self showHint:NSLocalizedString(@"reconnection.success", @"reconnection successful！")];
        }
    }
}
#pragma mark - public

- (void)jumpToChatList
{
    if ([self.navigationController.topViewController isKindOfClass:[ChatViewController class]]) {
        //        ChatViewController *chatController = (ChatViewController *)self.navigationController.topViewController;
        //        [chatController hideImagePicker];
    }
    else if(_chatListVC)
    {
        [self.navigationController popToViewController:self animated:NO];
//        [self.view setSelectedViewController:_chatListVC];
    }
}

- (EMConversationType)conversationTypeFromMessageType:(EMChatType)type
{
    EMConversationType conversatinType = EMConversationTypeChat;
    switch (type) {
        case EMChatTypeChat:
            conversatinType = EMConversationTypeChat;
            break;
        case EMChatTypeGroupChat:
            conversatinType = EMConversationTypeGroupChat;
            break;
        case EMChatTypeChatRoom:
            conversatinType = EMConversationTypeChatRoom;
            break;
        default:
            break;
    }
    return conversatinType;
}
- (void)didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo)
    {
        if ([self.navigationController.topViewController isKindOfClass:[ChatViewController class]]) {
            //            ChatViewController *chatController = (ChatViewController *)self.navigationController.topViewController;
            //            [chatController hideImagePicker];
        }
        
        NSArray *viewControllers = self.navigationController.viewControllers;
        [viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            if (obj != self)
            {
                if (![obj isKindOfClass:[ChatViewController class]])
                {
                    [self.navigationController popViewControllerAnimated:NO];
                }
                else
                {
                    NSString *conversationChatter = userInfo[kConversationChatter];
                    ChatViewController *chatViewController = (ChatViewController *)obj;
                    if (![chatViewController.conversation.conversationId isEqualToString:conversationChatter])
                    {
                        [self.navigationController popViewControllerAnimated:NO];
                        EMChatType messageType = [userInfo[kMessageType] intValue];
#ifdef REDPACKET_AVALABLE
                        chatViewController = [[RedPacketChatViewController alloc]
#else
                                              chatViewController = [[ChatViewController alloc]
#endif
                                                                    initWithConversationChatter:conversationChatter conversationType:[self conversationTypeFromMessageType:messageType]];
                                              switch (messageType) {
                                                  case EMChatTypeChat:
                                                  {
                                                      NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
                                                      for (EMGroup *group in groupArray) {
                                                          if ([group.groupId isEqualToString:conversationChatter]) {
                                                              chatViewController.title = group.subject;
                                                              break;
                                                          }
                                                      }
                                                  }
                                                      break;
                                                  default:
                                                      chatViewController.title = conversationChatter;
                                                      break;
                                              }
                                              [self.navigationController pushViewController:chatViewController animated:NO];
                                              }
                                              *stop= YES;
                                              }
                                              }
                                              else
                                              {
                                                  ChatViewController *chatViewController = nil;
                                                  NSString *conversationChatter = userInfo[kConversationChatter];
                                                  EMChatType messageType = [userInfo[kMessageType] intValue];
#ifdef REDPACKET_AVALABLE
                                                  chatViewController = [[RedPacketChatViewController alloc]
#else
                                                                        chatViewController = [[ChatViewController alloc]
#endif
                                                                                              initWithConversationChatter:conversationChatter conversationType:[self conversationTypeFromMessageType:messageType]];
                                                                        switch (messageType) {
                                                                            case EMChatTypeGroupChat:
                                                                            {
                                                                                NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
                                                                                for (EMGroup *group in groupArray) {
                                                                                    if ([group.groupId isEqualToString:conversationChatter]) {
                                                                                        chatViewController.title = group.subject;
                                                                                        break;
                                                                                    }
                                                                                }
                                                                            }
                                                                                break;
                                                                            default:
                                                                                chatViewController.title = conversationChatter;
                                                                                break;
                                                                        }
                                                                        [self.navigationController pushViewController:chatViewController animated:NO];
                                                                        }
                                                                        }];
                                              }
                                              else if (_chatListVC)
                                              {
                                                  [self.navigationController popToViewController:self animated:NO];
//                                                  [self setSelectedViewController:_chatListVC];
                                              }
                                              }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
