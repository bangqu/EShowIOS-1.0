//
//  MusicListViewController.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/19.
//  Copyright © 2016年 王迎军. All rights reserved.
//

#import "MusicListViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "MusicModel.h"
#import "SDAutoLayout.h"
#import "UIImageView+WebCache.h"
#import "AudioPlayerViewController.h"
@interface MusicListViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *musicList;
}

@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;

@end

@implementation MusicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor colorWithRed:(247.0 / 255.0f) green:(247.0 /255.0f) blue:(240.0 / 255.0f) alpha:1.0f];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _myTableView.tableHeaderView = [self customHeaderView];
    _myTableView.tableFooterView = [self customFootherView];
    [self addDataJson];
}
- (void)addDataJson
{
    musicList = [[NSMutableArray alloc] init];
    NSString *str = [[NSBundle mainBundle]pathForResource:@"musicPaper" ofType:@"json"];
    NSData *data = [[NSData alloc]initWithContentsOfFile:str];
    
    NSMutableArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"%@,  ---%ld",dataArray, dataArray.count);
    //    [self.songArray addObject:dic];
    for (NSDictionary *dic in dataArray) {
        MusicModel *model = [[MusicModel alloc] init];
        [model setValuesForKeysWithDictionary:dic];
        [musicList addObject:model];
    }
    [self.myTableView reloadData];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return musicList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7.5, 45, 45)];
        imageView.tag = 101;
//        imageView.backgroundColor = [UIColor grayColor];
        imageView.layer.cornerRadius = 5.0;
        [cell.contentView addSubview:imageView];
        UILabel *musicName = [UILabel new];
        musicName.tag = 102;
        musicName.font = [UIFont systemFontOfSize:16.0];
        [cell.contentView addSubview:musicName];
        musicName.sd_layout.leftSpaceToView(imageView,12).topSpaceToView(cell.contentView,8).widthIs(200).heightIs(21);
        UILabel *singerName = [[UILabel alloc] init];
        singerName.tag = 103;
        singerName.font = [UIFont systemFontOfSize:12.0];
        singerName.textColor = RGBColor(16, 16, 16);
        [cell.contentView addSubview:singerName];
        singerName.sd_layout.topSpaceToView(musicName,4).leftEqualToView(musicName).widthIs(100).heightIs(15);
    }
    MusicModel *model = [[MusicModel alloc] init];
    model = [musicList objectAtIndex:indexPath.row];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:101];
    [imageView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"address"]];
    UILabel *musicName = (UILabel *)[cell.contentView viewWithTag:102];
    musicName.text = model.name;
    UILabel *singerName = (UILabel *)[cell.contentView viewWithTag:103];
    singerName.text = model.singer;
//    cell.textLabel.text = [NSString stringWithFormat:@"%@_%@_%@", model.music_id, model.name, model.singer];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AudioPlayerViewController *audio = [AudioPlayerViewController audioPlayerController];
    [audio initWithArray:musicList index:indexPath.row];
    [self.navigationController pushViewController:audio animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

- (UIView *)customHeaderView{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.02*ScreenHeight)];
    headerV.backgroundColor = [UIColor clearColor];
    return headerV;
}
- (UIView *)customFootherView
{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.04*ScreenHeight)];
    headerV.backgroundColor = [UIColor clearColor];
    return headerV;
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
