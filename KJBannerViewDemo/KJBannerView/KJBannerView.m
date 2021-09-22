//
//  KJBannerView.m
//  KJBannerView
//
//  Created by 杨科军 on 2018/2/27.
//  Copyright © 2018年 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJBannerView.h"
#import "KJBannerViewCell.h"
#import <objc/runtime.h>
#import "KJPageView.h"
#import "KJBannerViewFlowLayout.h"
#import "KJBannerViewTimer.h"
#import "KJBannerViewFunc.h"

#define kPageHeight (20)

@interface KJBannerView() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) KJBannerViewFlowLayout *layout;
@property (nonatomic,strong) KJPageView *pageControl;
@property (nonatomic,strong) CALayer *topLayer;
@property (nonatomic,assign) CGFloat height;
@property (nonatomic,assign) CGFloat lastX,lastY;
@property (nonatomic,strong) KJBannerViewTimer *timer;
@property (nonatomic,assign) NSInteger shamItemCount;// 虚假Cell个数，无穷大看着像无限轮播
@property (nonatomic,assign) NSInteger numberOfItems;// 真实Cell个数
@property (nonatomic,strong) NSMutableDictionary *cacheImageDict;// 缓存区已经显示过的图片资源

@end

@implementation KJBannerView

/// 设置默认参数
- (void)kj_config{
    _itemWidth = self.bounds.size.width;
    _height = self.bounds.size.height;
    _itemSpace = 0;
    _autoTime = 2;
    _infiniteLoop = YES;
    _autoScroll = YES;
    _showPageControl = YES;
    _rollType = KJBannerViewRollDirectionTypeRightToLeft;
    _cacheImageDict = [NSMutableDictionary dictionary];
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self kj_config];
        [self addSubview:self.collectionView];
        [self addSubview:self.pageControl];
        [self.layer addSublayer:self.topLayer];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self kj_config];
        [self addSubview:self.collectionView];
        [self addSubview:self.pageControl];
        [self.layer addSublayer:self.topLayer];
    }
    return self;
}
- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    [self.timer kj_pauseTimer];
}
- (void)dealloc{
    [self.timer kj_invalidateTimer];
}

#pragma mark - public method

/// 注册一个类，用于创建 `UICollectionViewCell`
/// @param clazz 类
/// @param identifier 标识符
- (void)registerClass:(Class)clazz forCellWithReuseIdentifier:(NSString *)identifier{
    [self.collectionView registerClass:clazz forCellWithReuseIdentifier:identifier];
}

/// 注册一个类，用于创建 `UICollectionViewCell`
/// @param nib UINib
/// @param identifier 标识符
- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier{
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}

/// 创建 `UICollectionViewCell`
/// @param identifier 标识符
/// @param index 下标
- (__kindof KJBannerViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier
                                                             forIndex:(NSInteger)index{
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    id cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (![cell isKindOfClass:[KJBannerViewCell class]]) {
        NSAssert(YES, @"Cell class must be subclass of KJBannerViewCell");
    }
    return (__kindof KJBannerViewCell *)cell;
}
/// 刷新
- (void)reloadData{
    if ([self.dataSource respondsToSelector:@selector(kj_numberOfItemsInBannerView:)]) {
        [self.cacheImageDict removeAllObjects];
        self.numberOfItems = [self.dataSource kj_numberOfItemsInBannerView:self];
    }
}

/// 滚动到指定位置
/// @param index 指定位置
/// @param animated 是否执行动画
- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated{
    [self kj_scrollToIndex:index autoScroll:NO animated:animated];
}

/// 暂停计时器滚动处理
- (void)kj_pauseTimer{
    [self.timer kj_pauseTimer];
}
/// 继续计时器滚动
- (void)kj_repauseTimer{
    [self.timer kj_startTimer];
}

/// 使用Masonry自动布局，请在设置布局之后调用该方法
- (void)kj_useMasonry{
    [self layoutIfNeeded];
    if (self.bounds.size.height <= 0) return;
    self.height = self.bounds.size.height;
    self.collectionView.frame = self.bounds;
    self.layout.itemSize = CGSizeMake(_itemWidth, self.height);
    self.pageControl.frame = CGRectMake(0, self.height-kPageHeight, self.bounds.size.width, kPageHeight);
    [self.topLayer setBounds:self.bounds];
    [self.topLayer setPosition:CGPointMake(self.bounds.size.width*.5, self.bounds.size.height*.5)];
}
/// 滚动到指定位置
- (void)kj_makeScrollToIndex:(NSInteger)index{
    [self scrollToItemAtIndex:index animated:YES];
}
/// 如果为异步操作获取到数据源之后，请刷新
- (void)kj_reloadBannerViewDatas{
    [self reloadData];
}

#pragma mark - setter/getter

- (void)setIsZoom:(BOOL)isZoom{
    _isZoom = isZoom;
    self.layout.isZoom = isZoom;
}
- (void)setAutoScroll:(BOOL)autoScroll{
    _autoScroll = autoScroll;
    if (autoScroll) {
        if (self.timer.pausing) {
            [self.timer kj_startTimer];
        }
    } else {
        [self.timer kj_invalidateTimer];
    }
}
- (void)setShowPageControl:(BOOL)showPageControl{
    _showPageControl = showPageControl;
    self.pageControl.hidden = !showPageControl;
}
- (void)setAutoTime:(CGFloat)autoTime{
    if (_autoTime != autoTime) {
        _autoTime = autoTime;
        [self.timer kj_invalidateTimer];
        _timer = nil;
        if (self.timer && self.autoScroll) {
            [self.timer kj_startTimer];
        }
    }
}
- (void)setItemWidth:(CGFloat)itemWidth{
    _itemWidth = itemWidth;
    self.layout.itemSize = CGSizeMake(itemWidth, self.height);
}
- (void)setItemSpace:(CGFloat)itemSpace{
    _itemSpace = itemSpace;
    self.layout.minimumLineSpacing = itemSpace;
}
- (void)setRollType:(KJBannerViewRollDirectionType)rollType{
    _rollType = rollType;
    if (rollType == KJBannerViewRollDirectionTypeRightToLeft ||
        rollType == KJBannerViewRollDirectionTypeLeftToRight) {
        self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    } else {
        self.layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
}
- (void)setNumberOfItems:(NSInteger)numberOfItems{
    _numberOfItems = numberOfItems;
    if (numberOfItems == 0) {
        self.shamItemCount = 0;
        self.topLayer.hidden = NO;
        self.pageControl.hidden = YES;
        self.collectionView.hidden = YES;
        [self.timer kj_pauseTimer];
        return;
    }
    self.topLayer.hidden = YES;
    self.collectionView.hidden = NO;
    if (numberOfItems == 1) {
        self.shamItemCount = 9;
        self.pageControl.hidden = YES;
        self.collectionView.scrollEnabled = NO;
        [self.timer kj_pauseTimer];
    } else {
        if (CGRectEqualToRect(self.pageControl.frame, CGRectZero)) {
            [self kj_useMasonry];
        }
        self.shamItemCount = self.infiniteLoop ? 100 * numberOfItems : numberOfItems;
        self.pageControl.hidden = !self.showPageControl;
        self.pageControl.totalPages = numberOfItems;
        self.collectionView.scrollEnabled = YES;
        [self setAutoScroll:self.autoScroll];
    }
    [self.collectionView reloadData];
    NSInteger index = self.infiniteLoop ? (int)(self.shamItemCount / 2) : 0;
    [self kj_scrollToIndex:index autoScroll:self.autoScroll animated:YES];
}
/// 当前位置
- (NSInteger)currentIndex{
    NSInteger index = 0;
    if (_layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        float wT = (_itemWidth + _itemSpace);
        index = (self.collectionView.contentOffset.x + wT * 0.5) / wT;
    } else {
        float wT = self.height;
        index = (self.collectionView.contentOffset.y + wT * 0.5) / wT;
    }
    return MAX(0, index);
}

#pragma mark - private method

/// 自动滚动
- (void)kj_automaticScroll{
    if(_numberOfItems == 0) return;
    NSInteger index = [self currentIndex];
    switch (_rollType) {
        case KJBannerViewRollDirectionTypeRightToLeft:
        case KJBannerViewRollDirectionTypeBottomToTop:
            if (index == self.shamItemCount - 10) index = 10;
            index++;
            break;
        case KJBannerViewRollDirectionTypeLeftToRight:
        case KJBannerViewRollDirectionTypeTopToBottom:
            if (index == 10) index = self.shamItemCount - 10;
            index--;
            break;
        default:break;
    }
    [self kj_scrollToIndex:index autoScroll:YES animated:YES];
}
/// 滚动到指定位置
- (void)kj_scrollToIndex:(NSInteger)index autoScroll:(BOOL)autoScroll animated:(BOOL)animated{
    if (_numberOfItems == 0) {
        return;
    }
    NSInteger idx = index % _numberOfItems;
    if (autoScroll) {
        self.pageControl.currentIndex = idx;
    } else if (self.pageControl.hidden == NO){
        [self.pageControl kj_notAutomaticScrollIndex:idx];
    }
    if ([self.delegate respondsToSelector:@selector(kj_bannerView:loopScrolledItemAtIndex:)]) {
        [self.delegate kj_bannerView:self loopScrolledItemAtIndex:idx];
    }
    UICollectionViewScrollPosition position = UICollectionViewScrollPositionCenteredVertically;
    if (_layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        position = UICollectionViewScrollPositionCenteredHorizontally;
    }
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                                atScrollPosition:position animated:animated];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    self.collectionView.userInteractionEnabled = NO;
    if (_numberOfItems == 0) return;
    if ([self.delegate respondsToSelector:@selector(kj_bannerViewDidScroll:)]) {
        [self.delegate kj_bannerViewDidScroll:self];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _lastX = scrollView.contentOffset.x;
    _lastY = scrollView.contentOffset.y;
    if (self.autoScroll) {
        [self.timer kj_pauseTimer];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.autoScroll) {
        kGCD_banner_after_main(self.autoTime, ^{
            [self.timer kj_startTimer];
        });
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self scrollViewDidEndScrollingAnimation:self.collectionView];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    self.collectionView.userInteractionEnabled = YES;
}
/// 手离开屏幕的时候
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset{
    self.collectionView.userInteractionEnabled = NO;
    NSInteger idx = 0,dragIndex = 0;
    if (_layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        CGFloat move = scrollView.contentOffset.x - self.lastX;
        NSInteger page = (int)(move / (self.itemWidth * .5));
        if (velocity.x > 0 || page > 0) {
            dragIndex = 1;
        } else if (velocity.x < 0 || page < 0) {
            dragIndex = -1;
        }
        idx = (_lastX + (self.itemWidth + self.itemSpace) * 0.5) / (self.itemSpace + self.itemWidth);
    } else {
        CGFloat move = scrollView.contentOffset.y - self.lastY;
        NSInteger page = move / (self.height*.5);
        if (velocity.y > 0 || page > 0) {
            dragIndex = 1;
        } else if (velocity.y < 0 || page < 0) {
            dragIndex = -1;
        }
        idx = (_lastY + (self.height) * 0.5) / (self.height);
    }
    [self kj_scrollToIndex:idx + dragIndex autoScroll:NO animated:YES];
}
/// 松开手指滑动开始减速的时候设置滑动动画
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
//    NSInteger idx = 0;
//    if (_layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
//        idx = (_lastX + (self.itemWidth + self.itemSpace) * 0.5) / (self.itemSpace + self.itemWidth);
//    } else {
//        idx = (_lastY + (self.height) * 0.5) / (self.height);
//    }
//    [self kj_scrollToIndex:idx automaticScroll:NO];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.shamItemCount;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger itemIndex = indexPath.item % _numberOfItems;
    KJBannerViewCell *bannerViewCell = [self.dataSource kj_bannerView:self cellForItemAtIndex:itemIndex];
    if ([bannerViewCell isMemberOfClass:[KJBannerViewCell class]]) {
#if __has_include("UIView+KJWebImage.h")
        if (bannerViewCell.useMineLoadImage && bannerViewCell.imageURLString) {
            /// 自带Cell处理
            bannerViewCell.backgroundColor = self.bannerRadiusColor?:self.backgroundColor;
            [bannerViewCell setValue:@(self.bannerNoPureBack) forKey:@"bannerNoPureBack"];
            [bannerViewCell setValue:@(self.bannerCornerRadius) forKey:@"bannerCornerRadius"];
            [bannerViewCell setValue:@(self.bannerScale) forKey:@"bannerScale"];
            [bannerViewCell setValue:@(self.bannerRadius) forKey:@"bannerRadius"];
            [bannerViewCell setValue:@(self.bannerContentMode) forKey:@"bannerContentMode"];
            [bannerViewCell setValue:@(self.bannerPreRendering) forKey:@"bannerPreRendering"];
            [bannerViewCell setValue:self.placeholderImage forKey:@"placeholderImage"];
            /// 预渲染处理
            if (self.bannerPreRendering && bannerViewCell.nextImageURLString) {
                
            }
            /// 绘制图片，并加入缓存区
            NSString * key = kBannerMD5String(bannerViewCell.imageURLString);
            void(^kSaveCacheImage)(UIImage *) = ^(UIImage * image){
                [self.cacheImageDict setValue:image forKey:key];
            };
            UIImage * cacheImage = self.cacheImageDict[key];
            SEL sel = NSSelectorFromString(@"drawBannerImage:withBlock:");
            if ([bannerViewCell respondsToSelector:sel]) {
                IMP imp = [bannerViewCell methodForSelector:sel];
                void (* tempFunc)(id, SEL, UIImage *, void(^)(UIImage *)) = (void *)imp;
                tempFunc(bannerViewCell, sel, cacheImage, kSaveCacheImage);
            }
        }
#endif
    }
    return bannerViewCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if ([self.delegate respondsToSelector:@selector(kj_bannerView:didSelectItemAtIndex:)]) {
        NSInteger idx = [self currentIndex] % _numberOfItems;
        [self.delegate kj_bannerView:self didSelectItemAtIndex:idx];
    }
}

#pragma mark - lazy

- (CALayer *)topLayer{
    if (!_topLayer) {
        _topLayer = [[CALayer alloc] init];
        [_topLayer setBounds:self.bounds];
        [_topLayer setPosition:CGPointMake(self.bounds.size.width*.5, self.bounds.size.height*.5)];
        [_topLayer setContents:(id)self.placeholderImage.CGImage];
        _topLayer.zPosition = 1;
    }
    return _topLayer;
}
- (KJBannerViewFlowLayout *)layout{
    if (!_layout) {
        _layout = [[KJBannerViewFlowLayout alloc] init];
        _layout.minimumLineSpacing = 0;
        _layout.itemSize = CGSizeMake(_itemWidth, self.frame.size.height);
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _layout;
}
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollsToTop = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = self.backgroundColor;
    }
    return _collectionView;
}
- (KJPageView *)pageControl{
    if (!_pageControl) {
        _pageControl = [[KJPageView alloc] init];
        _pageControl.hidden = YES;
    }
    return _pageControl;
}

- (KJBannerViewTimer *)timer{
    if (!_timer) {
        __banner_weakself;
        _timer = [[KJBannerViewTimer alloc] initWithInterval:self.autoTime repeats:YES task:^{
            [weakself kj_automaticScroll];
        }];
    }
    return _timer;
}

@end

@implementation KJBannerView (KJBannerViewCell)
- (BOOL)bannerScale{
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number == nil) {
        return NO;
    } else {
        return [number boolValue];
    }
}
- (BOOL)bannerNoPureBack{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (BOOL)bannerPreRendering{
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number == nil) {
        return YES;
    } else {
        return [number boolValue];
    }
}
- (CGFloat)bannerRadius{
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}
- (UIImage *)placeholderImage{
    UIImage *image = objc_getAssociatedObject(self, _cmd);
    if (image == nil) image = [UIImage imageNamed:@"KJBannerView.bundle/KJBannerPlaceholderImage"];
    return image;
}
- (UIViewContentMode)bannerContentMode{
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number == nil) {
        return UIViewContentModeScaleAspectFill;
    } else {
        return number.integerValue;
    }
}
- (UIRectCorner)bannerCornerRadius{
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number == nil) {
        return UIRectCornerAllCorners;
    }
    return number.integerValue;
}
- (UIColor *)bannerRadiusColor{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setBannerPreRendering:(BOOL)bannerPreRendering{
    objc_setAssociatedObject(self, @selector(bannerPreRendering), @(bannerPreRendering), OBJC_ASSOCIATION_ASSIGN);
}
- (void)setBannerNoPureBack:(BOOL)bannerNoPureBack{
    objc_setAssociatedObject(self, @selector(bannerNoPureBack), @(bannerNoPureBack), OBJC_ASSOCIATION_ASSIGN);
}
- (void)setBannerScale:(BOOL)bannerScale{
    objc_setAssociatedObject(self, @selector(bannerScale), @(bannerScale), OBJC_ASSOCIATION_ASSIGN);
}
- (void)setBannerCornerRadius:(UIRectCorner)bannerCornerRadius{
    objc_setAssociatedObject(self, @selector(bannerCornerRadius), @(bannerCornerRadius), OBJC_ASSOCIATION_ASSIGN);
}
- (void)setBannerRadius:(CGFloat)bannerRadius{
    objc_setAssociatedObject(self, @selector(bannerRadius), @(bannerRadius), OBJC_ASSOCIATION_ASSIGN);
}
- (void)setPlaceholderImage:(UIImage *)placeholderImage{
    objc_setAssociatedObject(self, @selector(placeholderImage), placeholderImage, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void)setBannerContentMode:(UIViewContentMode)bannerContentMode{
    objc_setAssociatedObject(self, @selector(bannerContentMode), @(bannerContentMode), OBJC_ASSOCIATION_ASSIGN);
}
- (void)setBannerRadiusColor:(UIColor *)bannerRadiusColor{
    objc_setAssociatedObject(self, @selector(bannerRadiusColor), bannerRadiusColor, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
