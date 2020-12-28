//
//  KJLoadImageView.h
//  iSchool
//
//  Created by 杨科军 on 2018/12/22.
//  Copyright © 2018 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo
//  不依赖三方网络加载图片显示

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KJLoadImageView : UIImageView
/// 下载图片失败时重试次数，默认两次
@property (nonatomic,assign)NSUInteger kj_failedTimes;
/// 是否裁剪为控件尺寸，默认NO
@property (nonatomic,assign)BOOL kj_isScale;

/// 清理掉本地缓存
+ (void)kj_clearImagesCache;
/// 获取图片缓存的占用的总大小
+ (int64_t)kj_imagesCacheSize;

/// 网图显示下载
- (void)kj_setImageWithURLString:(NSString*)url Placeholder:(UIImage*)placeholder;
- (void)kj_setImageWithURLString:(NSString*)url Placeholder:(UIImage*)placeholder Completion:(void(^_Nullable)(UIImage*image))completion;

/// 动态图显示下载
- (void)kj_setGIFImageWithURLString:(NSString*)url Placeholder:(UIImage*)placeholder Completion:(void(^_Nullable)(UIImage*image))completion;

@end

NS_ASSUME_NONNULL_END
