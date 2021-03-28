//
//  KJBannerViewType.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/12/7.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo
//  枚举文件夹

#ifndef KJBannerViewType_h
#define KJBannerViewType_h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, KJBannerImageType) {
    KJBannerImageTypeUnknown = 0, /// 未知
    KJBannerImageTypeJpeg    = 1, /// jpg
    KJBannerImageTypePng     = 2, /// png
    KJBannerImageTypeGif     = 3, /// gif
    KJBannerImageTypeTiff    = 4, /// tiff
    KJBannerImageTypeWebp    = 5, /// webp
};
/// 滚动方法
typedef NS_ENUM(NSInteger, KJBannerViewRollDirectionType) {
    KJBannerViewRollDirectionTypeRightToLeft, /// 默认，从右往左
    KJBannerViewRollDirectionTypeLeftToRight, /// 从左往右
    KJBannerViewRollDirectionTypeBottomToTop, /// 从下往上
    KJBannerViewRollDirectionTypeTopToBottom, /// 从上往下
};
/// 分页控件类型
typedef NS_ENUM(NSInteger, KJPageControlStyle) {
    PageControlStyleRectangle = 0, // 默认类型 长方形
    PageControlStyleCircle, // 圆形
    PageControlStyleSquare, // 正方形
    PageControlStyleSizeDot,// 大小点
};
/// 分页控件显示位置
typedef NS_ENUM(NSInteger, KJPageControlDisplayType) {
    KJPageControlDisplayTypeCenter,
    KJPageControlDisplayTypeLeft,
    KJPageControlDisplayTypeRight,
};
/// 弱引用
#define __banner_weakself __weak __typeof(self) weakself = self
/// 子线程
NS_INLINE void kGCD_banner_async(dispatch_block_t _Nonnull block) {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {
        block();
    }else{
        dispatch_async(queue, block);
    }
}
/// 主线程
NS_INLINE void kGCD_banner_main(dispatch_block_t _Nonnull block) {
    dispatch_queue_t queue = dispatch_get_main_queue();
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {
        block();
    }else{
        if ([[NSThread currentThread] isMainThread]) {
            dispatch_async(queue, block);
        }else{
            dispatch_sync(queue, block);
        }
    }
}
/// 异步绘制圆角，支持特定方位圆角处理，原理就是绘制一个镂空图片盖在上面，所以这种只适用于纯色背景
NS_INLINE void kBannerAsyncCornerRadius(CGFloat radius, void(^xxblock)(UIImage *image), UIRectCorner corners, UIView *view){
    UIColor *bgColor;
    if (view.backgroundColor) {
        bgColor = view.backgroundColor;
    }else if (view.superview.backgroundColor){
        bgColor = view.superview.backgroundColor;
    }else{
        bgColor = UIColor.whiteColor;
    }
    CGRect bounds = view.bounds;
    if (xxblock) {
        kGCD_banner_async(^{
            CGFloat scale = [UIScreen mainScreen].scale;
            UIGraphicsBeginImageContextWithOptions(bounds.size, NO, scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:bounds];
            UIBezierPath *cornerPath = [[UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)] bezierPathByReversingPath];
            [path appendPath:cornerPath];
            CGContextAddPath(context, path.CGPath);
            [bgColor set];
            CGContextFillPath(context);
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            kGCD_banner_main(^{ xxblock(image);});
            UIGraphicsEndImageContext();
        });
    }
}

NS_ASSUME_NONNULL_END
#endif /* KJBannerViewType_h */
