//
//  SetMobileViewController.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/9.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import "SetMobileViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "Input_OnlyText_Cell.h"//文本
#import "UITTTAttributedLabel.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
@interface SetMobileViewController ()<UITableViewDataSource,UITableViewDelegate,TTTAttributedLabelDelegate>

@property (strong, nonatomic) UIButton *footerBtn;
@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UITextField *username_textField;

@end

@implementation SetMobileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     self.title = @"绑定帐号";
    //添加myTableView
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor colorWithRed:(247.0 / 255.0f) green:(247.0 /255.0f) blue:(240.0 / 255.0f) alpha:1.0f];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    self.myTableView.tableHeaderView = [self customHeaderView];
    self.myTableView.tableFooterView=[self customFooterView];
    
    if (self.navigationController.childViewControllers.count <= 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissSelf)];
    }

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)dismissSelf{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.row == 0) {
        self.username_textField = [[UITextField alloc] init];
        self.username_textField.frame = CGRectMake(20.0f, 0, ScreenWidth-30.0f, 55.0f);
        self.username_textField.keyboardType = UIKeyboardTypeNumberPad;
        self.username_textField.placeholder = @"请输入手机号码";
        self.username_textField.clearButtonMode = UITextFieldViewModeAlways;
        [cell.contentView addSubview:self.username_textField];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0;
}

#pragma mark - Table view Header Footer
- (UIView *)customHeaderView{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.04*ScreenHeight)];
    headerV.backgroundColor = [UIColor clearColor];
    return headerV;
}

- (UIView *)customFooterView{
    
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 100, ScreenWidth, 150)];
    _footerBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"提交" andFrame:CGRectMake(kLoginPaddingLeftWidth, 20, ScreenWidth-kLoginPaddingLeftWidth*2, 45) target:self action:@selector(sendRegister)];
    [footerV addSubview:_footerBtn];
    
    UITTTAttributedLabel *lineLabel = ({
        UITTTAttributedLabel *label = [UITTTAttributedLabel new];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor grayColor];
        label.numberOfLines = 0;
        label.linkAttributes = kLinkAttributes;
        label.activeLinkAttributes = kLinkAttributesActive;
        label.delegate = self;
        label;
    });
    NSString * tipStr = @"我已阅读并同意《EShow 使用协议》";
    lineLabel.text = tipStr;
    [lineLabel addLinkToTransitInformation:@{@"actionStr": @"gotoServiceTermsVC"} withRange:[tipStr rangeOfString:@"《EShow 使用协议》"]];
    CGRect footerBtnFrame = _footerBtn.frame;
    lineLabel.frame = CGRectMake(CGRectGetMinX(footerBtnFrame), CGRectGetMaxY(footerBtnFrame) +12, CGRectGetWidth(footerBtnFrame), 12);
    [footerV addSubview:lineLabel];
    
    return footerV;
}

#pragma mark Btn Clicked
- (void)sendRegister
{
    [self.username_textField resignFirstResponder];
    
    if ([self.username_textField.text length] !=11) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入正确的手机号码" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    
    [manager GET:[NSString stringWithFormat:@"http://api.eshow.org.cn/user/mobile.json"]
      parameters:@{
                   @"user.username":self.username_textField.text,
                   @"thirdParty.username":_thirdPartyID
                   }
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSDictionary *dic = responseObject;
             
             NSString *str = [NSString stringWithFormat:@"msg:%@;status:%@",dic[@"msg"],dic[@"status"]];
             
             NSLog(@"显示数据:%@",str);
             
             if (dic[@"status"] == nil) {
                 return;
             }else if ([dic[@"status"] intValue] == 1){
                 MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_myTableView animated:YES];
                 hud.mode = MBProgressHUDModeText;
                 hud.label.text = @"正在登录中";
                 hud.removeFromSuperViewOnHide = YES;
                 [hud hideAnimated: YES afterDelay: 2];
                 
                 NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                 [userDefaults setObject:dic[@"user"][@"username"] forKey:@"user.username"];
                 [userDefaults setObject:dic[@"user"][@"password"] forKey:@"user.password"];
                 [userDefaults setObject:dic[@"user"][@"id"] forKey:@"user.userid"];
                 [userDefaults synchronize];
                 [((AppDelegate *)[UIApplication sharedApplication].delegate) setupTabViewController];
                 
                 //                                  返回user对象
                 [[NSUserDefaults standardUserDefaults] setObject:dic[@"accessToken"][@"accessToken"] forKey:@"accessTokenLogin"];
                 [[NSUserDefaults standardUserDefaults] setObject:_thirdPartyIcon forKey:@"user.photo"];
                 if (![dic[@"user"][@"realname"] isKindOfClass:[NSNull class]]) {
                     [[NSUserDefaults standardUserDefaults] setObject:dic[@"user"][@"realname"] forKey:@"realname"];
                 }else{
                     [[NSUserDefaults standardUserDefaults] setObject:@"未填写" forKey:@"realname"];
                 }
                 
                 if (![dic[@"user"][@"realname"] isKindOfClass:[NSNull class]]) {
                     [[NSUserDefaults standardUserDefaults] setObject:dic[@"user"][@"realname"] forKey:@"user.realname"];
                 } else {
                     [[NSUserDefaults standardUserDefaults] setObject:@"未填写" forKey:@"user.realname"];
                 }
                 
                 if (![dic[@"user"][@"nickname"] isKindOfClass:[NSNull class]]) {
                     [[NSUserDefaults standardUserDefaults] setObject:dic[@"user"][@"nickname"] forKey:@"user.nickname"];
                 } else {
                     [[NSUserDefaults standardUserDefaults] setObject:@"未填写" forKey:@"user.nickname"];
                 }
                 
                 if (![dic[@"user"][@"age"] isKindOfClass:[NSNull class]]) {
                     [[NSUserDefaults standardUserDefaults] setInteger:[dic[@"user"][@"age"] intValue]forKey:@"user.age"];
                 } else {
                     [[NSUserDefaults standardUserDefaults] setObject:@"未填写" forKey:@"user.age"];
                 }
                 
                 if (![dic[@"user"][@"male"] isKindOfClass:[NSNull class]]) {
                     [[NSUserDefaults standardUserDefaults] setInteger:[dic[@"user"][@"male"] boolValue]forKey:@"user.male"];
                 } else {
                     [[NSUserDefaults standardUserDefaults] setObject:@"未知" forKey:@"user.male"];
                 }
                 
                 
                 if (![dic[@"user"][@"email"] isKindOfClass:[NSNull class]]) {
                     [[NSUserDefaults standardUserDefaults] setObject:dic[@"user"][@"email"] forKey:@"user.email"];
                 } else {
                     [[NSUserDefaults standardUserDefaults] setObject:@"未填写" forKey:@"user.email"];
                 }
                 
                 if (![dic[@"user"][@"birthday"] isKindOfClass:[NSNull class]]) {
                     [[NSUserDefaults standardUserDefaults] setObject:dic[@"user"][@"birthday"] forKey:@"user.birthday"];
                 } else {
                     [[NSUserDefaults standardUserDefaults] setObject:@"请选择" forKey:@"user.birthday"];
                 }
                 
                 if (![dic[@"user"][@"intro"] isKindOfClass:[NSNull class]]) {
                     [[NSUserDefaults standardUserDefaults] setObject:dic[@"user"][@"intro"]forKey:@"user.intro"] ;
                 } else {
                     [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"user.intro"];
                 }
                 
             }else{
                 
                 MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                 hud.mode = MBProgressHUDModeText;
                 hud.label.text = [NSString stringWithFormat:@"%@",dic[@"msg"]];
                 hud.removeFromSuperViewOnHide = YES;
                 [hud hideAnimated: YES afterDelay: 2];
                 
                 return;
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             NSLog(@"error: %@", error);
             
         }];
    
}

#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    [self gotoServiceTermsVC];
}

#pragma mark VC
- (void)gotoServiceTermsVC{
    //    NSString *pathForServiceterms = [[NSBundle mainBundle] pathForResource:@"service_terms" ofType:@"html"];
    //    WebViewController *vc = [WebViewController webVCWithUrlStr:pathForServiceterms];
    //    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
