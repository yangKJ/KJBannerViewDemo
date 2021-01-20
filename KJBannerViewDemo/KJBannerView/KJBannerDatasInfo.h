//
//  KJBannerDatasInfo.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/12/8.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KJBannerViewType.h"
NS_ASSUME_NONNULL_BEGIN

@interface KJBannerDatasInfo : NSObject
@property (nonatomic,strong) NSData *data;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) NSString *imageUrl;
@property (nonatomic,strong) UIImage *placeholderImage;
@property (nonatomic,assign) KJBannerImageInfoType type;
@property (nonatomic,assign) KJBannerViewImageType superType;
@end

NS_ASSUME_NONNULL_END
