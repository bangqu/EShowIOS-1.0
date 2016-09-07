//
//  PersonalInformationViewController.m
//  EShowIOS
//
//  Created by 金璟 on 16/3/4.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import "PersonalInformationViewController.h"
#import "TitleRImageMoreCell.h"
#import "TitleValueMoreCell.h"
#import "JDStatusBarNotification.h"
#import "SettingTextViewController.h"
#import "ChooseGenderViewController.h"
#import "ActionSheetStringPicker.h"
#import "ActionSheetDatePicker.h"
#import "NSDate+Helper.h"
#import "AddressManager.h"
#import "WYJDatePicker.h"
#import "WYJAddressPicker.h"
#import "UMSocial.h"
@interface PersonalInformationViewController () <UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,WYJTimeDelegate>
{
    NSString *userToken;
    MBProgressHUD *hud;
    WYJAddressPicker *_pickerview;
}
@property (nonatomic , strong) UITableView *myTableView;
@property (nonatomic , strong) NSString *address;
@property (nonatomic , strong) WYJDatePicker *datePicker;
@end

@implementation PersonalInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"信息表单";
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor colorWithRed:(247.0f / 255.0f) green:(247.0f / 255.0f) blue:(240.0f / 255.0f) alpha:1.0f];
        tableView.dataSource = self;
        tableView.delegate = self;
        [tableView registerClass:[TitleRImageMoreCell class] forCellReuseIdentifier:kCellIdentifier_TitleRImageMore];
        [tableView registerClass:[TitleValueMoreCell class] forCellReuseIdentifier:kCellIdentifier_TitleValueMore];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    userToken = [userDefault objectForKey:@"accessTokenLogin"];
}
- (WYJDatePicker *)datePicker{
    if (!_datePicker) {
        self.datePicker = [[WYJDatePicker alloc]initWithFrame:self.view.bounds type:UIDatePickerModeDate];
        self.datePicker.delegate = self;
    }
    return _datePicker;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.myTableView = nil;
    self.view = nil;

}

#pragma mark tableviewdelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row;
    if (section == 0) {
        row = 6;
    }else if (section == 1){
        row = 4;
    }else{
        row = 2;
    }
    return row;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight;
    if (indexPath.section == 0 && indexPath.row == 0) {
        cellHeight = [TitleRImageMoreCell cellHeight];
    }else{
        cellHeight = [TitleValueMoreCell cellHeight];
    }
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            TitleRImageMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleRImageMore forIndexPath:indexPath];
            
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
            return cell;
        }else{
            TitleValueMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleValueMore forIndexPath:indexPath];
            switch (indexPath.row) {
                case 1:{
                    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"user.username"];
                    [cell setTitleStr:@"账号:" valueStr:username];
                    break;
                }
                case 2:
                {
                    NSString *realname = [[NSUserDefaults standardUserDefaults] stringForKey:@"user.realname"];
                    [cell setTitleStr:@"姓名:" valueStr:realname];
                    break;
                }
                case 3:
                {
                    NSString *nickname = [[NSUserDefaults standardUserDefaults] stringForKey:@"user.nickname"];
                    [cell setTitleStr:@"昵称:" valueStr:nickname];
                    break;
                }
                case 4:
                {
                    NSString *age = [[NSUserDefaults standardUserDefaults] stringForKey:@"user.age"];
                    [cell setTitleStr:@"年龄:" valueStr:age];
                    break;
                }
                default:
                {
                    NSString *male =[[NSUserDefaults standardUserDefaults] stringForKey:@"user.male"];
                    if ([male intValue] == 1) {
                        [cell setTitleStr:@"性别:" valueStr:@"男"];
                    }else{
                        [cell setTitleStr:@"性别:" valueStr:@"女"];
                    }
                    break;
                }
            }
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
            return cell;
        }
    }else if (indexPath.section == 1){
        TitleValueMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleValueMore forIndexPath:indexPath];
        switch (indexPath.row) {
            case 0:
            {
                NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"user.username"];
                [cell setTitleStr:@"手机号码:" valueStr:username];
                break;
            }
            case 1:
            {
                NSString *email = [[NSUserDefaults standardUserDefaults] stringForKey:@"user.email"];
                [cell setTitleStr:@"电子邮件:" valueStr:email];
                break;
            }
            case 2:
            {
                NSString *birthday = [[NSUserDefaults standardUserDefaults] stringForKey:@"user.birthday"];
                [cell setTitleStr:@"出生日期:" valueStr:birthday];
                break;
            }
            default:
            {
                NSString *address = [[NSUserDefaults standardUserDefaults] stringForKey:@"user.address"];
                [cell setTitleStr:@"常住城市:" valueStr:@"请选择"];
                if (address.length > 0)
                {
                     [cell setTitleStr:@"常住城市:" valueStr:address];
                }
                break;
            }
        }
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else{
        
        TitleValueMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleValueMore forIndexPath:indexPath];
        switch (indexPath.row) {
            case 0:
            {
                [cell setTitleStr:@"微信账号:" valueStr:@"未绑定"];
                if ([_ThirdpartyStr isEqualToString:@"weixin"])
                {
                    [cell setTitleStr:@"微信账号:" valueStr:@"已绑定"];
                }
                break;
            }
            default:
            {
                [cell setTitleStr:@"QQ帐号:" valueStr:@"未绑定"];
                if ([_ThirdpartyStr isEqualToString:@"qq"])
                {
                    [cell setTitleStr:@"QQ帐号:" valueStr:@"已绑定"];
                }
                break;
            }
        }
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"更换头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
            [actionSheet showInView:self.view];

        }else if (indexPath.row == 2){
            [self pushViewControllerandData:[[NSUserDefaults standardUserDefaults] objectForKey:@"user.realname"]
                                    andType:@"user.nickname"
                                   andTitle:@"姓名"];
        }else if (indexPath.row == 3){
            [self pushViewControllerandData:[[NSUserDefaults standardUserDefaults] objectForKey:@"user.nickname"]
                                    andType:@"user.nickname"
                                   andTitle:@"昵称"];
        }else if (indexPath.row == 4){
            [self pushViewControllerandData:[[NSUserDefaults standardUserDefaults] objectForKey:@"user.age"]
                                    andType:@"user.age"
                                   andTitle:@"年龄"];
        }else {
            ChooseGenderViewController *vc = [[ChooseGenderViewController alloc] init];
            vc.setData = [[NSUserDefaults standardUserDefaults] objectForKey:@"user.male"];
            vc.dataType = @"user.male";
            vc.title = @"性别";
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if (indexPath.section == 1){
        if (indexPath.row == 1)
        {
            [self pushViewControllerandData:[[NSUserDefaults standardUserDefaults] objectForKey:@"user.email"]
                                    andType:@"user.email"
                                   andTitle:@"邮箱"];
        }
        else if (indexPath.row == 2) {
            
            NSDate *curDate = [NSDate dateFromString:[[NSUserDefaults standardUserDefaults] objectForKey:@"user.birthday"] withFormat:@"yyyy-MM-dd"];
            if (!curDate) {
                curDate = [NSDate date];
            }
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            
            [self.datePicker setNowTime:[formatter stringFromDate:curDate]];
            [self.view addSubview:_datePicker];
        }else if (indexPath.row == 3){
            _pickerview = [WYJAddressPicker shareInstance];
            [_pickerview showBottomView];
            [self.view addSubview:_pickerview];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            __weak UITableView *temp = _myTableView;
            _pickerview.block = ^(NSString *province,NSString *city,NSString *district)
            {
//                [temp setTitle:[NSString stringWithFormat:@"%@ %@ %@",province,city,district] forState:UIControlStateNormal];
                [defaults setObject:[NSString stringWithFormat:@"%@-%@-%@",province,city,district] forKey:@"user.address"];
                [temp reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            };
        }
    }
    else
    {
        if (indexPath.row == 0)
        {
            if (_ThirdpartyStr.length > 0)
            {
                if ([_ThirdpartyStr isEqualToString:@"weixin"])
                {
                    [self cancleBuildingWithPlatform:_ThirdpartyStr];
                }
                else
                {
                    [self buildingOpinion];
                }
            }
            else
            {
                [self getThirdpartyEmpowerAndType:UMShareToWechatSession AndPlatform:@"weixin"];
            }
        }
        else
        {
            if (_ThirdpartyStr.length > 0)
            {
                if ([_ThirdpartyStr isEqualToString:@"qq"])
                {
                    [self cancleBuildingWithPlatform:_ThirdpartyStr];
                }
                else
                {
                    [self buildingOpinion];
                }
            }
            else
            {
                [self getThirdpartyEmpowerAndType:UMShareToQQ AndPlatform:@"qq"];
            }
        }
    }
}
#pragma mark 跳转修改信息界面
- (void)pushViewControllerandData:(NSString *)data andType:(NSString *)type andTitle:(NSString *)title
{
    SettingTextViewController *vc = [[SettingTextViewController alloc] init];
    vc.setData = data;
    vc.dataType = type;
    vc.title = title;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark 取消绑定
- (void)cancleBuildingWithPlatform:(NSString *)platform
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定取消绑定吗?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[NetworkEngine sharedManager] cancleThirdparty:@{
                                                          @"accessToken":userToken,
                                                          @"thirdParty.platform":platform
                                                          }
                                                    url:nil
                                           successBlock:^(id responseBody) {
                                               if ([responseBody[@"status"] intValue] == 1)
                                               {
                                                   hud = [MBProgressHUD showHUDAddedTo:_myTableView animated:YES];
                                                   hud.mode = MBProgressHUDModeText;
                                                   hud.margin = 10.f;
                                                   [hud setOffset:CGPointMake(0, -100)];
                                                   hud.label.text = @"修改成功";
                                                   [hud hideAnimated:YES afterDelay:2];
                                                   _ThirdpartyStr = @"";
                                                   [_myTableView reloadData];
                                               }
                                               else
                                               {
                                                   NSLog(@"%@",responseBody);
                                               }
                                           }
                                           failureBlock:^(NSString *error) {
                                               NSLog(@"%@",error);
                                           }];
    }];
    [alert addAction:ok];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alert addAction:cancle];
    [self presentViewController:alert animated:YES completion:^{ }];

}
#pragma mark 已绑定提醒
- (void)buildingOpinion
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否添加绑定?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.view makeToast:@"请先取消其它绑定" duration:2 position:@"center"];
    }];
    [alert addAction:ok];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alert addAction:cancle];
    [self presentViewController:alert animated:YES completion:^{ }];
    return;
}
#pragma mark 第三方平台授权
- (void)getThirdpartyEmpowerAndType:(NSString *)type AndPlatform:(NSString *)platform
{
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:type];
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQQ];
            NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
            //调用接口
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
            [manager POST:[NSString stringWithFormat:@"http://api.eshow.org.cn/user/third.json?"]
               parameters:@{
                            @"thirdParty.platform" : platform,
                            @"thirdParty.nickname" : snsAccount.userName,
                            @"thirdParty.username.url" : snsAccount.iconURL,
                            @"thirdParty.username" : snsAccount.usid,
                            } success:^(AFHTTPRequestOperation *operation,id responseObject) {
                                NSDictionary *dic = responseObject;
                                NSString *str = [NSString stringWithFormat:@"msg:%@;status:%@",dic[@"msg"],dic[@"status"]];
                                NSLog(@"显示数据:%@",str);
                                if (dic[@"status"] == nil) {
                                    return;
                                }else if ([dic[@"status"] intValue] == 0){
                                    [self.view makeToast:dic[@"msg"] duration:2 position:@"center"];
                                    return;
                                }else if ([dic[@"status"] intValue] == 1){
                                    _ThirdpartyStr = platform;
                                    [self buildThirdPartyWithUsername:snsAccount.usid];
                                    if (snsAccount.iconURL.length > 0)
                                    {
                                        [[NSUserDefaults standardUserDefaults] setObject:snsAccount.iconURL forKey:@"user.photo"];
                                    }
                                }else if ([dic[@"status"] intValue] == -5){
                                    [self.view makeToast:dic[@"msg"] duration:2 position:@"center"];
                                    return;
                                }
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"error: %@", error);
                            }];
        }
    });
}
#pragma mark 绑定第三方平台
- (void)buildThirdPartyWithUsername:(NSString *)str
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    [manager GET:[NSString stringWithFormat:@"http://api.eshow.org.cn/user/mobile.json"]
      parameters:@{
                   @"user.username":[[NSUserDefaults standardUserDefaults] stringForKey:@"user.username"],
                   @"thirdParty.username":str
                   }
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *dic = responseObject;
             NSString *str = [NSString stringWithFormat:@"msg:%@;status:%@",dic[@"msg"],dic[@"status"]];
             NSLog(@"显示数据:%@",str);
             if (dic[@"status"] == nil) {
                 return;
             }else if ([dic[@"status"] intValue] == 1){
                 [self.view makeToast:@"绑定成功" duration:2 position:@"center"];
                 [_myTableView reloadData];
             }
             else{
                 return;
             }
         }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"error: %@", error);
         }];
}
#pragma mark UIActionSheetDelegate M
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 2) {
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;//设置可编辑
    
    if (buttonIndex == 0) {
        //  拍照
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else if (buttonIndex == 1){
        UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
        photoPicker.delegate = self;
        photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        photoPicker.view.backgroundColor = [UIColor whiteColor];
        [self presentViewController:photoPicker animated:YES completion:NULL];
    }
    [self presentViewController:picker animated:YES completion:nil];//进入照相界面
}
//当时间改变时触发
- (void)changeTime:(NSDate *)date{
    
}

//确定时间
- (void)determine:(NSDate *)date{
     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
//     TitleValueMoreCell *cell = [_myTableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleValueMore forIndexPath:indexPath];
//     [cell setTitleStr:@"出生日期:" valueStr:[self.datePicker stringFromDate:date]];
    [[NSUserDefaults standardUserDefaults] setObject:[self.datePicker stringFromDate:date] forKey:@"user.birthday"];
     [_myTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//    [self.chooseTimeBtn setTitle:[self.timeV stringFromDate:date] forState:UIControlStateNormal];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_myTableView reloadData];
}
@end
