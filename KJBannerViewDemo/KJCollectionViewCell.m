//
//  KJCollectionViewCell.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2019/1/13.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "KJCollectionViewCell.h"
#import "KJLoadImageView.h"
@interface KJCollectionViewCell ()
@property (strong, nonatomic) UILabel *label;
@end

@implementation KJCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self.contentView addSubview:self.label];
    }
    return self;
}

- (void)setModel:(NSObject*)model{
    self.label.text = (NSString*)model;
}
- (UILabel*)label{
    if (!_label) {
        _label = [[UILabel alloc]initWithFrame:self.bounds];
        _label.textColor = UIColor.blackColor;
        _label.font = [UIFont boldSystemFontOfSize:16];
    }
    return _label;
}

@end
