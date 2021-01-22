//
//  UIButton+KJWebImage.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2021/1/22.
//  Copyright © 2021 杨科军. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KJBannerViewType.h"
#import "KJBannerViewDownloader.h"
NS_ASSUME_NONNULL_BEGIN

@interface UIButton (KJWebImage)
/// 显示网络图片
- (void)kj_setImageWithURL:(NSURL*)url
               placeholder:(UIImage*)placeholder
                     state:(UIControlState)state
                 completed:(KJWebImageCompleted)completed
                  progress:(KJLoadProgressBlock)progress;

@end

NS_ASSUME_NONNULL_END
