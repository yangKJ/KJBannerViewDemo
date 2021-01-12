//
//  KJBannerViewCell.m
//  KJBannerView
//
//  Created by 杨科军 on 2018/2/27.
//  Copyright © 2018年 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJBannerViewCell.h"
#import "KJLoadImageView.h"
#import "UIImage+KJBannerGIF.h"
@interface KJBannerViewCell()
@property (nonatomic,strong) KJLoadImageView *loadImageView;
@end

@implementation KJBannerViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        self.layer.contentsScale = [UIScreen mainScreen].scale;
        self.layer.drawsAsynchronously = YES;
    }
    return self;
}
- (void)setItemView:(UIView*)itemView{
    if (_itemView) [_itemView removeFromSuperview];
    _itemView = itemView;
    [self.contentView addSubview:itemView];
}

- (void)setInfo:(KJBannerDatasInfo*)info{
    _info = info;
    if (info.image) {
        self.loadImageView.image = info.image;
    }else{
        [self performSelector:@selector(kj_loadImageView) withObject:nil afterDelay:0.0 inModes:@[NSDefaultRunLoopMode]];
    }
}
/// 下载图片，并渲染到cell上显示
- (void)kj_loadImageView{
    __weak __typeof(&*self) weakself = self;
    switch (_info.type) {
        case KJBannerImageInfoTypeLocalityGIF:{
            kGCD_banner_async(^{
                weakself.info.image = [UIImage kj_bannerGIFImageWithData:weakself.info.data];
                kGCD_banner_main(^{weakself.loadImageView.image = weakself.info.image;});
            });
        }
            break;
        case KJBannerImageInfoTypeLocality:
            self.loadImageView.image = self.placeholderImage;
            break;
        case KJBannerImageInfoTypeGIFImage:{
            if (self.openGIFCache == NO) {
                kGCD_banner_async(^{
                    if (weakself.info.data) {
                        weakself.info.image = [UIImage kj_bannerGIFImageWithData:weakself.info.data];
                    }else{
                        weakself.info.image = [UIImage kj_bannerGIFImageWithURL:[NSURL URLWithString:weakself.info.imageUrl]];
                    }
                    kGCD_banner_main(^{weakself.loadImageView.image = weakself.info.image;});
                });
            }else{
                [self.loadImageView kj_setGIFImageWithURLString:self.info.imageUrl Placeholder:self.placeholderImage Completion:^(UIImage * _Nonnull image) {
                    weakself.info.image = image;
                }];
            }
        }
            break;
        case KJBannerImageInfoTypeNetIamge:{
            [self.loadImageView kj_setImageWithURLString:self.info.imageUrl Placeholder:self.placeholderImage Completion:^(UIImage * _Nonnull image) {
                weakself.info.image = image;
            }];
        }
            break;
        default:
            break;
    }
}
NS_INLINE void kGCD_banner_main(dispatch_block_t block) {
    dispatch_queue_t queue = dispatch_get_main_queue();
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {
        block();
    }else{
        if ([[NSThread currentThread] isMainThread]) {
            dispatch_async(queue, block);
        }else{
            dispatch_sync(queue, block);
        }
    }
}

#pragma mark - lazy
- (KJLoadImageView*)loadImageView{
    if(!_loadImageView){
        _loadImageView = [[KJLoadImageView alloc]initWithFrame:self.bounds];
        _loadImageView.contentMode = self.bannerContentMode;
        _loadImageView.kj_isScale = self.bannerScale;
        [self.contentView addSubview:_loadImageView];
        if (self.bannerRadius > 0) {
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = self.bounds;
            maskLayer.path = ({
                UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:_loadImageView.bounds cornerRadius:self.bannerRadius];
                path.CGPath;
            });
            _loadImageView.layer.mask = maskLayer;
        }
    }
    return _loadImageView;
}

@end
