//
//  ChatViewController.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/31.
//  Copyright © 2016年 王迎军. All rights reserved.
//

#import "ContectViewController.h"
#import "SDAutoLayout.h"
#import "ContectChineseToPinyin.h"
#import "ChatOrganizationViewController.h"
#import "ContectInfomationViewController.h"
@interface ContectViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate, UISearchDisplayDelegate>
{
    NSArray *sectiontitle;
}
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *displayController;
@property (strong, nonatomic) NSMutableArray *allData;
@property (strong, nonatomic) NSMutableArray *resultArray;
@property (strong, nonatomic) NSMutableArray *contectArr;
@property (nonatomic,retain) NSMutableArray *LetterResultArr;
@property (nonatomic,retain) NSMutableArray *Lettertitle;
@end

@implementation ContectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"通讯录";
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    self.view.backgroundColor = [UIColor colorWithRed:(247.0 / 255.0f) green:(247.0 /255.0f) blue:(240.0 / 255.0f) alpha:1.0f];
    [self initTableView];
    sectiontitle = @[@"群组"];
}
- (void)initTableView
{
    _tableView = [UITableView new];
    _tableView.backgroundColor = [UIColor colorWithRed:(247.0 / 255.0f) green:(247.0 /255.0f) blue:(240.0 / 255.0f) alpha:1.0f];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.sectionIndexBackgroundColor =[UIColor clearColor];
    _tableView.sectionIndexColor = [UIColor redColor];
    [self.view addSubview:_tableView];
    _tableView.tableFooterView = [self customFooterView];
    _tableView.sd_layout.topEqualToView(self.view).leftEqualToView(self.view).rightEqualToView(self.view).bottomEqualToView(self.view);
    [self initTableViewHeaderView];
    [self initSearchDisplay];
    _allData = [[NSMutableArray alloc] init];
    _Lettertitle = [[NSMutableArray alloc] init];
    _LetterResultArr = [[NSMutableArray alloc] init];
    
    [_allData addObjectsFromArray:@[@"zhang",@"长势",@"xuhang",@"道士",@"王",@"测试"]];
    self.Lettertitle = [ContectChineseToPinyin IndexArray:_allData];
    self.LetterResultArr = [ContectChineseToPinyin LetterSortArray:_allData];
    _contectArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.LetterResultArr count]; i++) {
       [_contectArr addObjectsFromArray:[self.LetterResultArr objectAtIndex:i]];
    }
}
- (void)initTableViewHeaderView
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    self.searchBar.barStyle     = UIBarStyleDefault;
    self.searchBar.translucent  = YES;
    self.searchBar.delegate     = self;
    self.searchBar.placeholder  = @"搜索"; 
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    self.tableView.tableHeaderView = self.searchBar;
}
- (void)initSearchDisplay
{
    self.displayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.displayController.delegate                = self;
    self.displayController.searchResultsDataSource = self;
    self.displayController.searchResultsDelegate   = self;
    self.displayController.searchContentsController.edgesForExtendedLayout = UIRectEdgeNone;
}
#pragma mark - UISearchBar Delegate
/**
 *  搜索开始回调用于更新UI
 *
 *  @param searchBar
 *
 *  @return
 */
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    if ([self.delegate respondsToSelector:@selector(beginSearch:)]) {
        [self.delegate beginSearch:searchBar];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
            [UIView animateWithDuration:0.25 animations:^{
                [self.view setBackgroundColor:RGBColor(198, 198, 203)];
                for (UIView *subview in self.view.subviews){
                    subview.transform = CGAffineTransformMakeTranslation(0, statusBarFrame.size.height);
                }
            }];
        }
    }
    return YES;
}

/**
 *  搜索结束回调用于更新UI
 *
 *  @param searchBar
 *
 *  @return
 */
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    if ([self.delegate respondsToSelector:@selector(endSearch:)]) {
        [self.delegate endSearch:searchBar];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            [UIView animateWithDuration:0.25 animations:^{
                for (UIView *subview in self.view.subviews){
                    subview.transform = CGAffineTransformMakeTranslation(0, 0);
                }
            } completion:^(BOOL finished) {
                [self.view setBackgroundColor:[UIColor whiteColor]];
            }];
        }
    }
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [_resultArray removeAllObjects];
    for (int i = 0; i < _contectArr.count; i++) {
        if ([_contectArr[i] hasPrefix:searchString]) {
            [_resultArray addObject:_contectArr[i]];
        }
    }
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption{
    [self searchDisplayController:controller shouldReloadTableForSearchString:_searchBar.text];
    return YES;
}
#pragma mark tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _tableView)
    {
        return self.Lettertitle.count +1;
    }
    else
    {
        return 1;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tableView)
    {
        if (section == 0 )
        {
            return 1;
        }
        else
        {
            return [[self.LetterResultArr objectAtIndex:section-1] count];
        }
    }
    else
    {
        return _resultArray.count;
    }
   
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 )
    {
        return 0;
    }
    else
    {
        return 20;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
#pragma mark -Section的Header的值
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0 )
    {
        return nil;
    }
    else
    {
        NSString *key = [self.Lettertitle objectAtIndex:section-1];
        return key;
    }
}
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.Lettertitle;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == _tableView) {
        if (section == 0 ){
            return nil;
        }else{
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
            view.backgroundColor = [UIColor colorWithRed:(247.0 / 255.0f) green:(247.0 /255.0f) blue:(240.0 / 255.0f) alpha:1.0f];
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 2.5, tableView.frame.size.width-10, 15)];
            titleLabel.text = [self.Lettertitle objectAtIndex:section-1];
            titleLabel.textColor = [UIColor grayColor];
            [view addSubview:titleLabel];
            return view;
        }
    }else{
        return nil;
    }
   }
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView)
    {
        if (indexPath.section == 0 )
        {
            UITableViewCell *Cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
            if (Cell == nil) {
                Cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
                Cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UIImageView *imageView = [UIImageView new];
                imageView.tag = 101;
                UILabel *titleLabel = [UILabel new];
                titleLabel.tag = 102;
                titleLabel.font = [UIFont systemFontOfSize:18];
                [Cell.contentView sd_addSubviews:@[imageView,titleLabel]];
                imageView.sd_layout.topSpaceToView(Cell.contentView,10).leftSpaceToView(Cell.contentView,15).widthIs(40).heightIs(40);
                titleLabel.sd_layout.topEqualToView(Cell.contentView).bottomEqualToView(Cell.contentView).widthIs([UIScreen mainScreen].bounds.size.width-80).leftSpaceToView(imageView,15);
            }
            UIImageView *imageView = (UIImageView *)[Cell.contentView viewWithTag:101];
            imageView.image = [UIImage imageNamed:@"gpsnormal"];
            UILabel *titleLabel = (UILabel *)[Cell.contentView viewWithTag:102];
            titleLabel.text = sectiontitle[indexPath.section];
            return Cell;
        }
        else
        {
            UITableViewCell *Cell = [tableView dequeueReusableCellWithIdentifier:@"Cell2"];
            if (Cell == nil) {
                Cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell2"];
                Cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UIImageView *imageView = [UIImageView new];
                imageView.tag = 101;
                UILabel *titleLabel = [UILabel new];
                titleLabel.tag = 102;
                titleLabel.font = [UIFont systemFontOfSize:16];
                UILabel *detailLabel = [UILabel new];
                detailLabel.tag = 103;
                detailLabel.font = [UIFont systemFontOfSize:13];
                detailLabel.textColor = RGBColor(180, 180, 180);
                [Cell.contentView sd_addSubviews:@[imageView,titleLabel,detailLabel]];
                imageView.sd_layout.topSpaceToView(Cell.contentView,10).leftSpaceToView(Cell.contentView,15).widthIs(40).heightIs(40);
                titleLabel.sd_layout.topSpaceToView(Cell.contentView,15).leftSpaceToView(imageView,15).widthIs([UIScreen mainScreen].bounds.size.width-80).heightIs(16);
                detailLabel.sd_layout.topSpaceToView(titleLabel,6).leftEqualToView(titleLabel).rightEqualToView(titleLabel).heightIs(13);
            }
            UIImageView *imageView = (UIImageView *)[Cell.contentView viewWithTag:101];
            imageView.image = [UIImage imageNamed:@"gpsnormal"];
            UILabel *titleLabel = (UILabel *)[Cell.contentView viewWithTag:102];
            titleLabel.text = [[self.LetterResultArr objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
            UILabel *detailLabel = (UILabel *)[Cell.contentView viewWithTag:103];
            detailLabel.text = @"测试";
            return Cell;
        }
    }
    else
    {
        static NSString *Identifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = [_resultArray objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
       
    }
    else
    {
        ContectInfomationViewController *chat = [[ContectInfomationViewController alloc] init];
        [self.navigationController pushViewController:chat animated:YES];
    }
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
- (UIView *)customFooterView{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.04*ScreenHeight)];
    headerV.backgroundColor = [UIColor clearColor];
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
