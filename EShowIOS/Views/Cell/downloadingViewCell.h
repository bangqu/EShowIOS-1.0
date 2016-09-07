//
//  downloadingViewCell.h
//  EShowIOS
//
//  Created by 王迎军 on 16/8/23.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFDownloadManager.h"

typedef void(^ZFBtnClickBlock)(void);
@interface downloadingViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;

/** 下载按钮点击回调block */
@property (nonatomic, copy  ) ZFBtnClickBlock  btnClickBlock;
/** 下载信息模型 */
@property (nonatomic, strong) ZFFileModel      *fileInfo;
/** 该文件发起的请求 */
@property (nonatomic,retain ) ZFHttpRequest    *request;
@end
