//
//  MessageDetailsViewController.m
//  EShowIOS
//
//  Created by MacBook on 16/8/18.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import "MessageDetailsViewController.h"

@interface MessageDetailsViewController ()

@end

@implementation MessageDetailsViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.extendedLayoutIncludesOpaqueBars = YES;
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"消息详情";
    self.view.backgroundColor = [UIColor whiteColor];
    [self createUI];
    // Do any additional setup after loading the view.
}

-(void)createUI{
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 80, ScreenWidth, 40)];
    titleLab.text = @"系统消息";
    titleLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLab];
    
    UITextView *contentView = [[UITextView alloc]initWithFrame:CGRectMake(30, 120, ScreenWidth-60, 200)];
    contentView.layer.cornerRadius = 5;
    contentView.layer.borderWidth = 1;
    contentView.layer.borderColor = [UIColor grayColor].CGColor;
    contentView.userInteractionEnabled = NO;
    contentView.font = [UIFont systemFontOfSize:15];
    contentView.text = _message;
    [self.view addSubview:contentView];
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
