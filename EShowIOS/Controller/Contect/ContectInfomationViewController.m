//
//  ChatInfomationViewController.m
//  EShowIOS
//
//  Created by 王迎军 on 16/9/1.
//  Copyright © 2016年 王迎军. All rights reserved.
//

#import "ContectInfomationViewController.h"
#import "SDAutoLayout.h"
#import "TitleValueMoreCell.h"
@interface ContectInfomationViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *titleArr,*valueArr;
}
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation ContectInfomationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"个人详情";
    self.view.backgroundColor = [UIColor colorWithRed:(247.0 / 255.0f) green:(247.0 /255.0f) blue:(240.0 / 255.0f) alpha:1.0f];
    [self initTablewView];
    titleArr = @[@"手机",@"职位",@"邮箱",@"昵称",@"年龄",@"性别"];
    valueArr = @[@"122333113",@"测试",@"测试",@"测试",@"测试",@"测试"];
}
- (void)initTablewView
{
    _tableView = [UITableView new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithRed:(247.0 / 255.0f) green:(247.0 /255.0f) blue:(240.0 / 255.0f) alpha:1.0f];
    [_tableView registerClass:[TitleValueMoreCell class] forCellReuseIdentifier:kCellIdentifier_TitleValueMore];
    [self.view addSubview:_tableView];
    _tableView.sd_layout.topEqualToView(self.view).leftEqualToView(self.view).rightEqualToView(self.view).bottomEqualToView(self.view);
    _tableView.tableFooterView = [self customFooterView];
    _tableView.tableHeaderView = [self customHeaderView];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight;
    cellHeight = [TitleValueMoreCell cellHeight];
    return cellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 7, 100, 30)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.tag = 101;
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textColor = [UIColor blackColor];
        [cell.contentView addSubview:titleLabel];
        UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 7, ScreenWidth-(110+kPaddingLeftWidth) - 30, 30)];
        valueLabel.tag = 102;
        valueLabel.backgroundColor = [UIColor clearColor];
        valueLabel.font = [UIFont systemFontOfSize:15];
        valueLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
        valueLabel.textAlignment = NSTextAlignmentLeft;
        valueLabel.adjustsFontSizeToFitWidth = YES;
        valueLabel.minimumScaleFactor = 0.6;
        [cell.contentView addSubview:valueLabel];
    }
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:101];
    titleLabel.text = titleArr[indexPath.row];
    UILabel *valueLabel = (UILabel *)[cell.contentView viewWithTag:102];
    valueLabel.text = valueArr[indexPath.row];
    return cell;
}
-(void)viewDidLayoutSubviews
{
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
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
- (UIView *)customHeaderView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 200)];
    view.backgroundColor = [UIColor colorWithRed:(247.0 / 255.0f) green:(247.0 /255.0f) blue:(240.0 / 255.0f) alpha:1.0f];
    
    UIImageView *imageView = [UIImageView new];
    imageView.image = [UIImage imageNamed:@"IMG_0094.jpg"];
    [view addSubview:imageView];
    imageView.sd_layout.centerXEqualToView(view).centerYEqualToView(view).heightIs(100).widthIs(100);
    imageView.layer.cornerRadius = imageView.frame.size.height/2.0;
    UILabel *nameLabel = [UILabel new];
    nameLabel.text = @"测死";
//    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:nameLabel];
    nameLabel.sd_layout.topSpaceToView(imageView,10).leftEqualToView(view).rightEqualToView(view).heightIs(20);
    return view;
}
- (UIView *)customFooterView{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 100)];
    headerV.backgroundColor = [UIColor clearColor];
    
    UIButton *btn = [UIButton new];
    btn.backgroundColor = RGBColor(247, 105, 86);
    btn.layer.cornerRadius = 5.0;
    btn.titleLabel.textColor = [UIColor whiteColor];
    [btn setTitle:@"发消息" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [headerV addSubview:btn];
    
    btn.sd_layout.topSpaceToView(headerV,50).leftSpaceToView(headerV,15).rightSpaceToView(headerV,15).heightIs(40);
    
    return headerV;
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
