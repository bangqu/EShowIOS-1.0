//
//  DownloadViewController.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/22.
//  Copyright © 2016年 王迎军. All rights reserved.
//

#import "DownloadViewController.h"
#import "ZFDownloadManager.h"
#import "SDAutoLayout.h"
#import "LFLUISegmentedControl.h"
#import "downloadedViewCell.h"
#import "downloadingViewCell.h"
@interface DownloadViewController ()<LFLUISegmentedControlDelegate,ZFDownloadDelegate,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray *notdownloadArr;
@property (strong, nonatomic) NSMutableArray *havedownloadArr;
@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (nonatomic, strong) LFLUISegmentedControl * LFLuisement;
@property (nonatomic, strong) ZFDownloadManager *downloadManage;
@property (strong, nonatomic) UITableView *downloadingView;    //下载中列表数据
@property (strong, nonatomic) UITableView *downloadedView;     //已下载列表数据
@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"下载列表";
    self.view.backgroundColor = RGBColor(247, 247, 240);
    /*分页*/
    LFLUISegmentedControl* LFLuisement=[[LFLUISegmentedControl alloc]initWithFrame:CGRectMake(0, 65, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds))];
    LFLuisement.delegate = self;
    NSArray* LFLarray=[NSArray arrayWithObjects:@"下载中",@"已下载",nil];
    [LFLuisement AddSegumentArray:LFLarray];
    [LFLuisement selectTheSegument:0];
    self.LFLuisement = LFLuisement;
    [self.view addSubview:LFLuisement];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.downloadManage.downloadDelegate = self;
    [self createMainScrollView];
}
#pragma mark segment
//创建正文ScrollView内容
- (void)createMainScrollView {
    self.mainScrollView = [UIScrollView new];
    self.mainScrollView.backgroundColor = RGBColor(247, 247, 240);
    self.mainScrollView.bounces = NO;
    self.mainScrollView.pagingEnabled = YES;
    self.mainScrollView.contentSize = CGSizeMake(ScreenWidth *2, ScreenHeight-44);
    self.mainScrollView.scrollEnabled = NO;
    self.mainScrollView.delegate = self;
    [self.view addSubview:self.mainScrollView];
    self.mainScrollView.sd_layout.topSpaceToView(self.LFLuisement,0).leftEqualToView(self.view).rightEqualToView(self.view).bottomEqualToView(self.view);
    _downloadingView = [UITableView new];
    _downloadingView.backgroundColor = RGBColor(247, 247, 240);
    _downloadingView.delegate = self;
    _downloadingView.dataSource = self;

    [self.mainScrollView addSubview:_downloadingView];
    _downloadingView.sd_layout.topEqualToView(self.mainScrollView).leftEqualToView(self.mainScrollView).widthIs(ScreenWidth).bottomEqualToView(self.mainScrollView);
    _downloadingView.tableHeaderView = [self customHeaderView];
    _downloadingView.tableFooterView = [self customFootherView];
    _downloadedView = [UITableView new];
    _downloadedView.backgroundColor = RGBColor(247, 247, 240);
    _downloadedView.delegate = self;
    _downloadedView.dataSource = self;
    [self.mainScrollView addSubview:_downloadedView];
    _downloadedView.sd_layout.topEqualToView(self.mainScrollView).leftSpaceToView(self.mainScrollView,ScreenWidth).widthIs(ScreenWidth).bottomEqualToView(self.mainScrollView);
    _downloadedView.tableHeaderView = [self customHeaderView];
    _downloadedView.tableFooterView = [self customFootherView];
    
}
//初始化下载中的数据
- (void)initHaveDownloadData
{
    [self.downloadManage startLoad];
    self.havedownloadArr = @[].mutableCopy;
    NSMutableArray *downladed = self.downloadManage.finishedlist;
    NSMutableArray *downloading = self.downloadManage.downinglist;
    [_havedownloadArr addObject:downloading];
    [_havedownloadArr addObject:downladed];
//    _havedownloadArr = self.downloadManage.downinglist;
//   _notdownloadArr = self.downloadManage.finishedlist;
    [_downloadingView reloadData];
    [_downloadedView reloadData];
}
//初始化已下载的数据
- (void)initDidnotDownloadData
{
    [self.downloadManage startLoad];
     _notdownloadArr = self.downloadManage.finishedlist;
    [_downloadedView reloadData];
}
- (ZFDownloadManager *)downloadManage
{
    if (!_downloadManage) {
        _downloadManage = [ZFDownloadManager sharedDownloadManager];
    }
    return _downloadManage;
}
-(void)uisegumentSelectionChange:(NSInteger)selection{
    //加入动画,显得不太过于生硬切换
    [UIView animateWithDuration:.2 animations:^{
        [self.mainScrollView setContentOffset:CGPointMake(ScreenWidth *selection, 0)];
    }];
//    if (selection == 0)
//    {
        [self initHaveDownloadData];
//    }
//    else
//    {
//        [self initDidnotDownloadData];
//    }
}
#pragma mark - tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _downloadingView)
    {
        return [_havedownloadArr[0] count];
    }
    else
    {
        return [_havedownloadArr[1] count];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _downloadingView)
    {
        [_downloadingView registerNib:[UINib nibWithNibName:@"downloadingViewCell" bundle:nil] forCellReuseIdentifier:@"downloadingViewCell"];
        downloadingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"downloadingViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        ZFHttpRequest *request = self.havedownloadArr[0][indexPath.row];
        if (request == nil) { return nil; }
        ZFFileModel *fileInfo = [request.userInfo objectForKey:@"File"];
        
        __weak typeof(self) weakSelf = self;
        // 下载按钮点击时候的要刷新列表
        cell.btnClickBlock = ^{
            [weakSelf initHaveDownloadData];
        };
        // 下载模型赋值
        cell.fileInfo = fileInfo;
        // 下载的request
        cell.request = request;
        return cell;
    }
    else
    {
        [_downloadedView registerNib:[UINib nibWithNibName:@"downloadedViewCell" bundle:nil] forCellReuseIdentifier:@"downloadedViewCell"];
        downloadedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"downloadedViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        ZFFileModel *fileInfo = self.havedownloadArr[1][indexPath.row];
        cell.fileInfo = fileInfo;
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _downloadingView)
    {
        return 90;
    }
    return 70;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _downloadingView) {
        ZFHttpRequest *request = self.havedownloadArr[0][indexPath.row];
        [self.downloadManage deleteRequest:request];
        
    }else if (tableView == _downloadedView) {
        ZFFileModel *fileInfo = self.havedownloadArr[1][indexPath.row];
        [self.downloadManage deleteFinishFile:fileInfo];

    }
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
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
    if ([_downloadingView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_downloadingView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([_downloadingView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_downloadingView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
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
#pragma mark - ZFDownloadDelegate

// 开始下载
- (void)startDownload:(ZFHttpRequest *)request
{
    NSLog(@"开始下载!");
}

// 下载中
- (void)updateCellProgress:(ZFHttpRequest *)request
{
    ZFFileModel *fileInfo = [request.userInfo objectForKey:@"File"];
    [self performSelectorOnMainThread:@selector(updateCellOnMainThread:) withObject:fileInfo waitUntilDone:YES];
}

// 下载完成
- (void)finishedDownload:(ZFHttpRequest *)request
{
    [self initHaveDownloadData];
}

// 更新下载进度
- (void)updateCellOnMainThread:(ZFFileModel *)fileInfo
{
    NSArray *cellArr = [self.downloadingView visibleCells];
    for (id obj in cellArr)
    {
        if ([obj isKindOfClass:[downloadingViewCell class]])
        {
            downloadingViewCell *cell = (downloadingViewCell *)obj;
            if ([cell.fileInfo.fileURL isEqualToString:fileInfo.fileURL])
            {
                cell.fileInfo = fileInfo;
            }
            
        }
//         [self.downloadingView reloadData]; 
    }
  
//    for (id obj in cellArr) {
//        if([obj isKindOfClass:[downloadedViewCell class]]) {
//            downloadedViewCell *cell = (downloadedViewCell *)obj;
//            if([cell.fileInfo.fileURL isEqualToString:fileInfo.fileURL]) {
//                cell.fileInfo = fileInfo;
//            }
//        }
//    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initHaveDownloadData];
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
