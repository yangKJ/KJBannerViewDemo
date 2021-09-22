//
//  KJViewModel.m
//  KJBannerViewDemo
//
//  Created by 77。 on 2020/9/18.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJViewModel.h"
#import "KJBannerViewCacheManager.h"
#import "KJBannerViewTimer.h"

#define gif @"https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7a00f7f6c0c744a893f304a7d3b629b5~tplv-k3u1fbpfcp-watermark.image?"

#define tu1 @"https://img.jwfzl.com.cn/storage/20210422/60810d41b6303.jpeg"
#define tu2 @"http://photos.tuchong.com/285606/f/4374153.jpg"
#define tu3 @"https://tfile.melinked.com/2021/01/5c071de1-b7e9-4bf4-a1f7-a2f35eff9ed6.jpg"

@implementation KJViewModel

/// 模拟网络请求
/// @param refresh 请求回调
/// @param have 是否有数据
- (void)refresh:(void(^)(NSArray<KJBannerModel *>* datas))refresh haveDatas:(BOOL)have{
    if (have == NO) {
//        KJBannerModel *model = [[KJBannerModel alloc]init];
//        model.customImageUrl = gif;
//        model.customTitle = @"单图";
//        self.datas = @[model];
        self.datas = @[];
        refresh ? refresh(self.datas) : nil;
        return;
    }
    NSMutableArray *array = [NSMutableArray array];
    dispatch_group_t dispatchGroup = dispatch_group_create();
    dispatch_group_enter(dispatchGroup);
    dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                       dispatch_get_global_queue(0, 0), ^{
            NSArray *images = @[tu3,tu2,tu1];
            for (int i = 0; i < images.count; i++) {
                KJBannerModel *model = [[KJBannerModel alloc]init];
                model.customImageUrl = images[i];
                model.customTitle = [NSString stringWithFormat:@"A线程图片名称:%d",i];
                [array addObject:model];
            }
            dispatch_group_leave(dispatchGroup);
        });
    });
    dispatch_group_enter(dispatchGroup);
    dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                       dispatch_get_global_queue(0, 0), ^{
            NSArray *images = @[@"",@"xsi"];
            for (int i = 0; i < images.count; i++) {
                KJBannerModel *model = [[KJBannerModel alloc]init];
                model.customImageUrl = images[i];
                model.customTitle = @"B线程图片地址";
                [array addObject:model];
            }
            dispatch_group_leave(dispatchGroup);
        });
    });
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(){
        self.datas = array.mutableCopy;
        refresh ? refresh(array) : nil;
    });
}

/// 缓存大小
+ (CGFloat)cacheSize{
    return [KJBannerViewCacheManager kj_getLocalityImageCacheSize] / 1024 / 1024.0;
}

/// 清除缓存
+ (void)clearCache{
    [KJBannerViewCacheManager kj_clearLocalityImageAndCache];
}

@end
