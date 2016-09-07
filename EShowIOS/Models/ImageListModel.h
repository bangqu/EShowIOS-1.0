//
//  ImageListModel.h
//  EShowIOS
//
//  Created by 王迎军 on 16/8/2.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageListModel : NSObject

@property (strong, nonatomic) NSString *image_id;
@property (strong, nonatomic) NSString *image_icon;
@property (strong, nonatomic) NSString *image_title;
@property (strong, nonatomic) NSString *image_addTime;
@property (strong, nonatomic) NSString *image_description;
@property (strong, nonatomic) NSString *image_updateTime;

-(id)initWithDictionary:(NSDictionary *)dictionary;
@end
