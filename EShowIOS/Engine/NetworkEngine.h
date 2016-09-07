//
//  NetworkEngine.h
//  EShowIOS
//
//  Created by 王迎军 on 16/8/2.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

//请求超时
#define TIMEOUT 30

typedef void(^SuccessBlock)(id responseBody);

typedef void(^FailureBlock)(NSString *error);
@interface NetworkEngine : NSObject

+(NetworkEngine *)sharedManager;
-(AFHTTPRequestOperationManager *)baseHtppRequest;

/**
 *  分页获取图片列表
 *  @param url          /album/search.json
 */
-(void)getImageListBySearch:(NSDictionary *)parameter url:(NSString *)url successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;

/**
 *  非分页获取图片列表
 *  @param url          /album/list.json
 */
-(void)getImageListByList:(NSDictionary *)parameter url:(NSString *)url successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;
/**
 *  获取七牛的token
 *  @param url        ／qiniu/uptoken.json
 */
-(void)getQINIUToken:(NSDictionary *)parameter url:(NSString *)url successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;
/**
 *  获取七牛的key
 *  @param url        ／qiniu/key.json
 */
-(void)getQINIUKey:(NSDictionary *)parameter url:(NSString *)url successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;
/**
 *  相册添加
 *  @param url          /album/save.json
 */
-(void)saveImageList:(NSDictionary *)parameter url:(NSString *)url successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;
/**
 *  获取绑定信息
 */
-(void)getThirdparty:(NSDictionary *)parameter url:(NSString *)url successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;
/**
 *  取消相关绑定
 */
-(void)cancleThirdparty:(NSDictionary *)parameter url:(NSString *)url successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;
/**
 *  表单更新
 */
-(void)updateInfo:(NSDictionary *)parameter url:(NSString *)url successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;
@end
