//
//  ScanResultViewController.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/15.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import "ScanResultViewController.h"
#import "ContentViewController.h"
@interface ScanResultViewController ()

@end

@implementation ScanResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UILabel *resultTitle = [UILabel new];
    resultTitle.font = [UIFont systemFontOfSize:16];
    resultTitle.textAlignment = NSTextAlignmentCenter;
    resultTitle.text = @"已扫描到以下内容";
    resultTitle.textColor = [UIColor colorWithRed:16/255.0 green:16/255.0 blue:16/255.0 alpha:1.0f];
    [self.view addSubview:resultTitle];
    [resultTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(135);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(45);
    }];
    UILabel *contentLabel = [UILabel new];
    contentLabel.backgroundColor = [UIColor whiteColor];
    contentLabel.textColor = [UIColor colorWithRed:16/255.0 green:16/255.0 blue:16/255.0 alpha:1.0f];
    contentLabel.font = [UIFont systemFontOfSize:16];
    contentLabel.text = _resultStr;
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.numberOfLines = 0;
    [self.view addSubview:contentLabel];
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(196);
        make.left.equalTo(self.view).offset(29);
        make.right.equalTo(self.view).offset(-29);
        make.height.mas_equalTo(45);
    }];
    UILabel *remindLabel = [UILabel new];
    remindLabel.font = [UIFont systemFontOfSize:16];
    remindLabel.textAlignment = NSTextAlignmentCenter;
    remindLabel.text = @"扫描所得内容并非微信提供,请谨慎使用";
    remindLabel.textColor = [UIColor colorWithRed:16/255.0 green:16/255.0 blue:16/255.0 alpha:1.0f];
    remindLabel.numberOfLines = 0;
    [self.view addSubview:remindLabel];
    [remindLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(241);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(45);
    }];
    UIButton * backItem = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, 44)];
    [backItem setImage:[UIImage imageNamed:@"navi_back_red_new"] forState:UIControlStateNormal];
    
    [backItem setTitle:@"返回" forState:UIControlStateNormal];
    [backItem.titleLabel setFont:[UIFont systemFontOfSize:18]];
    //    [backItem setTitleEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    backItem.contentEdgeInsets = UIEdgeInsetsMake(0, -35, 0, 0);
    [backItem setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [backItem setTitleColor:[UIColor colorWithRed:(247 / 255.0f) green:(105 / 255.0f) blue:(86 / 255.0f) alpha:1] forState:UIControlStateNormal];
    [backItem addTarget:self action:@selector(clickedBackItem:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * leftItemBar = [[UIBarButtonItem alloc]initWithCustomView:backItem];
    self.navigationItem.leftBarButtonItem = leftItemBar;

}
- (void)clickedBackItem:(UIBarButtonItem *)btn
{
    for (UIViewController *temp in self.navigationController.viewControllers) {
        if ([temp isKindOfClass:[ContentViewController class]]) {
            [self.navigationController popToViewController:temp animated:YES];
        }
    }
}
#pragma mark - clickedCloseItem
- (void)clickedCloseItem:(UIButton *)btn{
   
    //    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor colorWithRed:(247.0 / 255.0f) green:(247.0 /255.0f) blue:(240.0 / 255.0f) alpha:1.0f];
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
