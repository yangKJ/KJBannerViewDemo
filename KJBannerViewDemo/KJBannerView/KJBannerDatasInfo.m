//
//  KJBannerDatasInfo.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/12/8.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJBannerDatasInfo.h"
#import "UIImage+KJBannerGIF.h"
@implementation KJBannerDatasInfo
- (void)setImageUrl:(NSString*)imageUrl{
    _imageUrl = imageUrl;
    __weak __typeof(&*self) weakself = self;
    void (^kDealLocalityImage)(void) = ^{
        weakself.data = kGetLocalityGIFData(imageUrl);
        if (weakself.data) {
            kGCD_banner_async(^{weakself.image = [UIImage kj_bannerGIFImageWithData:weakself.data];});
            weakself.type = KJBannerImageInfoTypeLocalityGIF;
        }else{
            weakself.image = [UIImage imageNamed:imageUrl]?:weakself.placeholderImage;
            weakself.type = KJBannerImageInfoTypeLocality;
        }
    };
    void (^kDealNetworkingImage)(void) = ^{
        if (!kValid(imageUrl)) {
            weakself.image = weakself.placeholderImage;
            weakself.type = KJBannerImageInfoTypeLocality;
        }else{
            weakself.data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            if (kContentType(weakself.data) == KJBannerImageTypeGif) {
                kGCD_banner_async(^{weakself.image = [UIImage kj_bannerGIFImageWithData:weakself.data];});
                weakself.type = KJBannerImageInfoTypeGIFImage;
            }else{
                weakself.type = KJBannerImageInfoTypeNetIamge;
            }
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
/// 获取动态图资源
NS_INLINE NSData * _Nullable kGetLocalityGIFData(NSString *name){
    NSBundle *bundle = [NSBundle mainBundle];
    NSData *data = [NSData dataWithContentsOfFile:[bundle pathForResource:name ofType:@"gif"]];
    if (data == nil) {
        data = [NSData dataWithContentsOfFile:[bundle pathForResource:name ofType:@"GIF"]];
    }
    return data;
}
/// 判断是网络图片还是本地
NS_INLINE bool kLocality(NSString * urlString){
    return ([urlString hasPrefix:@"http"] || [urlString hasPrefix:@"https"]) ? false : true;
}
/// 判断该字符串是不是一个有效的URL
NS_INLINE bool kValid(NSString * urlString){
    NSString *regex = @"[a-zA-z]+://[^\\s]*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [predicate evaluateWithObject:urlString];
}
/// 根据DATA判断图片类型
NS_INLINE KJBannerImageType kContentType(NSData * data){
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return KJBannerImageTypeJpeg;
        case 0x89:
            return KJBannerImageTypePng;
        case 0x47:
            return KJBannerImageTypeGif;
        case 0x49:
        case 0x4D:
            return KJBannerImageTypeTiff;
        case 0x52:
            if ([data length] < 12) return KJBannerImageTypeUnknown;
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) return KJBannerImageTypeWebp;
            return KJBannerImageTypeUnknown;
    }
    return KJBannerImageTypeUnknown;
}

@end
