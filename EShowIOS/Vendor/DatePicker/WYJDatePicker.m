//
//  WYJDatePicker.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/10.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import "WYJDatePicker.h"

#define kZero 0
#define kFullWidth [UIScreen mainScreen].bounds.size.width
#define kFullHeight [UIScreen mainScreen].bounds.size.height

#define kDatePicY kFullHeight/3*2
#define kDatePicHeight kFullHeight/3

#define kDateTopBtnY kDatePicY - 30
#define kDateTopBtnHeight 30

#define kDateTopRightBtnWidth kDateTopLeftBtnWidth
#define kDateTopRightBtnX kFullWidth  - kDateTopRightBtnWidth

#define kDateTopLeftbtnX 0
#define kDateTopLeftBtnWidth kFullWidth/6


@interface WYJDatePicker()
@property (nonatomic,strong)UIDatePicker *dateP;
@property (nonatomic,strong)UIView *groundV;
@property (nonatomic,strong)UIButton *leftBtn;
@property (nonatomic,strong)UIButton *rightBtn;
@property (nonatomic,strong)UIView *topView;

@property (nonatomic,assign)UIDatePickerMode type;
@end

@implementation WYJDatePicker
- (instancetype)initWithFrame:(CGRect)frame type:(UIDatePickerMode)type{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        [self addSubview:self.groundV];
        [self addSubview:self.dateP];
        [self addSubview:self.topView];
        [self addSubview:self.leftBtn];
        [self addSubview:self.rightBtn];
    }
    return self;
}

- (UIDatePicker *)dateP{
    if (!_dateP) {
        self.dateP = [[UIDatePicker alloc]initWithFrame:CGRectMake(kZero, kDatePicY, kFullWidth, kDatePicHeight)];
        self.dateP.backgroundColor = [UIColor whiteColor];
        
        self.dateP.datePickerMode = self.type;
        self.dateP.locale = [[NSLocale alloc]initWithLocaleIdentifier:@"zh_CHS_CN"];
        //        NSDate *maxDate = [NSDate date];
        //        self.dateP.maximumDate = maxDate;
        [self.dateP addTarget:self action:@selector(handleDateP:) forControlEvents:UIControlEventValueChanged];
    }
    return _dateP;
}

- (UIView *)groundV {
    if (!_groundV) {
        self.groundV = [[UIView alloc]initWithFrame:self.bounds];
        self.groundV.backgroundColor = [UIColor blackColor];
        self.groundV.alpha = 0.7;
    }
    return _groundV;
}

- (UIButton *)leftBtn{
    if (!_leftBtn) {
        self.leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.leftBtn.frame = CGRectMake(kDateTopLeftbtnX, kDateTopBtnY, kDateTopLeftBtnWidth, kDateTopBtnHeight);
        [self.leftBtn setTitle:@"取消" forState:UIControlStateNormal];
        [self.leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.leftBtn addTarget:self action:@selector(handleDateTopViewLeft) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftBtn;
}

- (UIButton *)rightBtn {
    if (!_rightBtn) {
        self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.rightBtn.frame = CGRectMake(kDateTopRightBtnX, kDateTopBtnY, kDateTopRightBtnWidth, kDateTopBtnHeight);
        [self.rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.rightBtn setTitle:@"确定" forState:UIControlStateNormal];
        
        [self.rightBtn addTarget:self action:@selector(handleDateTopViewRight) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}

- (UIView *)topView {
    if (!_topView) {
        self.topView = [[UIView alloc]initWithFrame:CGRectMake(kZero, kDateTopBtnY, kFullWidth, kDateTopBtnHeight)];
        self.topView.backgroundColor = [UIColor whiteColor];
    }
    return _topView;
}

- (void)setNowTime:(NSString *)dateStr{
    
    [self.dateP setDate:[self dateFromString:dateStr] animated:YES];
}

- (void)end{
    [self removeFromSuperview];
}
- (void)handleDateP :(NSDate *)date {
    [self.delegate changeTime:self.dateP.date];
}
- (void)handleDateTopViewLeft {
    [self end];
}
- (void)handleDateTopViewRight {
    [self.delegate determine:self.dateP.date];
    [self end];
}



// NSDate --> NSString
- (NSString*)stringFromDate:(NSDate*)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    switch (self.type) {
        case UIDatePickerModeTime:
            [dateFormatter setDateFormat:@"HH:mm"];
            break;
        case UIDatePickerModeDate:
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            break;
        case UIDatePickerModeDateAndTime:
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            break;
        case UIDatePickerModeCountDownTimer:
            [dateFormatter setDateFormat:@"HH:mm"];
            break;
        default:
            break;
    }
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

//NSDate <-- NSString
- (NSDate*)dateFromString:(NSString*)dateString{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    switch (self.type) {
        case UIDatePickerModeTime:
            [dateFormatter setDateFormat:@"HH:mm"];
            break;
        case UIDatePickerModeDate:
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            break;
        case UIDatePickerModeDateAndTime:
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            break;
        case UIDatePickerModeCountDownTimer:
            [dateFormatter setDateFormat:@"HH:mm"];
            break;
        default:
            break;
    }
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    return destDate;
}

@end
