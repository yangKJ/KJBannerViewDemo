//
//  KJBannerViewTimer.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/12/7.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJBannerViewTimer.h"

@interface KJBannerViewTimer ()

@property (nonatomic,assign) BOOL pausing;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign) NSTimeInterval interval;

@end

@implementation KJBannerViewTimer

- (void)dealloc{
    [self kj_invalidateTimer];
}

/// 开启一个当前线程内可重复执行的NSTimer对象
/// @param inerval 间隔时间
/// @param repeats 是否重复
/// @param task 事件处理
- (instancetype)initWithInterval:(NSTimeInterval)inerval
                         repeats:(BOOL)repeats
                            task:(void(^)(void))task{
    if (self = [super init]) {
        self.pausing = YES;
        self.interval = inerval;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:inerval
                                                      target:self
                                                    selector:@selector(blcokInvoke:)
                                                    userInfo:[task copy]
                                                     repeats:repeats];
    }
    return self;
}

- (void)blcokInvoke:(NSTimer *)timer{
    void (^withBlock)(void) = timer.userInfo;
    if (withBlock) withBlock();
    self.pausing = NO;
}

/// 开启计时器
- (void)kj_startTimer{
    if (![self.timer isValid]) return;
    [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.interval]];
    self.pausing = NO;
}

/// 暂停计时器
- (void)kj_pauseTimer{
    if (![self.timer isValid]) return;
    [self.timer setFireDate:[NSDate distantFuture]];
    self.pausing = YES;
}

/// 继续计时器
- (void)kj_resumeTimer{
    if (![self.timer isValid]) return;
    [self.timer setFireDate:[NSDate date]];
    self.pausing = NO;
}

/// 释放计时器
- (void)kj_invalidateTimer{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    self.pausing = YES;
}

/// 立刻执行
- (void)kj_immediatelyTimer{
    if (![self.timer isValid]) return;
    [self.timer fire];
    self.pausing = NO;
}

@end
