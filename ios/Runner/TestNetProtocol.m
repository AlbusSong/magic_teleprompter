//
//  TestNetProtocol.m
//  Runner
//
//  Created by Albus on 4/6/21.
//

#import "TestNetProtocol.h"
#import "NSJSONSerialization+AvoidNull.h"

static NSString *const TestInitKey = @"TestInitKey";

@interface TestNetProtocol ()

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

@end

@implementation TestNetProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSLog(@"canInitWithRequest: %@", request.URL.absoluteString);
    //判断是否已经处理过request
//    if ([NSURLProtocol propertyForKey:TestInitKey inRequest:request]) {
//        return NO;
//    }
//
//    //这里可添加拦截逻辑
//    if ([request.URL.absoluteString containsString:@"tusdk.com"]) {
//        return NO;
//    }

    return NO;
}

/**
 * 返回一个准确的request,
 *  在这里可以设置请求头，重定向等
 */
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableURLRequest = request.mutableCopy;
    return mutableURLRequest;
//    return request;
}

/**
 * 判断网络请求是否一致，一致的话使用缓存数据。没有需要就调用 super 的方法
 */
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client {
    NSMutableURLRequest *mutableURLRequest = request.mutableCopy;
    if (self.request.HTTPBody == nil) {
        mutableURLRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:@{} options:NSJSONWritingPrettyPrinted error:nil];
    }
    return [super initWithRequest:mutableURLRequest cachedResponse:cachedResponse client:client];
}

- (void)startLoading {
    NSLog(@"startLoading: %@",self.request.HTTPBody);
    
     //这里还可以把结果缓存起来直接返回出去
//    NSMutableURLRequest *mutableURLRequest = [self.request mutableCopy];
    //给处理的request添加标记
//    [NSURLProtocol setProperty:@(YES) forKey:TestInitKey inRequest:mutableURLRequest];
    NSURLSessionConfiguration *sessionConfigura = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfigura];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSMutableDictionary *dict = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] mutableCopy];
        //这里可以修改返回值的response
        [dict setObject:@"1234567890" forKey:@"reason"];
        data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingFragmentsAllowed error:nil];
        if (!error) {
            [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            [self.client URLProtocol:self didLoadData:data];
            [self.client URLProtocolDidFinishLoading:self];
        }else{
            [self.client URLProtocol:self didFailWithError:error];
        }
    }];
    NSLog(@"dataTask1:%@",dataTask);
    _dataTask = dataTask;
    [dataTask resume];
}

- (void)stopLoading {
    NSLog(@"stopLoading");
    NSLog(@"dataTask2:%@,resopnseURL:%@,progress:%@",self.dataTask,[(NSHTTPURLResponse *)self.dataTask.response URL],self.dataTask.progress);
    [self.dataTask cancel];
}

@end
