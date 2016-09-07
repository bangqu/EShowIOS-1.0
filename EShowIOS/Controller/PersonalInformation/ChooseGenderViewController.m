//
//  ChooseGenderViewController.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/9.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import "ChooseGenderViewController.h"

@interface ChooseGenderViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    NSMutableDictionary *dicArr;
    NSArray *maleArr;
    BOOL ManBool,WomanBool;
}
@property (nonatomic, strong) UITableView *myTableView;

@end

@implementation ChooseGenderViewController
#define SizeProportion [UIScreen mainScreen].bounds.size.width/375.0
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = [UIColor colorWithRed:(247.0f / 255.0f) green:(247.0f / 255.0f) blue:(240.0f / 255.0f) alpha:1.0f];
        tableView.dataSource = self;
        tableView.delegate = self;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.equalTo (self.view);
        }];
        tableView;
    });
    ManBool = NO;
    WomanBool = NO;
    if (!([_setData intValue] < 0))
    {
        if ([_setData intValue] == 1)
        {
            ManBool = YES;
        }
        else
        {
            WomanBool = YES;
        }
    }
    dicArr = [[NSMutableDictionary alloc] init];
    NSMutableArray *genderArr = [NSMutableArray array];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (int i = 0; i < 2; i ++)
    {
        [dic setObject:@"NO" forKey:@"State"];
        [genderArr addObject:dic];
    }
    [dicArr setObject:genderArr forKey:@"male"];
    maleArr = @[@"男",@"女"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(sendUp)];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
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
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *titleLabel = [UILabel new];
        titleLabel.frame = CGRectMake(20, 7, 40, 30);
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.tag = 101;
        [cell.contentView addSubview:titleLabel];
        UIImageView *checkImage = [UIImageView new];
        checkImage.tag = 102;
        [cell.contentView addSubview:checkImage];
        [checkImage mas_makeConstraints:^(MASConstraintMaker *make){
            make.right.equalTo(cell.contentView).offset(-16);
            make.height.mas_equalTo(24*SizeProportion);
            make.width.mas_equalTo(24*SizeProportion);
            make.top.equalTo(cell.contentView).offset((44-24*SizeProportion)/2.0);
        }];
    }
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:101];
    titleLabel.text = maleArr[indexPath.row];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:102];
    if (indexPath.row ==0 )
    {
        if (ManBool == NO)
        {
            imageView.image = [UIImage imageNamed:@"btn_unchecked"];
        }
        else
        {
             imageView.image = [UIImage imageNamed:@"btn_checked"];
        }
    }
    else
    {
        if (WomanBool == NO)
        {
            imageView.image = [UIImage imageNamed:@"btn_unchecked"];
        }
        else
        {
            imageView.image = [UIImage imageNamed:@"btn_checked"];
        }

    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0)
    {
        if (ManBool == NO)
        {
            ManBool = YES;
            WomanBool = NO;
        }
        else
        {
            ManBool = NO;
            WomanBool = NO;
        }
    }
    else
    {
        if (WomanBool == NO)
        {
            ManBool = NO;
            WomanBool = YES;
        }
        else
        {
            ManBool = NO;
            WomanBool = NO;
        }
    }
    [tableView reloadData];
}
- (void)sendUp
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:_myTableView];
    [self.view addSubview:hud];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = @"正在提交数据...";
    [hud showAnimated:YES];

    NSDictionary *parameters;
    if (ManBool ==NO && WomanBool ==NO)
    {
        parameters = @{@"accessToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"accessTokenLogin"]};
    }
    else
    {
        if (ManBool == YES)
        {
            parameters = @{@"accessToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"accessTokenLogin"],
                           _dataType:@true};
        }
        else
        {
            parameters = @{@"accessToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"accessTokenLogin"],
                           _dataType:@false};
        }
    }
    [[NetworkEngine sharedManager] updateInfo:parameters
                                          url:nil
                                 successBlock:^(id responseBody) {
                                     [hud removeFromSuperview];
                                     if (responseBody[@"status"] == nil) {
                                         return;
                                     }else if ([responseBody[@"status"] intValue] == 1){
                                         [[NSUserDefaults standardUserDefaults] setInteger:[parameters[_dataType] intValue]forKey:_dataType];
                                         [self.view makeToast:responseBody[@"msg"] duration:2 position:@"center"];
                                         [self.navigationController popViewControllerAnimated:YES];
                                         
                                     }else{
                                         
                                         [self.view makeToast:responseBody[@"msg"] duration:2 position:@"center"];
                                     }
                                 }
                                 failureBlock:^(NSString *error) {
                                     [hud removeFromSuperview];
                                     NSLog(@"error: %@", error);
                                 }];
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
