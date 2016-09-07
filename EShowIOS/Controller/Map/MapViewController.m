//
//  MapViewController.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/11.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import "MapViewController.h"
#import <CoreText/CoreText.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "AMapTipAnnotation.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "POIAnnotation.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "LFLUISegmentedControl.h"
#import "AFNetworking.h"
@interface MapViewController () <MAMapViewDelegate, AMapSearchDelegate,UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate,UIScrollViewDelegate,LFLUISegmentedControlDelegate>
{
    BOOL allTypeBOOL,officeBOOL,houseBOOL,schoolBOOL;
    float latitudefloat,longitudefloat;
}
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *displayController;
@property (nonatomic, strong) NSMutableArray *tips;           //搜索结果数据
@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) LFLUISegmentedControl * LFLuisement;
@property (nonatomic, strong) UIImageView  *redWaterView;     //可拖动的图标
@property (nonatomic, assign) BOOL  FirstLogin;
@property (nonatomic, assign) BOOL  isMapViewRegionChangedFromTableView;  //是否拖动图片
@property (nonatomic, assign) BOOL  isLocated;                //位置是否变更
@property (nonatomic, strong) UIButton *locationBtn;          //回到当前位置
@property (nonatomic, strong) UIImage *imageLocated;          //回到当前位置点击状态
@property (nonatomic, strong) UIImage *imageNotLocate;        //回到当前位置未点击状态
@property (nonatomic, strong) UITableView *AllMap_vc;         //全部
@property (nonatomic, strong) UITableView *office_vc;         //写字楼
@property (nonatomic, strong) UITableView *house_vc;          //小区
@property (nonatomic, strong) UITableView *school_vc;         //学校
@property (nonatomic, strong) NSMutableArray *AllMap_arr;     //全部的列表数据
@property (nonatomic, strong) NSMutableArray *OfficeMap_arr;  //写字楼数据
@property (nonatomic, strong) NSMutableArray *SchoolMap_arr;  //学校数据
@property (nonatomic, strong) NSMutableArray *HouseMap_arr;   //小区数据
@end

@implementation MapViewController
@synthesize mapView = _mapView;
@synthesize search  = _search;

- (id)init
{
    if (self = [super init])
    {
        self.tips = [NSMutableArray array];
        self.AllMap_arr = [NSMutableArray array];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"地图";
    allTypeBOOL = YES;officeBOOL = NO;houseBOOL = NO;schoolBOOL = NO;
    _FirstLogin = YES;
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight/2 + 64)];
    self.mapView.delegate = self;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    self.mapView.zoomLevel = 17;
    self.mapView.customizeUserLocationAccuracyCircleRepresentation = YES;
    if (_latitude_str.length > 0)
    {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([self.latitude_str floatValue], [self.longitude_str floatValue]);
        // 显示尺寸span
        MACoordinateSpan span = MACoordinateSpanMake(0.04, 0.04);
        self.mapView.region = MACoordinateRegionMake(coordinate,span);
    }
    else
    {
        self.mapView.showsUserLocation = YES;//打开定位
    }
    [self.view addSubview:self.mapView];
    //搜索
    [self initSearchBar];
    [self initSearchDisplay];
    [self initRedWaterView];
    [self initLocationButton];
    /*分页*/
    LFLUISegmentedControl* LFLuisement=[[LFLUISegmentedControl alloc]initWithFrame:CGRectMake(0, ScreenHeight/2, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds))];
    LFLuisement.delegate = self;
    NSArray* LFLarray=[NSArray arrayWithObjects:@"全部",@"写字楼",@"小区",@"学校",nil];
    [LFLuisement AddSegumentArray:LFLarray];
    [LFLuisement selectTheSegument:0];
    self.LFLuisement = LFLuisement;
    [self.view addSubview:LFLuisement];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self createMainScrollView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _mapView.showsUserLocation = NO;
}
#pragma mark search
#pragma mark - Initialization
- (void)initSearchBar
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    self.searchBar.barStyle     = UIBarStyleDefault;
    self.searchBar.translucent  = YES;
    self.searchBar.delegate     = self;
    self.searchBar.placeholder  = @"搜索";
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    
    [self.view addSubview:self.searchBar];
}
- (void)initSearchDisplay
{
    self.displayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.displayController.delegate                = self;
    self.displayController.searchResultsDataSource = self;
    self.displayController.searchResultsDelegate   = self;
    self.displayController.searchContentsController.edgesForExtendedLayout = UIRectEdgeNone;
}
#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *key = searchBar.text;
    /* 按下键盘enter, 搜索poi */
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    request.keywords         = key;
    request.city             = @"010";
    request.requireExtension = YES;
    [self.search AMapPOIKeywordsSearch:request];
    [self.displayController setActive:NO animated:NO];
    self.searchBar.placeholder = key;
}
#pragma mark - UISearchDisplayDelegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self searchTipsWithKey:searchString];
    return YES;
}
/* 输入提示 搜索.*/
- (void)searchTipsWithKey:(NSString *)key
{
    if (key.length == 0)
    {
        return;
    }
    //配置用户Key
    [AMapServices sharedServices].apiKey = @"f912d3064492b7d1102a9bc6de5b77c1";
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    //发起输入提示搜索
    AMapInputTipsSearchRequest *tips = [[AMapInputTipsSearchRequest alloc] init];
    tips.keywords = key;
    [self.search AMapInputTipsSearch:tips];
}
- (void)searchReGeocodeWithlatitude:(float)latitude andlongitude:(float)longitude
{
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = [AMapGeoPoint locationWithLatitude:latitude longitude:longitude];
    regeo.requireExtension = YES;
    [self.search AMapReGoecodeSearch:regeo];
}
#pragma mark - MapViewDelegate
//定位回调 获取当前坐标
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if(!updatingLocation)
        return ;
    if (userLocation.location.horizontalAccuracy < 0)
    {
        return ;
    }
    if (!self.isLocated)
    {
        self.isLocated = YES;
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude)];
    }
}
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (!self.isMapViewRegionChangedFromTableView)
    {
        if (_FirstLogin == YES &&_latitude_str.length > 0)
        {
            [self searchReGeocodeWithlatitude:[_latitude_str floatValue] andlongitude:[_latitude_str floatValue]];
        }
        else
        {
            [self searchReGeocodeWithlatitude:self.mapView.centerCoordinate.latitude andlongitude:self.mapView.centerCoordinate.longitude];
        }
        latitudefloat = self.mapView.centerCoordinate.latitude;
        longitudefloat = self.mapView.centerCoordinate.longitude;
        if (allTypeBOOL == YES)
        {
            if (_FirstLogin == YES &&_latitude_str.length > 0)
            {
                [self UpDateForMapWithlatitude:[_latitude_str floatValue] Withlongitude:[_longitude_str floatValue]];
                _FirstLogin = NO;
            }
            else
            {
                 [self UpDateForMapWithlatitude:self.mapView.centerCoordinate.latitude Withlongitude:self.mapView.centerCoordinate.longitude];
            }
        }
        if (officeBOOL == YES)
        {
            [self UpdateForOfficeMapWithlatitude:self.mapView.centerCoordinate.latitude Withlongitude:self.mapView.centerCoordinate.longitude];
        }
        if (houseBOOL == YES)
        {
            [self UpdateForHouseMapWithlatitude:self.mapView.centerCoordinate.latitude Withlongitude:self.mapView.centerCoordinate.longitude];
        }
        if (schoolBOOL == YES)
        {
            [self UpdateForSchoolMapWithlatitude:self.mapView.centerCoordinate.latitude Withlongitude:self.mapView.centerCoordinate.longitude];
        }
        [self.locationBtn setImage:self.imageNotLocate forState:UIControlStateNormal];
    }
    self.isMapViewRegionChangedFromTableView = NO;
}
- (void)mapView:(MAMapView *)mapView  didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated
{
    if (mode == MAUserTrackingModeFollow && self.mapView.userTrackingMode == MAUserTrackingModeNone)
    {
        [self.locationBtn setImage:self.imageNotLocate forState:UIControlStateNormal];
    }
    else
    {
        [self.locationBtn setImage:self.imageLocated forState:UIControlStateNormal];
    }
}
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"error = %@",error);
}
#pragma mark - AMapSearchDelegate
/* 输入提示回调. */
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response
{
    [self.tips setArray:response.tips];
    [self.displayController.searchResultsTableView reloadData];
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _AllMap_vc) {
        return self.AllMap_arr.count;
    }else if (tableView == _office_vc){
        return self.OfficeMap_arr.count;
    }else if (tableView == _house_vc){
        return self.HouseMap_arr.count;
    }else if (tableView == _school_vc){
        return self.SchoolMap_arr.count;
    }else{
        return self.tips.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _AllMap_vc) {
        static NSString *cellIdentifier = @"firstTableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:cellIdentifier];
            UILabel *poiName = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, [UIScreen mainScreen].bounds.size.width-40, 30)];
            poiName.tag = 101;
            poiName.textColor = [UIColor blackColor];
            [cell.contentView addSubview:poiName];
            cell.imageView.image = [UIImage imageNamed:@"address"];
        }
        AMapPOI *poi = self.AllMap_arr[indexPath.row];
        UILabel *poiName = (UILabel *)[cell.contentView viewWithTag:101];
        if (indexPath.row == 0)
        {
            poiName.attributedText = [self setAttributedStringWithString:poi.name];
        }
        else
        {
            poiName.text = poi.name;
        }
        return cell;
    }else if (tableView == _office_vc){
        static NSString *cellIdentifier = @"secondTableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:cellIdentifier];
            UILabel *poiName = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, [UIScreen mainScreen].bounds.size.width-40, 30)];
            poiName.tag = 101;
            poiName.textColor = [UIColor blackColor];
            [cell.contentView addSubview:poiName];
            cell.imageView.image = [UIImage imageNamed:@"address"];
        }
        AMapPOI *poi = self.OfficeMap_arr[indexPath.row];
        UILabel *poiName = (UILabel *)[cell.contentView viewWithTag:101];
        if (indexPath.row == 0)
        {
            poiName.attributedText = [self setAttributedStringWithString:poi.name];
        }
        else
        {
            poiName.text = poi.name;
        }
        return cell;
    }else if (tableView == _house_vc){
        static NSString *cellIdentifier = @"ThirdTableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:cellIdentifier];
            UILabel *poiName = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, [UIScreen mainScreen].bounds.size.width-40, 30)];
            poiName.tag = 101;
            poiName.textColor = [UIColor blackColor];
            [cell.contentView addSubview:poiName];
            cell.imageView.image = [UIImage imageNamed:@"address"];
        }
        AMapPOI *poi = self.HouseMap_arr[indexPath.row];
        UILabel *poiName = (UILabel *)[cell.contentView viewWithTag:101];
        if (indexPath.row == 0)
        {
            poiName.attributedText = [self setAttributedStringWithString:poi.name];
        }
        else
        {
            poiName.text = poi.name;
        }
        return cell;
    }else if (tableView == _school_vc){
        static NSString *cellIdentifier = @"fourTableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:cellIdentifier];
            UILabel *poiName = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, [UIScreen mainScreen].bounds.size.width-40, 30)];
            poiName.tag = 101;
            poiName.textColor = [UIColor blackColor];
            [cell.contentView addSubview:poiName];
            cell.imageView.image = [UIImage imageNamed:@"address"];
        }
        AMapPOI *poi = self.SchoolMap_arr[indexPath.row];
        UILabel *poiName = (UILabel *)[cell.contentView viewWithTag:101];
        if (indexPath.row == 0)
        {
            poiName.attributedText = [self setAttributedStringWithString:poi.name];
        }
        else
        {
            poiName.text = poi.name;
        }
        return cell;
    }else{
        static NSString *tipCellIdentifier = @"tipCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tipCellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:tipCellIdentifier];
            cell.imageView.image = [UIImage imageNamed:@"address"];
        }
        AMapTip *tip = self.tips[indexPath.row];
        if (tip.location == nil)
        {
            cell.imageView.image = [UIImage imageNamed:@"search"];
        }
        cell.textLabel.text = tip.name;
        cell.textLabel.textColor = [UIColor orangeColor];
        cell.detailTextLabel.text = tip.district;
        cell.detailTextLabel.textColor = [UIColor orangeColor];
        return cell;
    }
}
-(void)viewDidLayoutSubviews
{
    if ([_AllMap_vc respondsToSelector:@selector(setSeparatorInset:)]) {
        [_AllMap_vc setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    if ([_AllMap_vc respondsToSelector:@selector(setLayoutMargins:)]) {
        [_AllMap_vc setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
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
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:_AllMap_vc])
    {
        [self addAmapTip:_AllMap_arr[indexPath.row]];
    }
    else if ([tableView isEqual:_office_vc])
    {
        [self addAmapTip:_OfficeMap_arr[indexPath.row]];
    }
    else if ([tableView isEqual:_house_vc])
    {
        [self addAmapTip:_HouseMap_arr[indexPath.row]];
    }
    else if ([tableView isEqual:_school_vc])
    {
        [self addAmapTip:_SchoolMap_arr[indexPath.row]];
    }
    else
    {
        [self.displayController setActive:NO animated:NO];;
        [self addAmapTip:_tips[indexPath.row]];
    }
}
- (NSAttributedString *)setAttributedStringWithString:(NSString *)string
{
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[string dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSPlainTextDocumentType } documentAttributes:nil error:nil];
    NSMutableAttributedString *newattri = [[NSMutableAttributedString alloc] initWithData:[@"[当前]" dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute:NSPlainTextDocumentType } documentAttributes:nil error:nil];
    NSRange redRange = NSMakeRange(0, newattri.length);
    [newattri addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0/255.0 green:113/255.0 blue:227/255.0 alpha:1.0] range:redRange];
    [newattri appendAttributedString:attrStr];
    [newattri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, newattri.length)];
    return newattri;
}
/* 清除annotations & overlays */
- (void)clear
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
}

- (void)clearAndShowAnnotationWithTip:(AMapTip *)tip
{
    /* 清除annotations & overlays */
    [self clear];
    if (tip.uid != nil && tip.location != nil) /* 可以直接在地图打点  */
    {
        AMapTipAnnotation *annotation = [[AMapTipAnnotation alloc] initWithMapTip:tip];
        [self.mapView addAnnotation:annotation];
        [self.mapView setCenterCoordinate:annotation.coordinate];
        [self.mapView selectAnnotation:annotation animated:YES];
    }
    else if (tip.uid != nil && tip.location == nil)/* 公交路线，显示出来*/
    {
        AMapBusLineIDSearchRequest *request = [[AMapBusLineIDSearchRequest alloc] init];
        request.city                        = @"北京";
        request.uid                         = tip.uid;
        request.requireExtension            = YES;
        
        [self.search AMapBusLineIDSearch:request];
    }
    else if(tip.uid == nil && tip.location == nil)/* 品牌名，进行POI关键字搜索 */
    {
        AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
        request.keywords         = tip.name;
        request.city             = @"010";
        request.requireExtension = YES;
        [self.search AMapPOIKeywordsSearch:request];
    }
}

#pragma mark segment
//创建正文ScrollView内容
- (void)createMainScrollView {
    self.mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, ScreenHeight/2 + 44, ScreenWidth,ScreenHeight/2 - 44)];
    self.mainScrollView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.mainScrollView];
    self.mainScrollView.bounces = NO;
    self.mainScrollView.pagingEnabled = YES;
    self.mainScrollView.contentSize = CGSizeMake(ScreenWidth * 4, ScreenHeight/2-44);
    self.mainScrollView.scrollEnabled = NO;
    //设置代理
    self.mainScrollView.delegate = self;
    _AllMap_vc = [[UITableView alloc]initWithFrame:CGRectMake(ScreenWidth * 0, 0, ScreenWidth,self.mainScrollView.frame.size.height-64)];
    _AllMap_vc.delegate = self;
    _AllMap_vc.dataSource = self;
    [self.mainScrollView addSubview:_AllMap_vc];
    
    _office_vc = [[UITableView alloc] initWithFrame:CGRectMake(ScreenWidth * 1, 0, ScreenWidth, self.mainScrollView.frame.size.height-64)];
    _office_vc.delegate = self;
    _office_vc.dataSource = self;
    [self.mainScrollView addSubview:_office_vc];
    
    _house_vc = [[UITableView alloc] initWithFrame:CGRectMake(ScreenWidth * 2, 0, ScreenWidth, self.mainScrollView.frame.size.height-64)];
    _house_vc.delegate = self;
    _house_vc.dataSource = self;
    [self.mainScrollView addSubview:_house_vc];
    
    _school_vc = [[UITableView alloc] initWithFrame:CGRectMake(ScreenWidth * 3, 0, ScreenWidth, self.mainScrollView.frame.size.height-64)];
    _school_vc.delegate = self;
    _school_vc.dataSource = self;
    [self.mainScrollView addSubview:_school_vc];
}

#pragma mark --- UIScrollView代理方法

//static NSInteger pageNumber = 0;
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    pageNumber = (int)(scrollView.contentOffset.x / ScreenWidth + 0.5);
//    //    滑动SV里视图,切换标题
//    [self.LFLuisement selectTheSegument:pageNumber];
//}

#pragma mark ---SegmentedControlDelegate
//点击后切换相应的列表，检索信息
-(void)uisegumentSelectionChange:(NSInteger)selection{
    //加入动画,显得不太过于生硬切换
    [UIView animateWithDuration:.2 animations:^{
        [self.mainScrollView setContentOffset:CGPointMake(ScreenWidth *selection, 0)];
    }];
    if (selection == 0)
    {
        [self UpDateForMapWithlatitude:latitudefloat Withlongitude:longitudefloat];
    }
    else if (selection == 1)
    {
        [self UpdateForOfficeMapWithlatitude:latitudefloat Withlongitude:longitudefloat];
    }
    else if (selection == 2)
    {
        [self UpdateForHouseMapWithlatitude:latitudefloat Withlongitude:longitudefloat];
    }
    else
    {
        [self UpdateForSchoolMapWithlatitude:latitudefloat Withlongitude:longitudefloat];
    }
}
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if(response.pois.count == 0)
    {
        return;
    }
    if (allTypeBOOL == YES)
    {
        _AllMap_arr = [[NSMutableArray alloc] init];
        //通过 AMapPOISearchResponse 对象处理搜索结果
        for (AMapPOI *p in response.pois) {
            [_AllMap_arr addObject:p];
        }
        [_AllMap_vc reloadData];
    }
    if (officeBOOL == YES)
    {
        _OfficeMap_arr = [[NSMutableArray alloc] init];
        for (AMapPOI *p in response.pois) {
            [_OfficeMap_arr addObject:p];
        }
        [_office_vc reloadData];
    }
    if (houseBOOL == YES)
    {
        _HouseMap_arr = [[NSMutableArray alloc] init];
        for (AMapPOI *p in response.pois) {
            [_HouseMap_arr addObject:p];
        }
        [_house_vc reloadData];
    }
    if (schoolBOOL == YES) {
        _SchoolMap_arr = [[NSMutableArray alloc] init];
        for (AMapPOI *p in response.pois) {
            [_SchoolMap_arr addObject:p];
        }
        [_school_vc reloadData];
    }
}
//检索写字楼信息
- (void)UpdateForOfficeMapWithlatitude:(float )latitude Withlongitude:(float )longitude
{
    allTypeBOOL = NO;officeBOOL = YES;houseBOOL = NO;schoolBOOL = NO;
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location            = [AMapGeoPoint locationWithLatitude:latitude longitude:longitude];
    request.keywords            = @"大厦";
    request.sortrule            = 1;
    request.requireExtension    = YES;
    [self.search AMapPOIAroundSearch:request];
}
//检索小区信息
- (void)UpdateForHouseMapWithlatitude:(float )latitude Withlongitude:(float )longitude
{
    allTypeBOOL = NO;officeBOOL = NO;houseBOOL = YES;schoolBOOL = NO;
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location            = [AMapGeoPoint locationWithLatitude:latitude longitude:longitude];
    request.keywords            = @"小区";
    request.sortrule            = 1;
    request.requireExtension    = YES;
    [self.search AMapPOIAroundSearch:request];
}
//检索学校信息
- (void)UpdateForSchoolMapWithlatitude:(float )latitude Withlongitude:(float )longitude
{
    allTypeBOOL = NO;officeBOOL = NO;houseBOOL = NO;schoolBOOL = YES;
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location            = [AMapGeoPoint locationWithLatitude:latitude longitude:longitude];
    request.keywords            = @"学校";
    request.sortrule            = 1;
    request.requireExtension    = YES;
    [self.search AMapPOIAroundSearch:request];
}
//检索全部信息
- (void)UpDateForMapWithlatitude:(float )Latitude Withlongitude:(float )longitude
{
    allTypeBOOL = YES;officeBOOL = NO;houseBOOL = NO;schoolBOOL = NO;
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    //构造AMapPOIAroundSearchRequest对象，设置周边请求参数
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location = [AMapGeoPoint locationWithLatitude:Latitude longitude:longitude];
    request.keywords = @"大厦|小区|学校";
    request.sortrule = 1;
    request.requireExtension = YES;
    [self.search AMapPOIAroundSearch:request];
}
#pragma mark - Handle Action

- (void)actionLocation
{
    if (self.mapView.userTrackingMode == MAUserTrackingModeFollow)
    {
        [self.mapView setUserTrackingMode:MAUserTrackingModeNone animated:YES];
    }
    else
    {
        [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            // 因为下面这句的动画有bug，所以要延迟0.5s执行，动画由上一句产生
            [self.mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
        });
    }
}
- (void)initRedWaterView
{
    UIImage *image = [UIImage imageNamed:@"wateRedBlank"];
    self.redWaterView = [[UIImageView alloc] initWithImage:image];
    
    self.redWaterView.frame = CGRectMake(self.view.bounds.size.width/2-image.size.width/2, self.mapView.bounds.size.height/2-image.size.height, image.size.width, image.size.height);
    
    self.redWaterView.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2, CGRectGetHeight(self.mapView.bounds) / 2 - CGRectGetHeight(self.redWaterView.bounds) / 2);
    
    [self.view addSubview:self.redWaterView];
}
- (void)initLocationButton
{
    self.imageLocated = [UIImage imageNamed:@"gpssearchbutton"];
    self.imageNotLocate = [UIImage imageNamed:@"gpsnormal"];
    self.locationBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.mapView.bounds)*0.05, CGRectGetHeight(self.mapView.bounds)*0.85, 40, 40)];
    self.locationBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.locationBtn.backgroundColor = [UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1];
    self.locationBtn.layer.cornerRadius = 3;
    [self.locationBtn addTarget:self action:@selector(actionLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.locationBtn setImage:self.imageNotLocate forState:UIControlStateNormal];
    [self.view addSubview:self.locationBtn];
}
/* 移动窗口弹一下的动画 */
- (void)redWaterAnimimate
{
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGPoint center = self.redWaterView.center;
                         center.y -= 20;
                         [self.redWaterView setCenter:center];}
                     completion:nil];
    [UIView animateWithDuration:0.45
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         CGPoint center = self.redWaterView.center;
                         center.y += 20;
                         [self.redWaterView setCenter:center];}
                     completion:nil];
}
#pragma mark - back
- (void)addAmapTip:(AMapTip *)str
{
    AMapTip *tip = str;
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",tip.location.latitude] forKey:@"user.latitude"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",tip.location.longitude] forKey:@"user.longitude"];
    [[NSUserDefaults standardUserDefaults] setObject:tip.name forKey:@"user.locationName"];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
