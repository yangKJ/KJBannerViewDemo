//
//  KJNetworkManager.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/12/7.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJNetworkManager.h"

@implementation KJBannerDownloadProgress

@end

@interface KJNetworkManager ()<NSURLSessionDownloadDelegate>

@property(nonatomic,strong)NSURLSessionTask *task;
@property(nonatomic,strong)NSOperationQueue *queue;
@property(nonatomic,strong)NSURLSessionConfiguration *configuration;
@property(nonatomic,strong)KJBannerDownloadProgress *downloadProgress;
@property(nonatomic,copy,readwrite)KJLoadProgressBlock progressBlock;
@property(nonatomic,copy,readwrite)KJLoadDataBlock dataBlock;

@end

@implementation KJNetworkManager
- (void)kj_cancelRequest{
    [self.task cancel];
}
- (void)kj_startDownloadImageWithURL:(NSURL *)URL progress:(KJLoadProgressBlock)progress complete:(KJLoadDataBlock)complete{
    if (URL == nil) {
//        NSAssert(URL == nil, @"URL is nil.");
        NSError *error = [NSError errorWithDomain:@"url failed"
                                             code:400
                                         userInfo:@{NSLocalizedDescriptionKey:@"URL is nil."}];
        complete ? complete(nil, error) : nil;
        return;
    }
    self.maxConcurrentOperationCount = 2;
    if (progress) {
        self.dataBlock = complete;
        self.progressBlock = progress;
        [self kj_downloadImageWithURL:URL];
    } else {
        [self kj_dataImageWithURL:URL Complete:complete];
    }
}
/// 不需要下载进度的网络请求
- (void)kj_dataImageWithURL:(NSURL *)URL Complete:(KJLoadDataBlock)complete{
    NSMutableURLRequest *request = kGetRequest(URL, self.timeoutInterval ?: 10.0);
    NSURLSession *session = [NSURLSession sessionWithConfiguration:self.configuration delegate:self delegateQueue:self.queue];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        if (complete) complete(data,error);
    }];
    [dataTask resume];
    self.task = dataTask;
}
/// 下载进度的请求方式
- (void)kj_downloadImageWithURL:(NSURL *)URL{
    NSMutableURLRequest *request = kGetRequest(URL, self.timeoutInterval ?: 10.0);
    NSURLSession *session = [NSURLSession sessionWithConfiguration:self.configuration delegate:self delegateQueue:self.queue];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
    [downloadTask resume];
    self.task = downloadTask;
}
/// 创建请求对象
NS_INLINE NSMutableURLRequest * kGetRequest(NSURL * URL, NSTimeInterval timeoutInterval){
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.timeoutInterval = timeoutInterval;
    request.HTTPShouldUsePipelining = YES;
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:@"image/webp,image/*;q=0.8" forKey:@"Accept"];
//    [param setValue:@"" forKey:@"Accept-Encoding"];
    [request setAllHTTPHeaderFields:param];
    return request;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask*)dataTask didReceiveResponse:(NSURLResponse*)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    completionHandler(NSURLSessionResponseAllow);
}
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge*)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential, card);
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}
/// 下载中
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    @synchronized (self.downloadProgress) {
        self.downloadProgress.bytesWritten = bytesWritten;
        self.downloadProgress.downloadBytes = totalBytesWritten;
        self.downloadProgress.speed = bytesWritten / 1024.;
        if (totalBytesExpectedToWrite == -1) {
            self.downloadProgress.totalBytes = 0;
            self.downloadProgress.progress = 0;
        } else {
            self.downloadProgress.totalBytes = totalBytesExpectedToWrite;
            self.downloadProgress.progress = (double)totalBytesWritten / totalBytesExpectedToWrite;
        }
        self.progressBlock(self.downloadProgress);
    }
}
/// 下载完成调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    if (self.dataBlock) {
        NSData *data = [NSData dataWithContentsOfURL:location];
        self.dataBlock(data, nil);
        _dataBlock = nil;
    }
}
/// 下载失败
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError*)error{
    if ([error code] != NSURLErrorCancelled) {
        if (self.dataBlock) {
            self.dataBlock(nil, error);
            _dataBlock = nil;
        }
    }
}
/// 后台下载
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    
}

#pragma mark - getter/setter

- (void)setMaxConcurrentOperationCount:(NSUInteger)maxConcurrentOperationCount{
    _maxConcurrentOperationCount = maxConcurrentOperationCount;
    self.queue.maxConcurrentOperationCount = maxConcurrentOperationCount;
}

#pragma mark - lazy

- (KJBannerDownloadProgress *)downloadProgress{
    if (!_downloadProgress) {
        _downloadProgress = [[KJBannerDownloadProgress alloc]init];
    }
    return _downloadProgress;
}
- (NSOperationQueue *)queue{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc]init];
    }
    return _queue;
}
- (NSURLSessionConfiguration *)configuration{
    if (!_configuration) {
        _configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _configuration.networkServiceType = NSURLNetworkServiceTypeDefault;
    }
    return _configuration;
}

@end
