//
//  ImageListViewController.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/2.
//  Copyright © 2016年 王迎军. All rights reserved.
//

#import "ImageListViewController.h"
#import "NetworkEngine.h"
#import "ImageListModel.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "FRDLivelyButton.h"
#import "SDRotationLoopProgressView.h"
#import "ImageListCollectionViewCell.h"
#import "ImageSaveViewController.h"
#import "ImageInfomationViewController.h"
#import "UIImageView+WebCache.h"
#define IDENTIFIER_CELL @"homeMenuCell"
@interface ImageListViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    ImageListModel *_imageModel;
    NSMutableArray *_dataArray;
    UICollectionView *_collectionView;
    NSInteger _page;          //当前的页数
    NSString *userID;         //登陆返回的id
    ImageListModel *model;
}
@property (nonatomic, strong) FRDLivelyButton *rightNavBtn;
@property (nonatomic, strong) MJRefreshComponent *myRefreshView;

@end

@implementation ImageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"相册";
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    _rightNavBtn = [[FRDLivelyButton alloc] initWithFrame:CGRectMake(0,0,18.5,18.5)];
    [_rightNavBtn setOptions:@{ kFRDLivelyButtonLineWidth: @(1.0f),
                                kFRDLivelyButtonColor: [UIColor colorWithRed:(247 / 255.0f) green:(105 / 255.0f) blue:(86 / 255.0f) alpha:1]
                                }];
    [_rightNavBtn setStyle:kFRDLivelyButtonStylePlus animated:NO];
    [_rightNavBtn addTarget:self action:@selector(addItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightNavBtn];
    self.navigationItem.rightBarButtonItem = buttonItem;

    _page = 1;
    _dataArray = [[NSMutableArray alloc] init];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    userID = [userDefault objectForKey:@"user.userid"];
//    NSMutableArray *NewArrList = [NSMutableArray new];
//    for (int i =0 ; i < 10; i ++)
//    {
//        UIImage *image = [UIImage imageNamed:@"NewImage.jpg"];
//        [NewArrList addObject:image];
//    }
//    _dataArray = NewArrList;
    [_dataArray addObjectsFromArray:[self creatModelsWithCount:self.dateArr.count andData:self.dateArr]];
    [self initCollectionView];
}
#pragma mark Model
- (NSMutableArray *)creatModelsWithCount:(NSInteger)count andData:(NSArray *)arr
{
    NSMutableArray *resArr = [NSMutableArray new];
    for (int i = 0; i < count; i ++)
    {
        ImageListModel *imagemodel = [ImageListModel new];
        imagemodel.image_id = arr[i][@"id"];
        imagemodel.image_icon = @"";
//        if(![arr[i][@"img"] isKindOfClass:[NSNull class]])
//        {
//            imagemodel.image_icon = arr[i][@"img"];
//        }
        imagemodel.image_title = arr[i][@"name"];
        imagemodel.image_addTime = arr[i][@"addTime"];
        imagemodel.image_updateTime = arr[i][@"updateTime"];
        imagemodel.image_description = arr[i][@"description"];
        [resArr addObject:imagemodel];
    }
    return [resArr copy];
}
- (void)addItemClicked:(id)sender
{
    ImageSaveViewController *save = [[ImageSaveViewController alloc] init];
    [self.navigationController pushViewController:save animated:YES];
}
- (void)initCollectionView
{
    //创建布局
    CGFloat w = ([UIScreen mainScreen].bounds.size.width-80)/2.0 ;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(w, w);
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor colorWithRed:242/255.0 green:245/255.0 blue:233/255.0 alpha:1.0f];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    //注册重复使用的cell
    [_collectionView registerClass:[ImageListCollectionViewCell class] forCellWithReuseIdentifier:@"NewCell"];
    
//    //注册重复使用的headerView和footerView
//    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reuseHeader"];
//    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"reuseFooter"];
    //下拉刷新
    __weak typeof(self) weakSelf = self;
    _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.myRefreshView = _collectionView.mj_header;
        _page = 2;
        [weakSelf loadData];
    }];
    // 马上进入刷新状态
//    [_collectionView.mj_header beginRefreshing];
    
    //..上拉刷新
    _collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        weakSelf.myRefreshView = _collectionView.mj_footer;
        _page = _page + 10;
        [weakSelf loadData];
    }];
    
    _collectionView.mj_footer.hidden = NO;
    //添加长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [_collectionView addGestureRecognizer:longPress];
}
- (void)loadData
{
    //..下拉刷新
    if (self.myRefreshView == _collectionView.mj_header) {
 
        [[NetworkEngine sharedManager] getImageListBySearch:@{
                                                              @"query.begin":@"2",
                                                              
                                                              }
                                                        url:[NSString stringWithFormat:@"%@album/search.json",BaseUrl]
                                               successBlock:^(id responseBody){
                                                   
                                                   NSLog(@"%@",responseBody);
                                                   NSMutableArray *NewArrList = [NSMutableArray new];
                                                   NewArrList=[NSMutableArray objectArrayWithKeyValuesArray:[responseBody objectForKey:@"albums"]];
                                                   _dataArray = [[NSMutableArray alloc] initWithArray:[self creatModelsWithCount:NewArrList.count andData:[NewArrList copy]]];
                                                   _collectionView.mj_footer.hidden = _dataArray.count==0?YES:NO;
                                                   [self doneWithView:self.myRefreshView];
                                               }
                                               failureBlock:^(NSString *error){
                                                   [self doneWithView:self.myRefreshView];
                                                   
                                               }];
        
    }else if(self.myRefreshView == _collectionView.mj_footer){
        //上拉刷新
            [[NetworkEngine sharedManager] getImageListBySearch:@{
                                                                  @"query.begin":@"2",
                                                                  
                                                                  }
                                                            url:[NSString stringWithFormat:@"%@album/search.json",BaseUrl]
                                                   successBlock:^(id responseBody){
                                                       
                                                       NSLog(@"%@",responseBody);
                                                       NSMutableArray *NewArrList = [NSMutableArray new];
                                                       NewArrList=[NSMutableArray objectArrayWithKeyValuesArray:[responseBody objectForKey:@"albums"]];
                                                       [_dataArray addObjectsFromArray:[self creatModelsWithCount:NewArrList.count andData:[NewArrList copy]]];
                                                       [self doneWithView:self.myRefreshView];
                                                   }
                                                   failureBlock:^(NSString *error){
                                                       [self doneWithView:self.myRefreshView];
                                                   }];
    }
    

}
-(void)doneWithView:(MJRefreshComponent*)refreshView{
    _collectionView.bounces = YES;
    [_collectionView reloadData];
    [_myRefreshView  endRefreshing];
}
#pragma mark - CollectionView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat height = scrollView.frame.size.height;
    CGFloat contentYoffset = scrollView.contentOffset.y;
    CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;
//    NSLog(@"height:%f contentYoffset:%f frame.y:%f",height,contentYoffset,scrollView.frame.origin.y);
    if (distanceFromBottom < height) {
        _collectionView.bounces = NO;
    }
}
#pragma mark- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NewCell" forIndexPath:indexPath];
    [cell setContentWith:_dataArray[indexPath.item]];
    return cell;
}
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;     //视图是否支持拖动
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath{
    id obj = [_dataArray objectAtIndex:sourceIndexPath.item];
    [_dataArray removeObject:obj];
    [_dataArray insertObject:obj atIndex:destinationIndexPath.item];
}

//设置headerView和footerView
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
//    UICollectionReusableView *reusableView;
//    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
//        reusableView = [_collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reuseHeader" forIndexPath:indexPath];
//        UILabel *lab = [[UILabel alloc] init];
//        lab.text = @"头部";
//        [reusableView addSubview:lab];
//        [lab mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(reusableView);
//        }];
//        //        reusableView.backgroundColor = [UIColor redColor];
//    }else{
//        reusableView = [_collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"reuseFooter" forIndexPath:indexPath];
//        UILabel *lab = [[UILabel alloc] init];
//        lab.text = @"尾部";
//        [reusableView addSubview:lab];
//        [lab mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(reusableView);
//        }];
//        
//        //        reusableView.backgroundColor = [UIColor yellowColor];
//    }
//    return reusableView;
//}

#pragma mark - UICollectionViewDelegateFlowLayout
//设置cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size = CGSizeMake(([UIScreen mainScreen].bounds.size.width-80)/2.0, ([UIScreen mainScreen].bounds.size.width-80)/2.0);
    return size;
}

//设置cell与边缘的间隔
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 26, 0, 26);
    return inset;
}
//最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 37;
}

//最小列间距
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
////    return 35;
//}

//设置header高度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGSize size = CGSizeMake(0, 26);
    return size;
}
//设置footer高度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    CGSize size = CGSizeMake(0, 26);
    return size;
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.navigationController pushViewController:[ImageInfomationViewController demoCollectionViewController] animated:YES];
}
#pragma mark CollectionView长按效果
- (void)longPress:(UILongPressGestureRecognizer *)longPress{
    UIGestureRecognizerState state = longPress.state;
    switch (state) {
        case UIGestureRecognizerStateBegan:{
            CGPoint pressPoint = [longPress locationInView:_collectionView];
            NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:pressPoint];
            if (!indexPath) {
                break;
            }
            [_collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            CGPoint pressPoint = [longPress locationInView:_collectionView];
            [_collectionView updateInteractiveMovementTargetPosition:pressPoint];
            break;
        }
        case UIGestureRecognizerStateEnded:{
            [_collectionView endInteractiveMovement];
            break;
        }
        default:
            [_collectionView cancelInteractiveMovement];
            break;
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
