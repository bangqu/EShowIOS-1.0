//
//  WYJAddressPicker.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/10.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import "WYJAddressPicker.h"
#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@implementation WYJAddressPicker
{
    NSArray   *_provinces;
    NSArray   *_citys;
    NSArray   *_areas;
    
    NSString  *_currentProvince;
    NSString  *_currentCity;
    NSString  *_currentDistrict;
    
    UIView        *_wholeView;
    UIView        *_topView;
    UIPickerView  *_pickerView;
}
+ (id)shareInstance
{
    static WYJAddressPicker *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[WYJAddressPicker alloc] init];
    });
    
    return shareInstance;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.userInteractionEnabled = YES;
        self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenBottomView)];
        [self addGestureRecognizer:tap];
        
        [self createData];
        [self createView];
    }
    return self;
}

- (void)createData
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"plist"];
    NSArray *data = [[NSArray alloc]initWithContentsOfFile:plistPath];
    
    _provinces = data;
    
    // 第一个省分对应的全部市
    _citys = [[_provinces objectAtIndex:0] objectForKey:@"cities"];
    // 第一个省份
    _currentProvince = [[_provinces objectAtIndex:0] objectForKey:@"state"];
    // 第一个省份对应的第一个市
    _currentCity = [[_citys objectAtIndex:0] objectForKey:@"city"];
    // 第一个省份对应的第一个市对应的第一个区
    _areas = [[_citys objectAtIndex:0] objectForKey:@"areas"];
    if (_areas.count > 0) {
        _currentDistrict = [_areas objectAtIndex:0];
    } else {
        _currentDistrict = @"";
    }
}

- (void)createView
{
    // 弹出的整个视图
    _wholeView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 250)];
    _wholeView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_wholeView];
    
    // 头部按钮视图
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
    _topView.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
    [_wholeView addSubview:_topView];
    
    // 防止点击事件触发
    UITapGestureRecognizer *topTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    [_topView addGestureRecognizer:topTap];
    
    NSArray *buttonTitleArray = @[@"确定"];
//    for (int i = 0; i <buttonTitleArray.count ; i++)
//    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
//        [button setTintColor:[UIColor blueColor]];
        [button setTitleColor:[UIColor colorWithRed:(247 / 255.0f) green:(105 / 255.0f) blue:(86 / 255.0f) alpha:1] forState:UIControlStateNormal];
        button.frame = CGRectMake(1*(ScreenWidth-50), 0, 50, 40);
        [button setTitle:buttonTitleArray[0] forState:UIControlStateNormal];
        [_topView addSubview:button];
        
        button.tag = 1;
        [button addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
//    }
    
    // pickerView
    _pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 40, ScreenWidth, 240-40)];
    _pickerView.dataSource = self;
    _pickerView.delegate = self;
    [_wholeView addSubview:_pickerView];
}

- (void)buttonEvent:(UIButton *)button
{
    // 点击确定回调block
    if (button.tag == 1)
    {
        if (_block) {
            _block(_currentProvince, _currentCity, _currentDistrict);
        }
    }
    
    [self hiddenBottomView];
}

- (void)showBottomView
{
    [UIView animateWithDuration:0.3 animations:^
     {
         _wholeView.frame = CGRectMake(0, ScreenHeight-250, ScreenWidth, 250);
         
     } completion:^(BOOL finished) {}];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"address"]) {
        [self refreshPickerView:[defaults objectForKey:@"address"]];
    }
}

- (void)hiddenBottomView
{
    [UIView animateWithDuration:0.3 animations:^
     {
         _wholeView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, 250);
         
     } completion:^(BOOL finished) {
         [self removeFromSuperview];
     }];
}

- (void)refreshPickerView:(NSString *)address
{
    NSArray *addressArray = [address componentsSeparatedByString:@" "];
    NSString *provinceStr = addressArray[0];
    NSString *cityStr = addressArray[1];
    NSString *districtStr = addressArray[2];
    
    int oneColumn=0, twoColumn=0, threeColum=0;
    
    // 省份
    for (int i=0; i<_provinces.count; i++)
    {
        if ([provinceStr isEqualToString:[_provinces[i] objectForKey:@"state"]]) {
            oneColumn = i;
        }
    }
    
    // 用来记录是某个省下的所有市
    NSArray *tempArray = [_provinces[oneColumn] objectForKey:@"cities"];
    // 市
    for  (int j=0; j<[tempArray count]; j++)
    {
        if ([cityStr isEqualToString:[tempArray[j] objectForKey:@"city"]])
        {
            twoColumn = j;
            break;
        }
    }

    // 区
    for (int k=0; k<[[tempArray[twoColumn] objectForKey:@"areas"] count]; k++)
    {
        if ([districtStr isEqualToString:[tempArray[twoColumn] objectForKey:@"areas"][k]])
        {
            threeColum = k;
            break;
        }
    }
    
    [self pickerView:_pickerView didSelectRow:oneColumn inComponent:0];
    [self pickerView:_pickerView didSelectRow:twoColumn inComponent:1];
    [self pickerView:_pickerView didSelectRow:threeColum inComponent:2];
}

#pragma mark - UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [_provinces count];
            break;
        case 1:
            return [_citys count];
            break;
        case 2:
            
            return [_areas count];
            break;
            
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component)
    {
        case 0:
            return [[_provinces objectAtIndex:row] objectForKey:@"state"];
            break;
        case 1:
            return [[_citys objectAtIndex:row] objectForKey:@"city"];
            break;
        case 2:
            if ([_areas count] > 0) {
                return [_areas objectAtIndex:row];
                break;
            }
        default:
            return  @"";
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [pickerView selectRow:row inComponent:component animated:YES];
    
    switch (component)
    {
        case 0:
            
            _citys = [[_provinces objectAtIndex:row] objectForKey:@"cities"];
            [_pickerView selectRow:0 inComponent:1 animated:YES];
            [_pickerView reloadComponent:1];
            
            _areas = [[_citys objectAtIndex:0] objectForKey:@"areas"];
            [_pickerView selectRow:0 inComponent:2 animated:YES];
            [_pickerView reloadComponent:2];
            
            _currentProvince = [[_provinces objectAtIndex:row] objectForKey:@"state"];
            _currentCity = [[_citys objectAtIndex:0] objectForKey:@"city"];
            if ([_areas count] > 0) {
                _currentDistrict = [_areas objectAtIndex:0];
            } else{
                _currentDistrict = @"";
            }
            break;
            
        case 1:
            
            _areas = [[_citys objectAtIndex:row] objectForKey:@"areas"];
            [_pickerView selectRow:0 inComponent:2 animated:YES];
            [_pickerView reloadComponent:2];
            
            _currentCity = [[_citys objectAtIndex:row] objectForKey:@"city"];
            if ([_areas count] > 0) {
                _currentDistrict = [_areas objectAtIndex:0];
            } else {
                _currentDistrict = @"";
            }
            break;
            
        case 2:
            
            if ([_areas count] > 0) {
                _currentDistrict = [_areas objectAtIndex:row];
            } else{
                _currentDistrict = @"";
            }
            break;
            
        default:
            break;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *pickerLabel = (UILabel *)view;
    if (!pickerLabel)
    {
        pickerLabel = [[UILabel alloc] init];
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setFont:[UIFont systemFontOfSize:16]];
    }
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    
    return pickerLabel;
}
@end
