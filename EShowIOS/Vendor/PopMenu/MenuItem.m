//
//  MenuItem.m
//  JackFastKit
//
//  Created by 曾 宪华 on 14-10-13.
//  Copyright (c) 2014年 华捷 iOS软件开发工程师 曾宪华. All rights reserved.
//

#import "MenuItem.h"

@implementation MenuItem

- (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName {
    return [self initWithTitle:title iconName:iconName glowColor:nil];
}

- (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor {
    return [self initWithTitle:title iconName:iconName glowColor:glowColor isMessage:YES messageNum:0 index:-1];
}

- (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                        index:(NSInteger)index {
   return [self initWithTitle:title iconName:iconName glowColor:nil isMessage:YES messageNum:0 index:index];
}

- (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor
                    isMessage:(BOOL)isMessage
                   messageNum:(NSInteger)messageNum
                        index:(NSInteger)index {
    if (self = [super init]) {
        self.title = title;
        self.iconImage = [UIImage imageNamed:iconName];
        self.glowColor = glowColor;
        self.index = index;
        self.isMessage = isMessage;
        self.messageNum = messageNum;
        
    }
    return self;
}


+ (instancetype)itemWithTitle:(NSString *)title
                     iconName:(NSString *)iconName {
    return  [self itemWithTitle:title iconName:iconName glowColor:nil isMessage:YES messageNum:0 index:-1];
}

+ (instancetype)itemWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor {
    return [self itemWithTitle:title iconName:iconName glowColor:glowColor isMessage:YES messageNum:0 index:-1];
}

+ (instancetype)itemWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                        index:(NSInteger)index {
     return [self itemWithTitle:title iconName:iconName glowColor:nil isMessage:YES messageNum:0 index:index];
}

+ (instancetype)itemWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor
                    isMessage:(BOOL)isMessage
                   messageNum:(NSInteger)messageNum
                        index:(NSInteger)index {
    MenuItem *item = [[self alloc ] initWithTitle:title iconName:iconName glowColor:glowColor isMessage:isMessage messageNum:messageNum index:index];
    return item;
}

@end
