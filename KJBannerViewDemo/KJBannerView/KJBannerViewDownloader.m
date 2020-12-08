//
//  KJBannerViewDownloader.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/12/7.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJBannerViewDownloader.h"

@interface KJBannerViewDownloader ()<NSURLSessionDownloadDelegate>
@property(nonatomic,strong)NSURLSessionTask *task;
@property(nonatomic,copy,readwrite)KJLoadProgressBlock progressBlock;
@property(nonatomic,copy,readwrite)KJLoadDataBlock dataBlock;
@end

@implementation KJBannerViewDownloader
- (void)kj_cancelRequest{
    [self.task cancel];
}
- (void)kj_startDownloadImageWithURL:(NSURL*)URL Progress:(KJLoadProgressBlock)progress Complete:(KJLoadDataBlock)complete{
    if (URL == nil) {
        if (complete) {
            NSError *error = [NSError errorWithDomain:@"Domain" code:400 userInfo:@{@"message":@"URL不正确"}];
            complete(nil, error);
        }
        return;
    }
    if (progress) {
        self.dataBlock = complete;
        self.progressBlock = progress;
        [self kj_downloadImageWithURL:URL];
    }else{
        [self kj_downloadImageWithURL:URL Complete:complete];
    }
}
/// 不需要下载进度的网络请求
- (void)kj_downloadImageWithURL:(NSURL*)URL Complete:(KJLoadDataBlock)complete{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (complete) {
            complete(data,error);
        }
    }];
    [dataTask resume];
    self.task = dataTask;
}
/// 下载进度的请求方式
- (void)kj_downloadImageWithURL:(NSURL*)URL{
    NSMutableURLRequest *request = kGetRequest(URL, self.timeoutInterval?:10.0);
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
    [downloadTask resume];
    self.task = downloadTask;
}
/// 创建请求对象
static inline NSMutableURLRequest *kGetRequest(NSURL *URL, NSTimeInterval timeoutInterval){
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.timeoutInterval = timeoutInterval;
    request.HTTPShouldUsePipelining = YES;
    request.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    request.allHTTPHeaderFields = @{@"Accept":@"image/webp,image/*;q=0.8"};
    return request;
}
#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession*)session dataTask:(NSURLSessionDataTask*)dataTask didReceiveResponse:(NSURLResponse*)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    completionHandler(NSURLSessionResponseAllow);
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession*)session downloadTask:(NSURLSessionDownloadTask*)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}
/// 下载中
- (void)URLSession:(NSURLSession*)session downloadTask:(NSURLSessionDownloadTask*)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    KJBannerDownloadProgress *downloadProgress = [KJBannerDownloadProgress new];
    downloadProgress.bytesWritten = bytesWritten;
    downloadProgress.downloadBytes = totalBytesWritten;
    downloadProgress.totalBytes = totalBytesExpectedToWrite;
    downloadProgress.speed = bytesWritten / 1024.;
    downloadProgress.progress = (double)totalBytesWritten / totalBytesExpectedToWrite;
    
    self.progressBlock(downloadProgress);
}
/// 下载完成调用
- (void)URLSession:(NSURLSession*)session downloadTask:(NSURLSessionDownloadTask*)downloadTask didFinishDownloadingToURL:(NSURL*)location{
    NSData *data = [NSData dataWithContentsOfURL:location];
    if (self.dataBlock) {
        self.dataBlock(data, nil);
        _dataBlock = nil;
    }
}
/// 下载失败
- (void)URLSession:(NSURLSession*)session task:(NSURLSessionTask*)task didCompleteWithError:(NSError*)error{
    if ([error code] != NSURLErrorCancelled) {
        if (self.dataBlock) {
            self.dataBlock(nil, error);
            _dataBlock = nil;
        }
    }
}
/// 后台下载
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession*)session{
    
}

@end
@implementation KJBannerDownloadProgress
@end
