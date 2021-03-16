//
//  KJBannerViewCell.m
//  KJBannerView
//
//  Created by 杨科军 on 2018/2/27.
//  Copyright © 2018年 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJBannerViewCell.h"
#import "UIView+KJWebImage.h"

@interface KJBannerViewCell()
@property (nonatomic,strong) UIImageView *bannerImageView;
@end
@implementation KJBannerViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.layer.contentsScale = [UIScreen mainScreen].scale;
        self.layer.drawsAsynchronously = YES;
    }
    return self;
}
- (void)setItemView:(UIView*)itemView{
    if (_itemView) [_itemView removeFromSuperview];
    _itemView = itemView;
    [self addSubview:itemView];
}
/// 判断是网络图片还是本地
NS_INLINE bool kBannerLocality(NSString * _Nonnull urlString){
    return ([urlString hasPrefix:@"http://"] || [urlString hasPrefix:@"https://"]) ? false : true;
}
- (void)setBannerDatas:(KJBannerDatas*)info{
    _bannerDatas = info;
    if (info.bannerImage) {
        self.bannerImageView.image = info.bannerImage;
    }else{
        if (kBannerLocality(info.bannerURLString)) {
            NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:info.bannerURLString ofType:@"gif"]];
            if (data == nil) {
                data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:info.bannerURLString ofType:@"GIF"]];
            }
            if (data) {
                __banner_weakself;
                kBannerAsyncPlayImage(^(UIImage * _Nullable image) {
                    weakself.bannerImageView.image = info.bannerImage = image?:weakself.bannerPlaceholder;
                }, data);
            }else{
                self.bannerImageView.image = info.bannerImage = [UIImage imageNamed:info.bannerURLString]?:self.bannerPlaceholder;
            }
        }else{
            [self performSelector:@selector(kj_bannerImageView) withObject:nil afterDelay:0.0 inModes:@[NSDefaultRunLoopMode]];
        }
    }
}
/// 下载图片，并渲染到cell上显示
- (void)kj_bannerImageView{
    __banner_weakself;
    [self.bannerImageView kj_setImageWithURL:[NSURL URLWithString:self.bannerDatas.bannerURLString] handle:^(id<KJBannerWebImageHandle>handle) {
        handle.bannerPlaceholder = weakself.bannerPlaceholder;
        handle.cropScale = weakself.bannerScale;
        handle.bannerCompleted = ^(KJBannerImageType imageType, UIImage * image, NSData * data, NSError * error) {
            weakself.bannerDatas.bannerImage = image;
        };
    }];
}

#pragma mark - lazy
- (UIImageView*)bannerImageView{
    if(_bannerImageView == nil){
        _bannerImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        _bannerImageView.contentMode = self.bannerContentMode;
        _bannerImageView.image = self.bannerPlaceholder;
        [self addSubview:_bannerImageView];
        if (self.bannerRadius > 0) {
            if (self.bannerNoPureBack) {
                _bannerImageView.layer.cornerRadius = self.bannerRadius;
                _bannerImageView.layer.masksToBounds = YES;
            }else{
                CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
                shapeLayer.frame = self.bounds;
                _bannerImageView.clipsToBounds = YES;
                [_bannerImageView.layer addSublayer:shapeLayer];
                kBannerAsyncCornerRadius(self.bannerRadius, ^(UIImage *image) {
                    shapeLayer.contents = (id)image.CGImage;
                }, self.bannerCornerRadius, _bannerImageView);
            }
        }
    }
    return _bannerImageView;
}

@end
@implementation KJBannerDatas

@end
