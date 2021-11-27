//
//  KJNetworkManager.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/12/7.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo
//  网络请求工具

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class KJBannerDownloadProgress;
/// 网络请求回调
typedef void (^_Nullable KJLoadDataBlock)(NSData * _Nullable data, NSError * _Nullable error);
/// 下载进度回调
typedef void (^_Nullable KJLoadProgressBlock)(KJBannerDownloadProgress * downloadProgress);
@interface KJNetworkManager : NSObject

/// 超时时长，默认10秒
@property(nonatomic,assign)NSTimeInterval timeoutInterval;
/// 设置最大并发队列数，默认为2条
@property(nonatomic,assign)NSUInteger maxConcurrentOperationCount;

/// 下载数据
/// @param URL 下载链接
/// @param progress 下载进度回调
/// @param complete 下载完成回调
- (void)kj_startDownloadImageWithURL:(NSURL *)URL
                            progress:(KJLoadProgressBlock)progress
                            complete:(KJLoadDataBlock)complete;
/// 取消下载
- (void)kj_cancelRequest;

@end

//********************* 下载进度条 *********************
@interface KJBannerDownloadProgress : NSObject

@property(nonatomic,assign)int64_t bytesWritten;// 当前下载包大小
@property(nonatomic,assign)int64_t downloadBytes;// 已下载大小
@property(nonatomic,assign)int64_t totalBytes;// 总大小
@property(nonatomic,assign)float progress;// 下载进度
@property(nonatomic,assign)float speed;// 当前下载速度 kb/s

@end

NS_ASSUME_NONNULL_END
