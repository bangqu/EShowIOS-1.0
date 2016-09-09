//
//  DowmMenuView.m
//  EShowIOS
//
//  Created by 王迎军 on 16/9/8.
//  Copyright © 2016年 金璟. All rights reserved.
//
#define JHMargin 10
#import "DowmMenuView.h"
@interface DowmMenuView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;

@end
@implementation DowmMenuView

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]init];
        
        [self addSubview:_tableView];
    }
    return _tableView;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        self.tableView.frame = CGRectMake(0, JHMargin, self.bounds.size.width, self.bounds.size.height - JHMargin);
        
        self.tableView.layer.cornerRadius = 10;
        self.tableView.clipsToBounds = YES;
        
        self.dataArray = @[@"扫一扫",
                           @"加好友",
                           @"创建讨论组",
                           @"发送到电脑",
                           @"面对面快传",
                           @"收钱"];
        
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellid = @"idx";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellid];
    }
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

- (void)drawRect:(CGRect)rect
{
    // 背景色
    [[UIColor whiteColor] set];
    
    // 获取视图
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // 开始绘制
    CGContextBeginPath(contextRef);
    
    CGContextMoveToPoint(contextRef, self.bounds.size.width - 40, self.tableView.frame.origin.y);
    CGContextAddLineToPoint(contextRef, self.bounds.size.width - 20, self.tableView.frame.origin.y);
    CGContextAddLineToPoint(contextRef, self.bounds.size.width - 20 * 1.5, self.tableView.frame.origin.y - JHMargin);
    // 结束绘制
    CGContextClosePath(contextRef);
    // 填充色
    [[UIColor whiteColor] setFill];
    // 边框颜色
    [[UIColor whiteColor] setStroke];
    // 绘制路径
    CGContextDrawPath(contextRef, kCGPathFillStroke);
    
}


@end
