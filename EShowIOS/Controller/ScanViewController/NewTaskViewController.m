//
//  NewTaskViewController.m
//  EShowIOS
//
//  Created by MacBook on 16/8/16.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import "NewTaskViewController.h"
#import "GeTuiSdk.h"
#import "MessageDetailsViewController.h"
@interface NewTaskViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *allMessage;//所有消息
    NSMutableArray *message;
    
}
@property(nonatomic,strong)UITableView *teableV;
@end

@implementation NewTaskViewController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    allMessage = [NSMutableArray alloc];
    message = [NSMutableArray alloc];
    allMessage = [[NSMutableArray alloc]initWithArray:_messageArr];
    NSUserDefaults *userd = [NSUserDefaults standardUserDefaults];
    message = [NSMutableArray arrayWithArray:[userd objectForKey:@"message"]];
    if (message.count>0) {
        for (NSString *messages in message) {
            [allMessage addObject:messages];
        }
    }
    [_teableV reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"系统消息";
    self.view.backgroundColor = [UIColor grayColor];
    [self createTableView];
    //[GeTuiSdk resetBadge]; //重置角标计数
    // [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0]; // APP 清空角标
   // NSUserDefaults *userd = [NSUserDefaults standardUserDefaults];
   // [userd removeObjectForKey:@"messageArray"];
   
    // Do any additional setup after loading the view.
}

-(void)createTableView{
    UITableView *tableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
    tableV.delegate = self;
    tableV.dataSource = self;
    tableV.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:tableV];
    _teableV = tableV;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return allMessage.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *indentifier = @"indentifier";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
    }
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 40, 40)];
   // image.layer.cornerRadius = 20;
    image.image = [UIImage imageNamed:@"scan_picture"];
    [cell.contentView addSubview:image];
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 100, 35)];
    titleLab.text = @"系统消息";
    [cell.contentView addSubview:titleLab];
    UILabel *contentLab = [[UILabel alloc]initWithFrame:CGRectMake(70, 30, ScreenWidth-110, 25)];
    contentLab.font = [UIFont systemFontOfSize:15];
    contentLab.textColor = [UIColor grayColor];
    contentLab.text = allMessage[indexPath.row];
    [cell.contentView addSubview:contentLab];
    
    UILabel *read = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth-50, 20, 20, 20)];
    read.backgroundColor = [UIColor redColor];
    read.textColor = [UIColor whiteColor];
    if(indexPath.row<_messageArr.count){
        read.hidden = NO;
    }else{
        read.hidden = YES;
    }
    read.text = @"1";
    read.textAlignment = NSTextAlignmentCenter;
    read.layer.cornerRadius  = 10;
    read.clipsToBounds = YES;
    [cell.contentView addSubview:read];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row<_messageArr.count) {
        NSUserDefaults *userd = [NSUserDefaults standardUserDefaults];
        [message addObject:_messageArr[indexPath.row]];
        [userd setObject:message forKey:@"message"];
        [GeTuiSdk setBadge:_messageArr.count-1]; //同步本地角标值到服务器
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:_messageArr.count-1];
        if (self.clearBlock) {
            self.clearBlock(indexPath.row);
        }
        [_messageArr removeObjectAtIndex:indexPath.row];
    }
    // 取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MessageDetailsViewController *vc = [[MessageDetailsViewController alloc]init];
    vc.message = allMessage[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
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
