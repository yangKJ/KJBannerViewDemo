//
//  KJPageView.h
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2019/5/27.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import <UIKit/UIKit.h>
#import "KJBannerViewType.h"
NS_ASSUME_NONNULL_BEGIN

@interface KJPageView : UIView
/// 总共点数
@property(nonatomic,assign) IBInspectable NSInteger totalPages;
/// 当前点，默认第一个点
@property(nonatomic,assign) IBInspectable NSInteger currentIndex;
/// 选中的色，默认白色
@property(nonatomic,strong) IBInspectable UIColor *selectColor;
/// 背景色，默认灰色
@property(nonatomic,strong) IBInspectable UIColor *normalColor;
/// 方块间隙，默认大小点5px，其余8px
@property(nonatomic,assign) IBInspectable CGFloat margin;
/// 方块宽度
@property(nonatomic,assign) IBInspectable CGFloat dotwidth;
/// 方块高度
@property(nonatomic,assign) IBInspectable CGFloat dotheight;
/// 类别，默认长方形
@property(nonatomic,assign) KJPageControlStyle pageType;
/// 距离边界间隙，默认10px
@property(nonatomic,assign) IBInspectable CGFloat space;
/// 控件位置，默认居中
@property(nonatomic,assign) KJPageControlDisplayType displayType;
/// 非自动滚动情况
- (void)kj_notAutomaticScrollIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
