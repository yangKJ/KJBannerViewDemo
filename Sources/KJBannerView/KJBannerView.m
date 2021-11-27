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
#import "KJPageControl.h"
#import "KJBannerViewFlowLayout.h"
#import "KJBannerViewTimer.h"
#import "KJBannerViewFunc.h"
#import "KJBannerViewPreRendered.h"

#define kPageHeight (20)

@interface KJBannerView() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) KJBannerViewFlowLayout *layout;
@property (nonatomic,strong) KJPageControl *pageControl;
@property (nonatomic,strong) CALayer *topLayer;
@property (nonatomic,assign) CGFloat height;
@property (nonatomic,assign) CGFloat lastX,lastY;
@property (nonatomic,strong) KJBannerViewTimer *timer;
@property (nonatomic,assign) NSInteger shamItemCount;// 虚假Cell个数，无穷大看着像无限轮播
@property (nonatomic,assign) NSInteger numberOfItems;// 真实Cell个数
@property (nonatomic,strong) KJBannerViewPreRendered *preRendered;

@end

@implementation KJBannerView

- (void)dealloc{
    [self.timer kj_invalidateTimer];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupInit];
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupInit];
        [self setupUI];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    [self.timer kj_pauseTimer];
}

- (void)setupInit{
    _itemWidth = self.bounds.size.width;
    _height = self.bounds.size.height;
    _itemSpace = 0;
    _autoTime = 2;
    _infiniteLoop = YES;
    _autoScroll = YES;
    _showPageControl = YES;
    _rollType = KJBannerViewRollDirectionTypeRightToLeft;
    _placeholderImage = [UIImage imageNamed:@"KJBannerView.bundle/KJBannerPlaceholderImage.png"];
}

- (void)setupUI{
    [self addSubview:self.collectionView];
    [self addSubview:self.pageControl];
    [self.layer addSublayer:self.topLayer];
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
        [self.preRendered clearCacheImages];
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
        [self.pageControl scrollToIndex:idx];
    }
    UICollectionViewScrollPosition position = UICollectionViewScrollPositionCenteredVertically;
    if (_layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        position = UICollectionViewScrollPositionCenteredHorizontally;
    }
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                                atScrollPosition:position animated:animated];
    if ([self.delegate respondsToSelector:@selector(kj_bannerView:loopScrolledItemAtIndex:)]) {
        [self.delegate kj_bannerView:self loopScrolledItemAtIndex:idx];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
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
    if (_numberOfItems == 0) {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"banner_identifier"
                                                         forIndexPath:indexPath];
    }
    NSInteger itemIndex = indexPath.item % _numberOfItems;
    KJBannerViewCell *bannerViewCell = [self.dataSource kj_bannerView:self cellForItemAtIndex:itemIndex];
    if ([bannerViewCell isMemberOfClass:[KJBannerViewCell class]]) {
        /// 预渲染处理
        [self preRenderedImageWithIndex:itemIndex];
        /// 读取预加载数据
        [self preLoadWithBannerViewCell:bannerViewCell];
    }
    return bannerViewCell;
}

/// 预渲染处理
/// @param index 当前Index
- (void)preRenderedImageWithIndex:(NSInteger)index{
    if ([self.dataSource respondsToSelector:@selector(kj_bannerView:nextPreRenderedImageItemAtIndex:)]) {
        NSInteger nextIndex = index;
        switch (_rollType) {
            case KJBannerViewRollDirectionTypeRightToLeft:
            case KJBannerViewRollDirectionTypeBottomToTop:
                nextIndex++;
                if (nextIndex >= _numberOfItems) nextIndex = 0;
                break;
            case KJBannerViewRollDirectionTypeLeftToRight:
            case KJBannerViewRollDirectionTypeTopToBottom:
                nextIndex--;
                if (nextIndex < 0) nextIndex = _numberOfItems - 1;
                break;
            default:break;
        }
        NSString * nextString = [self.dataSource kj_bannerView:self
                               nextPreRenderedImageItemAtIndex:nextIndex];
        if (nextString != nil && nextString.length > 0) {
            __banner_weakself;
            [self.preRendered preRenderedImageWithUrl:nextString withBlock:^(UIImage * image) {
                if ([weakself.dataSource respondsToSelector:@selector(kj_bannerView:preRenderedImage:)]) {
                    [weakself.dataSource kj_bannerView:weakself preRenderedImage:image];
                }
            }];
        }
    }
}

/// 读取预加载数据
- (void)preLoadWithBannerViewCell:(__kindof KJBannerViewCell *)cell{
#if __has_include("KJWebImageHeader.h")
    if (cell.useMineLoadImage && cell.imageURLString) {
        [cell setValue:self.placeholderImage forKey:@"placeholderImage"];
        /// 读取预加载数据
        UIImage * cacheImage = [self.preRendered readCacheImageWithUrl:cell.imageURLString];
        SEL sel = NSSelectorFromString(@"drawBannerImage:");
        if ([cell respondsToSelector:sel]) {
            IMP imp = [cell methodForSelector:sel];
            void (* tempFunc)(id, SEL, UIImage *) = (void *)imp;
            tempFunc(cell, sel, cacheImage);
        }
    }
#endif
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
        [_collectionView registerClass:[UICollectionViewCell class]
            forCellWithReuseIdentifier:@"banner_identifier"];
    }
    return _collectionView;
}
- (KJPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [[KJPageControl alloc] init];
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

- (KJBannerViewPreRendered *)preRendered{
    if (!_preRendered) {
        _preRendered = [[KJBannerViewPreRendered alloc] init];
    }
    return _preRendered;
}

@end
