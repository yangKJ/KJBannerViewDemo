//
//  KJBannerViewTimer.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/12/7.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo
//  计时器

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KJBannerViewTimer : NSObject
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
/// 是否处于暂停中
@property (nonatomic, assign, readonly) BOOL pausing;

/// 创建异步子线程计时器
/// @param inerval 间隔时间
/// @param repeats 是否重复
/// @param task 事件处理
- (instancetype)initWithInterval:(NSTimeInterval)inerval
                         repeats:(BOOL)repeats
                            task:(void(^)(void))task;

/// 开启计时器，会延时 `inerval` 间隔秒执行
- (void)kj_startTimer;

/// 暂停计时器
- (void)kj_pauseTimer;

/// 继续计时器
- (void)kj_resumeTimer;

/// 释放计时器
- (void)kj_invalidateTimer;

/// 立刻执行
- (void)kj_immediatelyTimer;

@end

NS_ASSUME_NONNULL_END
