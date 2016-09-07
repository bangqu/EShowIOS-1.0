//
//  NetworkEngine.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/2.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import "NetworkEngine.h"


@implementation NetworkEngine
+(NetworkEngine *)sharedManager{
    static NetworkEngine *sharedNetworkSingleton = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate,^{
        sharedNetworkSingleton = [[self alloc] init];
    });
    return sharedNetworkSingleton;
}
-(AFHTTPRequestOperationManager *)baseHtppRequest{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setTimeoutInterval:20];
    //header 设置
    //    [manager.requestSerializer setValue:K_PASS_IP forHTTPHeaderField:@"Host"];
    //    [manager.requestSerializer setValue:@"max-age=0" forHTTPHeaderField:@"Cache-Control"];
    //    [manager.requestSerializer setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    //    [manager.requestSerializer setValue:@"zh-cn,zh;q=0.8,en-us;q=0.5,en;q=0.3" forHTTPHeaderField:@"Accept-Language"];
    //    [manager.requestSerializer setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    //    [manager.requestSerializer setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    //    [manager.requestSerializer setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:35.0) Gecko/20100101 Firefox/35.0" forHTTPHeaderField:@"User-Agent"];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"text/html",@"application/javascript",@"application/json", nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    return manager;
}
- (void)getImageListBySearch:(NSDictionary *)parameter url:(NSString *)url successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock
{
    AFHTTPRequestOperationManager *manager = [self baseHtppRequest];
    NSString *urlStr = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [manager POST:urlStr parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock(responseObject);
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString *errorStr = [error.userInfo objectForKey:@"NSLocalizedDescription"];
         failureBlock(errorStr);
     }];
}
- (void)getImageListByList:(NSDictionary *)parameter url:(NSString *)url successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock
{
    AFHTTPRequestOperationManager *manager = [self baseHtppRequest];
    NSString *urlStr = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [manager POST:urlStr parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock(responseObject);
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString *errorStr = [error.userInfo objectForKey:@"NSLocalizedDescription"];
         failureBlock(errorStr);
     }];
}
- (void)saveImageList:(NSDictionary *)parameter url:(NSString *)url successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock
{
    url = [NSString stringWithFormat:@"%@album/save.json",BaseUrl];
    AFHTTPRequestOperationManager *manager = [self baseHtppRequest];
    NSString *urlStr = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [manager POST:urlStr parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock(responseObject);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString *errorStr = [error.userInfo objectForKey:@"NSLocalizedDescription"];
         failureBlock(errorStr);
     }];
}
- (void)getQINIUToken:(NSDictionary *)parameter url:(NSString *)url successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock
{
    url = [NSString stringWithFormat:@"%@qiniu/uptoken.json",BaseUrl];
    AFHTTPRequestOperationManager *manager = [self baseHtppRequest];
    NSString *urlStr = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [manager POST:urlStr parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock(responseObject);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString *errorStr = [error.userInfo objectForKey:@"NSLocalizedDescription"];
         failureBlock(errorStr);
     }];
}
- (void)getQINIUKey:(NSDictionary *)parameter url:(NSString *)url successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock
{
    url = [NSString stringWithFormat:@"%@qiniu/key.json",BaseUrl];
    AFHTTPRequestOperationManager *manager = [self baseHtppRequest];
    NSString *urlStr = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [manager POST:urlStr parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock(responseObject);
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString *errorStr = [error.userInfo objectForKey:@"NSLocalizedDescription"];
         failureBlock(errorStr);
     }];
}
- (void)getThirdparty:(NSDictionary *)parameter url:(NSString *)url successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock
{
    url = [NSString stringWithFormat:@"%@third-party/check.json",BaseUrl];
    AFHTTPRequestOperationManager *manager = [self baseHtppRequest];
    NSString *urlStr = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [manager GET:urlStr parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock(responseObject);
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString *errorStr = [error.userInfo objectForKey:@"NSLocalizedDescription"];
         failureBlock(errorStr);
     }];
}
- (void)cancleThirdparty:(NSDictionary *)parameter url:(NSString *)url successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock
{
    url = [NSString stringWithFormat:@"%@user/cancel.json",BaseUrl];
    AFHTTPRequestOperationManager *manager = [self baseHtppRequest];
    NSString *urlStr = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [manager GET:urlStr parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock(responseObject);
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString *errorStr = [error.userInfo objectForKey:@"NSLocalizedDescription"];
         failureBlock(errorStr);
     }];
}
- (void)updateInfo:(NSDictionary *)parameter url:(NSString *)url successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock
{
    url = [NSString stringWithFormat:@"%@user/update.json",BaseUrl];
    AFHTTPRequestOperationManager *manager = [self baseHtppRequest];
    NSString *urlStr = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [manager GET:urlStr parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         successBlock(responseObject);
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSString *errorStr = [error.userInfo objectForKey:@"NSLocalizedDescription"];
         failureBlock(errorStr);
     }];
}
@end
