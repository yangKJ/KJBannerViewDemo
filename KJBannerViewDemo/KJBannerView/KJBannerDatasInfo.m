//
//  KJBannerDatasInfo.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/12/8.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJBannerDatasInfo.h"
#import "UIImage+KJBannerGIF.h"
#import "KJBannerTool.h"
@implementation KJBannerDatasInfo
- (void)setImageUrl:(NSString*)imageUrl{
    _imageUrl = imageUrl;
    __weak __typeof(&*self) weakself = self;
    void (^kDealLocalityImage)(void) = ^{
        weakself.data = kGetLocalityGIFData(imageUrl);
        if (weakself.data) {
            kGCD_banner_async(^{
                weakself.image = [UIImage kj_bannerGIFImageWithData:weakself.data];
            });
            weakself.type = KJBannerImageInfoTypeLocalityGIF;
        }else{
            weakself.image = [UIImage imageNamed:imageUrl];
            weakself.type = KJBannerImageInfoTypeLocality;
        }
    };
    void (^kDealNetworkingImage)(void) = ^{
        weakself.data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        if ([KJBannerTool contentTypeWithImageData:weakself.data] == KJBannerImageTypeGif) {
            kGCD_banner_async(^{
                weakself.image = [UIImage kj_bannerGIFImageWithData:weakself.data];
            });
            weakself.type = KJBannerImageInfoTypeGIFImage;
        }else{
            weakself.type = KJBannerImageInfoTypeNetIamge;
        }
    };
    
    switch (weakself.superType) {
        case KJBannerViewImageTypeMix:
            if (kLocality(imageUrl)) {
                kDealLocalityImage();
            }else{
                kDealNetworkingImage();
            }
            break;
        case KJBannerViewImageTypeLocality:
            kDealLocalityImage();
            break;
        case KJBannerViewImageTypeGIFAndNet:
        case KJBannerViewImageTypeNetIamge:
        case KJBannerViewImageTypeGIFImage:
            kDealNetworkingImage();
            break;
        default:
            break;
    }
}
#pragma mark - private
NS_INLINE bool kLocality(NSString *url){
    return ([url hasPrefix:@"http"] || [url hasPrefix:@"https"]) ? false : true;
}
NS_INLINE NSData * _Nullable kGetLocalityGIFData(NSString *name){
    NSBundle *bundle = [NSBundle mainBundle];
    NSData *data = [NSData dataWithContentsOfFile:[bundle pathForResource:name ofType:@"gif"]];
    if (data == nil) {
        data = [NSData dataWithContentsOfFile:[bundle pathForResource:name ofType:@"GIF"]];
    }
    return data;
}
void kGCD_banner_async(dispatch_block_t block) {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {
        block();
    }else{
        dispatch_async(queue, block);
    }
}

@end
