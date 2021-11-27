//
//  KJWebImageDownloader.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/12/7.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo
//  网图下载工具

#import <Foundation/Foundation.h>
#import "KJNetworkManager.h"

NS_ASSUME_NONNULL_BEGIN

/// 网图下载工具
@interface KJWebImageDownloader : NSObject
/// 失败次数，默认2次
@property(nonatomic,assign,class)NSInteger kMaxLoadNum;
/// 是否使用异步，默认NO
@property(nonatomic,assign,class)BOOL useAsync;

/// 带缓存机制的下载图片
+ (void)kj_loadImageWithURL:(NSString *)url
                   complete:(void(^)(UIImage * image))complete;
+ (void)kj_loadImageWithURL:(NSString *)url
                   complete:(void(^)(UIImage * image))complete
                   progress:(KJLoadProgressBlock)progress;

/// 下载数据，未使用缓存机制
+ (NSData *)kj_downloadDataWithURL:(NSString *)url progress:(KJLoadProgressBlock)progress;

@end

NS_ASSUME_NONNULL_END
