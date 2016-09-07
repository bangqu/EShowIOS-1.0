//
//  SigleLocationViewController.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/11.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import "SigleLocationViewController.h"
#import "TPKeyboardAVoidingTableView.h"
#import "MapViewController.h"


@interface SigleLocationViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingTableView *myTableView;
@property (nonatomic, strong) UITextField *addressInDetail_textField;
@property (nonatomic, assign) BOOL Firstlogin;          // 判断有没有选过位置

@end

@implementation SigleLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"地图";
    _Firstlogin = YES;
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] init];
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0;
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
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 0, ScreenWidth/5, 44.0f)];
        label.text = @"详细地址:";
        label.font = [UIFont systemFontOfSize:14.0f];
        label.textAlignment = NSTextAlignmentNatural;
        label.textColor = [UIColor grayColor];
        label.tag = 101;
        [cell.contentView addSubview:label];
        UILabel *add_label = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth/5+20.0f, 0, ScreenWidth*4/5 - 50, 44.0f)];
        add_label.tag = 102;
        add_label.font = [UIFont systemFontOfSize:14.0f];
        add_label.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:add_label];
        UIImageView *image= [[UIImageView alloc] init];
        image.tag = 103;
        image.frame = CGRectMake(ScreenWidth - 44, 12, 20, 20);
        image.image = [UIImage imageNamed:@"address"];
        [cell.contentView addSubview:image];
        UITextField *textFieled = [[UITextField alloc] initWithFrame:CGRectMake(ScreenWidth/5 + 20.0f, 0, ScreenWidth*4/5, 44.0f)];
        textFieled.tag = 104;
        [cell.contentView addSubview:textFieled];
    }

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [(UITextField *)[cell.contentView viewWithTag:104] removeFromSuperview];
            UILabel *add_label = (UILabel *)[cell.contentView viewWithTag:102];
            if (_Firstlogin == NO)
            {
                NSString *lactionName = [[NSUserDefaults standardUserDefaults]objectForKey:@"user.locationName"];
                if (lactionName.length > 0)
                {
                    add_label.text = lactionName;
                    add_label.textColor = [UIColor blackColor];
                }
                else
                {
                    add_label.text = @"请输入地址";
                    add_label.textColor = [UIColor colorWithRed:(200/255) green:(200/255) blue:(206/255) alpha:0.2f];
                }
            }
            else
            {
                add_label.text = @"请输入地址";
                add_label.textColor = [UIColor colorWithRed:(200/255) green:(200/255) blue:(206/255) alpha:0.2f];
            }
        }else{
            [(UILabel *)[cell.contentView viewWithTag:101] removeFromSuperview];
            [(UILabel *)[cell.contentView viewWithTag:102] removeFromSuperview];
            [(UIImageView *)[cell.contentView viewWithTag:103] removeFromSuperview];
            _addressInDetail_textField = (UITextField *)[cell.contentView viewWithTag:104];
            _addressInDetail_textField.keyboardType = UIKeyboardTypeDefault;
            _addressInDetail_textField.font = [UIFont systemFontOfSize:14.0f];
            _addressInDetail_textField.placeholder = @"请完善详细地址";
            _addressInDetail_textField.clearButtonMode = UITextFieldViewModeAlways;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        MapViewController *map_vc = [[MapViewController alloc] init];
        if (_Firstlogin == NO)
        {
            NSString *lactionName = [[NSUserDefaults standardUserDefaults]objectForKey:@"user.locationName"];
            if (lactionName.length > 0)
            {
                map_vc.latitude_str = [[NSUserDefaults standardUserDefaults]objectForKey:@"user.latitude"];
                map_vc.longitude_str =[[NSUserDefaults standardUserDefaults]objectForKey:@"user.longitude"];
            }
        }
        [self.navigationController pushViewController:map_vc animated:YES];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _Firstlogin = NO;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_Firstlogin == NO)
    {
        [_myTableView reloadData];
    }
}
@end
