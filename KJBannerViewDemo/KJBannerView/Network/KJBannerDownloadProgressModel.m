//
//  KJBannerDownloadModel.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/12/8.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJBannerDownloadModel.h"

@interface KJBannerDownloadModel ()
@property (nonatomic,assign) int64_t resumeBytesWritten;
@property (nonatomic,assign) int64_t bytesWritten;
@property (nonatomic,assign) int64_t totalBytesWritten;
@property (nonatomic,assign) int64_t totalBytesExpectedToWrite;
@property (nonatomic,assign) float progress;
@property (nonatomic,assign) float speed;
@property (nonatomic,assign) int remainTime;

@end

@implementation KJBannerDownloadModel

@end
