//
//  KJBannerViewCell.m
//  KJBannerView
//
//  Created by 杨科军 on 2018/2/27.
//  Copyright © 2018年 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJBannerViewCell.h"

@interface KJBannerViewCell()
@property (nonatomic,strong) KJLoadImageView *loadImageView;
@end

@implementation KJBannerViewCell

- (void)setInfo:(KJBannerDatasInfo*)info{
    __weak __typeof(&*self) weakself = self;
    switch (info.type) {
        case KJBannerImageInfoTypeLocality:
            self.loadImageView.image = info.image?:self.placeholderImage;
        case KJBannerImageInfoTypeGIFImage:{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (info.image == nil) info.image = [UIImage kj_bannerGIFImageWithURL:[NSURL URLWithString:info.imageUrl]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakself.loadImageView.image = info.image?:weakself.placeholderImage;
                });
            });
        }
            break;
        case KJBannerImageInfoTypeNetIamge:
            if (info.image == nil) {
                [self.loadImageView kj_setImageWithURLString:info.imageUrl Placeholder:self.placeholderImage Completion:^(UIImage * _Nonnull image) {
                    info.image = image;
                }];
            }else{
                self.loadImageView.image = info.image;
            }
            break;
        default:
            break;
    }
}

#pragma mark - lazy
- (KJLoadImageView*)loadImageView{
    if(!_loadImageView){
        _loadImageView = [[KJLoadImageView alloc]initWithFrame:self.bounds];
        _loadImageView.image = self.placeholderImage;
        _loadImageView.contentMode = self.contentMode;
        _loadImageView.kj_isScale = self.kj_scale;
        [self.contentView addSubview:_loadImageView];
        if (self.imgCornerRadius > 0) {
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = self.bounds;
            maskLayer.path = ({
                UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:_loadImageView.bounds cornerRadius:self.imgCornerRadius];
                path.CGPath;
            });
            _loadImageView.layer.mask = maskLayer;
        }
    }
    return _loadImageView;
}

@synthesize itemView = _itemView;
- (UIView*)itemView{
    if (_itemView == nil) {
        _itemView = [[UIView alloc] init];
    }
    return _itemView;
}
- (void)setItemView:(UIView*)itemView{
    if (_itemView) {
        [_itemView removeFromSuperview];
    }
    _itemView = itemView;
    [self addSubview:_itemView];
}

@end
