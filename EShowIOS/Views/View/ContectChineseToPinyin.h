//
//  ContectChineseToPinyin.h
//  EShowIOS
//
//  Created by 王迎军 on 16/9/1.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContectChineseToPinyin : NSObject

@property(retain,nonatomic)NSString *string;
@property(retain,nonatomic)NSString *pinYin;

//-----  返回tableview右方indexArray
+(NSMutableArray*)IndexArray:(NSArray*)stringArr;

//-----  返回联系人
+(NSMutableArray*)LetterSortArray:(NSArray*)stringArr;



///----------------------
//返回一组字母排序数组(中英混排)
+(NSMutableArray*)SortArray:(NSArray*)stringArr;

@end
