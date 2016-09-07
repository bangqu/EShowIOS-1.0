//
//  downloadedViewCell.h
//  EShowIOS
//
//  Created by 王迎军 on 16/8/23.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFDownloadManager.h"
@interface downloadedViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;

/** 下载信息模型 */
@property (nonatomic, strong) ZFFileModel *fileInfo;
@end
