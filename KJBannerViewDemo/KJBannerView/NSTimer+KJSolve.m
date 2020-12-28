//
//  NSTimer+KJSolve.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2019/12/25.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "NSTimer+KJSolve.h"

@implementation NSTimer (KJSolve)

+ (NSTimer*)kj_bannerScheduledTimerWithTimeInterval:(NSTimeInterval)inerval Repeats:(BOOL)repeats Block:(void(^)(NSTimer*timer))block{
    return [NSTimer scheduledTimerWithTimeInterval:inerval target:self selector:@selector(bannerblcokInvoke:) userInfo:[block copy] repeats:repeats];
}
+ (void)bannerblcokInvoke:(NSTimer*)timer {
    void (^block)(NSTimer *timer) = timer.userInfo;
    if (block) block(timer);
}

@end
