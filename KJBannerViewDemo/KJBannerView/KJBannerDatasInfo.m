//
//  KJBannerDatasInfo.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/12/8.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJBannerDatasInfo.h"

@implementation KJBannerDatasInfo
- (void)setImageUrl:(NSString*)imageUrl{
    _imageUrl = imageUrl;
    __weak __typeof(&*self) weakself = self;
    kGCD_banner_async(^{
        switch (weakself.superType) {
            case KJBannerViewImageTypeMix:{
                if ([KJBannerTool kj_bannerImageWithImageUrl:imageUrl]) {
                    weakself.type = KJBannerImageInfoTypeLocality;
                    weakself.image = [UIImage imageNamed:imageUrl];
                }else if ([KJBannerTool kj_bannerIsGifWithURL:imageUrl]) {
                    weakself.image = [UIImage kj_bannerGIFImageWithURL:[NSURL URLWithString:imageUrl]];
                    weakself.type = KJBannerImageInfoTypeGIFImage;
                }else{
                    weakself.type = KJBannerImageInfoTypeNetIamge;
                }
            }
                break;
            case KJBannerViewImageTypeGIFAndNet:{
                if ([KJBannerTool kj_bannerIsGifWithURL:imageUrl]) {
                    weakself.image = [UIImage kj_bannerGIFImageWithURL:[NSURL URLWithString:imageUrl]];
                    weakself.type = KJBannerImageInfoTypeGIFImage;
                }else{
                    weakself.type = KJBannerImageInfoTypeNetIamge;
                }
            }
                break;
            case KJBannerViewImageTypeLocality:{
                weakself.type = KJBannerImageInfoTypeLocality;
                weakself.image = [UIImage imageNamed:imageUrl];
            }
                break;
            case KJBannerViewImageTypeNetIamge:{
                weakself.type = KJBannerImageInfoTypeNetIamge;
            }
                break;
            case KJBannerViewImageTypeGIFImage:{
                weakself.image = [UIImage kj_bannerGIFImageWithURL:[NSURL URLWithString:imageUrl]];
                weakself.type = KJBannerImageInfoTypeGIFImage;
            }
                break;
            default:
                break;
        }
    });
}

NS_INLINE void kGCD_banner_async(dispatch_block_t block) {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {
        block();
    }else{
        dispatch_async(queue, block);
    }
}

@end
