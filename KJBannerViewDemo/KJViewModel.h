//
//  KJViewModel.h
//  KJBannerViewDemo
//
//  Created by 77。 on 2020/9/18.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import <Foundation/Foundation.h>
#import "KJBannerModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KJViewModel : NSObject

@property (nonatomic, strong) NSArray<KJBannerModel *> *datas;

/// 模拟网络请求
/// @param refresh 请求回调
/// @param have 是否有数据
- (void)refresh:(void(^)(NSArray<KJBannerModel *>* datas))refresh haveDatas:(BOOL)have;

/// 缓存大小
+ (CGFloat)cacheSize;

/// 清除缓存
+ (void)clearCache;

@end

NS_ASSUME_NONNULL_END
