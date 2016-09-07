/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "AppDelegate+UMeng.h"
#import "MobClick.h"

@implementation AppDelegate (UMeng)

-(void)setupUMeng{
    //友盟
    NSString *bundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    if ([bundleID isEqualToString:@"com.bangqu.EShowIOS"]) {
        [MobClick startWithAppkey:@"56ceca68e0f55a2ece000d68"
                     reportPolicy:BATCH
                        channelId:nil];
#if DEBUG
        [MobClick setLogEnabled:YES];
#else
        [MobClick setLogEnabled:NO];
#endif
    }
}

@end
