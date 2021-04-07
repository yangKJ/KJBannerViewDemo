//
//  NSObject+KJGCDTimer.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2021/2/20.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo
//  基于GCD内核计时器，内部有处理彻底解决定时器循环引用、释放时机问题

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KJGCDTimer)
/* 创建异步定时器 */
- (dispatch_source_t)kj_bannerCreateAsyncTimer:(BOOL)async
                                          Task:(void(^)(void))task
                                         start:(NSTimeInterval)start
                                      interval:(NSTimeInterval)interval
                                       repeats:(BOOL)repeats;
/* 取消计时器 */
- (void)kj_bannerStopTimer:(dispatch_source_t)timer;
/* 暂停计时器 */
- (void)kj_bannerPauseTimer:(dispatch_source_t)timer;
/* 继续计时器 */
- (void)kj_bannerResumeTimer:(dispatch_source_t)timer;

/* 延时执行 */
- (void)kj_bannerAfterTask:(void(^)(void))task time:(NSTimeInterval)time Asyne:(BOOL)async;

@end

NS_ASSUME_NONNULL_END
