//
//  ImageListModel.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/2.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import "ImageListModel.h"

@implementation ImageListModel
-(id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self=[super init]) {
        self.image_id = dictionary[@"id"];
        self.image_icon = @"";
        if(![dictionary[@"img"] isKindOfClass:[NSNull class]])
        {
            self.image_icon = dictionary[@"img"];
        }
//        self.image_icon = dictionary[@"img"];
        self.image_title = dictionary[@"name"];
        self.image_addTime = dictionary[@"addTime"];
        self.image_updateTime = dictionary[@"updateTime"];
        self.image_description = dictionary[@"description"];
    }
    
    return self;
}
@end
