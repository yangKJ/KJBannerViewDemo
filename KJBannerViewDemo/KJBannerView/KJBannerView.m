//
//  KJBannerView.m
//  KJBannerView
//
//  Created by 杨科军 on 2018/2/27.
//  Copyright © 2018年 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "KJBannerView.h"
#import "KJBannerViewCell.h"
#import "KJBannerViewFlowLayout.h"
#import <objc/runtime.h>
#define kPageHeight (20)
@interface KJBannerView()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,strong) NSMutableArray<KJBannerDatas*>*temps;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) KJBannerViewFlowLayout *layout;
@property (nonatomic,strong) KJPageView *pageControl;
@property (nonatomic,assign) NSInteger currentIndex;
@property (nonatomic,strong) CALayer *topLayer;
@property (nonatomic,assign) NSInteger nums;
@property (nonatomic,assign) CGFloat height;
@property (nonatomic,assign) CGFloat lastX,lastY;
@property (nonatomic,assign) BOOL useCustomCell;
@property (nonatomic,assign) BOOL useDataSource;
@property (nonatomic,strong) dispatch_source_t timer;
@end

@implementation KJBannerView
/// 设置默认参数
- (void)kj_config{
    _infiniteLoop = YES;
    _autoScroll = YES;
    _isZoom = NO;
    _itemWidth = self.bounds.size.width;
    _height = self.bounds.size.height;
    _itemSpace = 0;
    _autoTime = 2;
    _rollType = KJBannerViewRollDirectionTypeRightToLeft;
    _useCustomCell = NO;
    _useDataSource = NO;
    _showPageControl = YES;
    _itemClass = [KJBannerViewCell class];
}
- (instancetype)initWithCoder:(NSCoder*)aDecoder{
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
- (void)willMoveToSuperview:(UIView*)newSuperview{
    [super willMoveToSuperview:newSuperview];
    [self invalidateTimer];
}

#pragma mark - GCD定时器
/// 开启计时器
- (void)setupTimer{
    if (self.timer) {
        [self kj_bannerResumeTimer:self.timer];
    }else{
        __weak __typeof(self) weakself = self;
        self.timer = [self kj_bannerCreateAsyncTimer:YES Task:^{
            __strong __typeof(self) strongself = weakself;
            kGCD_banner_main(^{
                [strongself automaticScroll];
            });
        } start:self.autoTime/2. interval:self.autoTime repeats:YES];
    }
}
/// 释放计时器
- (void)invalidateTimer{
    if (self.timer) {
        [self kj_bannerStopTimer:self.timer];
        _timer = nil;
    }
}
/// 暂停计时器滚动处理
- (void)kj_pauseTimer{
    if (self.timer) {
        [self kj_bannerPauseTimer:self.timer];
    }
}
/// 继续计时器滚动
- (void)kj_repauseTimer{
    if (self.timer) {
        [self kj_bannerResumeTimer:self.timer];
    }
}
#pragma mark - public
/// 使用Masonry自动布局，请在设置布局之后调用该方法
- (void)kj_useMasonry{
    [self layoutIfNeeded];
    if (self.bounds.size.height <= 0) return;
    self.height = self.bounds.size.height;
    self.collectionView.frame = self.bounds;
    self.layout.itemSize = CGSizeMake(_itemWidth, self.height);
    self.pageControl.frame = CGRectMake(0, self.height-kPageHeight, self.bounds.size.width, kPageHeight);
    [_topLayer setBounds:self.bounds];
    [_topLayer setPosition:CGPointMake(self.bounds.size.width*.5, self.bounds.size.height*.5)];
}
/// 滚动到指定位置
- (void)kj_makeScrollToIndex:(NSInteger)index{
    [self kj_scrollToIndex:index automaticScroll:NO];
}
/// 如果为异步操作获取到数据源之后，请刷新
- (void)kj_reloadBannerViewDatas{
    if ([_dataSource respondsToSelector:@selector(kj_setDatasBannerView:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.imageDatas = [self.dataSource kj_setDatasBannerView:self];
#pragma clang diagnostic pop
    }
}

#pragma mark - setter/getter
- (void)setDelegate:(id<KJBannerViewDelegate>)delegate{
    _delegate = delegate;
    if ([delegate respondsToSelector:@selector(kj_BannerView:CurrentIndex:)]) {
        if ([delegate kj_BannerView:self CurrentIndex:0]) {
            _pageControl.hidden = YES;
        }
    }
}
- (void)setDataSource:(id<KJBannerViewDataSource>)dataSource{
    _dataSource = dataSource;
    self.useDataSource = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.imageDatas = [dataSource kj_setDatasBannerView:self];
#pragma clang diagnostic pop
}
- (void)setItemClass:(Class)itemClass{
    _itemClass = itemClass;
    if (![NSStringFromClass(itemClass) isEqualToString:@"KJBannerViewCell"]) {
        self.useCustomCell = YES;
    }
    [self.collectionView registerClass:itemClass forCellWithReuseIdentifier:NSStringFromClass(itemClass)];
}
- (void)setItemWidth:(CGFloat)itemWidth{
    _itemWidth = itemWidth;
    self.layout.itemSize = CGSizeMake(itemWidth, self.height);
}
- (void)setItemSpace:(CGFloat)itemSpace{
    _itemSpace = itemSpace;
    self.layout.minimumLineSpacing = itemSpace;
}
- (void)setIsZoom:(BOOL)isZoom{
    _isZoom = isZoom;
    self.layout.isZoom = isZoom;
}
- (void)setRollType:(KJBannerViewRollDirectionType)rollType{
    _rollType = rollType;
    if (rollType == KJBannerViewRollDirectionTypeRightToLeft || rollType == KJBannerViewRollDirectionTypeLeftToRight) {
        self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }else{
        self.layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
}
- (void)setShowPageControl:(BOOL)showPageControl{
    _showPageControl = showPageControl;
    _pageControl.hidden = !showPageControl;
}
- (void)setAutoScroll:(BOOL)autoScroll{
    _autoScroll = autoScroll;
    if (_autoScroll) {
        [self setupTimer];
    }else{
        [self invalidateTimer];
    }
}
- (void)setImageDatas:(NSArray*)imageDatas{
    if (imageDatas == nil) return;
    _imageDatas = imageDatas;
    if (imageDatas.count == 0) {
        _nums = 0;
        self.topLayer.hidden = NO;
        self.pageControl.hidden = YES;
        self.collectionView.hidden = YES;
        [self invalidateTimer];
        return;
    }
    if (CGRectEqualToRect(self.pageControl.frame, CGRectZero)) {
        [self kj_useMasonry];
    }
    if (self.useCustomCell == NO && self.useDataSource == NO) {
        [self.temps removeAllObjects];
        for (int i=0; i<imageDatas.count; i++) {
            KJBannerDatas *info = [[KJBannerDatas alloc]init];
            info.bannerURLString = imageDatas[i];
            [self.temps addObject:info];
        }
    }
    [self kj_dealImageDatas:imageDatas];
}
#pragma mark - private
/// 处理数据的相关操作
- (void)kj_dealImageDatas:(NSArray*)imageDatas{
    self.pageControl.hidden = !_showPageControl;
    self.collectionView.hidden = NO;
    NSInteger count = imageDatas.count;
    if (count > 1) {
        _nums = self.infiniteLoop ? count * 51 : count;
        self.pageControl.totalPages = count;
        self.collectionView.scrollEnabled = YES;
        [self setAutoScroll:_autoScroll];
    }else{
        _nums = 10;
        self.pageControl.hidden = YES;
        self.collectionView.scrollEnabled = NO;
        [self invalidateTimer];
    }
    [self.collectionView reloadData];
    NSInteger index = self.infiniteLoop ? _nums * 0.5 : 0;
    [self kj_scrollToIndex:index automaticScroll:NO];
    self.topLayer.hidden = YES;
}
/// 自动滚动
- (void)automaticScroll{
    if(_imageDatas.count == 0) return;
    NSInteger index = [self currentIndex];
    switch (_rollType) {
        case KJBannerViewRollDirectionTypeRightToLeft:
        case KJBannerViewRollDirectionTypeBottomToTop:
            index++;
            break;
        case KJBannerViewRollDirectionTypeLeftToRight:
        case KJBannerViewRollDirectionTypeTopToBottom:
            if (index == 0) index = _nums;
            index--;
            break;
        default:
            break;
    }
    [self kj_scrollToIndex:index automaticScroll:YES];
}
/// 当前位置
- (NSInteger)currentIndex{
    if (self.collectionView.frame.size.width == 0 || self.collectionView.frame.size.height == 0) return 0;
    NSInteger index = 0;
    if (_layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        index = (self.collectionView.contentOffset.x + (_itemWidth + _itemSpace) * 0.5) / (_itemSpace + _itemWidth);
    }else{
        index = (self.collectionView.contentOffset.y + self.height * 0.5) / self.height;
    }
    return MAX(0, index);
}
/// 滚动到指定位置
- (void)kj_scrollToIndex:(NSInteger)index automaticScroll:(BOOL)automatic{
    if (_imageDatas == nil) {
        self.currentIndex = 0;
        return;
    }
    NSInteger idx = index % _imageDatas.count;
    self.currentIndex = idx;
    if (automatic) {
        self.pageControl.currentIndex = idx;
    }else if (self.pageControl.hidden == NO){
        [self.pageControl kj_notAutomaticScrollIndex:idx];
    }
    if ([self.delegate respondsToSelector:@selector(kj_BannerView:CurrentIndex:)]) {
        [self.delegate kj_BannerView:self CurrentIndex:idx];
    }
    if (self.kScrollBlock) {
        self.kScrollBlock(self,idx);
    }
    UICollectionViewScrollPosition position = UICollectionViewScrollPositionCenteredVertically;
    if (_layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        position = UICollectionViewScrollPositionCenteredHorizontally;
    }
    if (index >= _nums) {
        if (self.infiniteLoop) {
            index = _nums * 0.5;
            [UIView performWithoutAnimation:^{
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:position animated:NO];
            }];
        }
        return;
    }
    if (automatic) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:position animated:YES];
    }else{
        [UIView performWithoutAnimation:^{
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:position animated:NO];
        }];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView*)scrollView{
    self.collectionView.userInteractionEnabled = NO;
    if (_imageDatas.count == 0) return;
    if ([self.delegate respondsToSelector:@selector(kj_BannerViewDidScroll:)]) {
        [self.delegate kj_BannerViewDidScroll:self];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView{
    _lastX = scrollView.contentOffset.x;
    _lastY = scrollView.contentOffset.y;
    if (self.autoScroll) {
        [self invalidateTimer];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate{
    if (self.autoScroll) {
        __banner_weakself;
        [self kj_bannerAfterTask:^{
            [weakself setupTimer];
        } time:self.autoTime Asyne:YES];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView{
    [self scrollViewDidEndScrollingAnimation:self.collectionView];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView*)scrollView{
    self.collectionView.userInteractionEnabled = YES;
}
/// 手离开屏幕的时候
- (void)scrollViewWillEndDragging:(UIScrollView*)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    self.collectionView.userInteractionEnabled = NO;
    NSInteger idx = 0,dragIndex = 0;
    if (_layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        CGFloat move = scrollView.contentOffset.x - self.lastX;
        NSInteger page = move / (self.itemWidth*.5);
        if (velocity.x > 0 || page > 0) {
            dragIndex = 1;
        }else if (velocity.x < 0 || page < 0) {
            dragIndex = -1;
        }
        idx = (_lastX + (self.itemWidth + self.itemSpace) * 0.5) / (self.itemSpace + self.itemWidth);
    }else{
        CGFloat move = scrollView.contentOffset.y - self.lastY;
        NSInteger page = move / (self.height*.5);
        if (velocity.y > 0 || page > 0) {
            dragIndex = 1;
        }else if (velocity.y < 0 || page < 0) {
            dragIndex = -1;
        }
        idx = (_lastY + (self.height) * 0.5) / (self.height);
    }
    [self kj_scrollToIndex:idx + dragIndex automaticScroll:NO];
}
/// 松开手指滑动开始减速的时候设置滑动动画
- (void)scrollViewWillBeginDecelerating:(UIScrollView*)scrollView{
//    NSInteger idx = 0;
//    if (_layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
//        idx = (_lastX + (self.itemWidth + self.itemSpace) * 0.5) / (self.itemSpace + self.itemWidth);
//    }else{
//        idx = (_lastY + (self.height) * 0.5) / (self.height);
//    }
//    [self kj_scrollToIndex:idx automaticScroll:NO];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section{
    return _imageDatas.count?self.nums:0;
}
- (__kindof UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath{
    NSInteger count = _imageDatas.count;
    if (count == 0) {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"KJBannerViewCell" forIndexPath:indexPath];
    }
    NSInteger itemIndex = indexPath.item % count;
    if (self.useDataSource) {
        KJBannerViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"KJBannerViewCell" forIndexPath:indexPath];
        cell.itemView = [_dataSource kj_BannerView:self ItemSize:cell.bounds.size Index:itemIndex];
//        cell.itemView = [_dataSource kj_BannerView:self BannerViewCell:cell ImageDatas:_imageDatas Index:itemIndex];
        return cell;
    }
    if (self.useCustomCell) {
        KJBannerViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(_itemClass) forIndexPath:indexPath];
        cell.model = _imageDatas[itemIndex];
        return cell;
    }
    /// 自带Cell处理
    KJBannerViewCell *bannerViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"KJBannerViewCell" forIndexPath:indexPath];
    bannerViewCell.backgroundColor = self.backgroundColor;
    bannerViewCell.bannerNoPureBack = self.bannerNoPureBack;
    bannerViewCell.bannerCornerRadius = self.bannerCornerRadius;
    bannerViewCell.bannerScale = self.bannerScale;
    bannerViewCell.bannerRadius = self.bannerRadius;
    bannerViewCell.bannerContentMode = self.bannerContentMode;
    bannerViewCell.bannerPlaceholder = self.placeholderImage;
    bannerViewCell.bannerDatas = self.temps[itemIndex];
    return bannerViewCell;
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath{
    NSInteger idx = [self currentIndex] % _imageDatas.count;
    if ([self.delegate respondsToSelector:@selector(kj_BannerView:SelectIndex:)]) {
        [self.delegate kj_BannerView:self SelectIndex:idx];
    }
    if (self.kSelectBlock) {
        self.kSelectBlock(self,idx);
    }
}
#pragma mark - lazy
- (NSMutableArray<KJBannerDatas*>*)temps{
    if (!_temps){
        _temps = [NSMutableArray array];
    }
    return _temps;
}
- (CALayer*)topLayer{
    if (!_topLayer){
        _topLayer = [[CALayer alloc]init];
        [_topLayer setBounds:self.bounds];
        [_topLayer setPosition:CGPointMake(self.bounds.size.width*.5, self.bounds.size.height*.5)];
        [_topLayer setContents:(id)self.placeholderImage.CGImage];
//        _topLayer.zPosition = 1;
    }
    return _topLayer;
}
- (KJBannerViewFlowLayout*)layout{
    if(!_layout){
        _layout = [[KJBannerViewFlowLayout alloc]init];
        _layout.minimumLineSpacing = 0;
        _layout.itemSize = CGSizeMake(_itemWidth, self.frame.size.height);
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _layout;
}
- (UICollectionView*)collectionView{
    if(!_collectionView){
        _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:self.layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollsToTop = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = self.backgroundColor;
        [_collectionView registerClass:_itemClass forCellWithReuseIdentifier:@"KJBannerViewCell"];
    }
    return _collectionView;
}
- (KJPageView*)pageControl{
    if(!_pageControl){
        _pageControl = [[KJPageView alloc]init];
        _pageControl.hidden = YES;
    }
    return _pageControl;
}

@end
@implementation KJBannerView (KJBannerViewCell)
- (BOOL)bannerScale{
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number == nil) {
        return YES;
    }else{
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
    }else{
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
- (BOOL)bannerNoPureBack{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setBannerNoPureBack:(BOOL)bannerNoPureBack{
    objc_setAssociatedObject(self, @selector(bannerNoPureBack), @(bannerNoPureBack), OBJC_ASSOCIATION_ASSIGN);
}
- (void)setBannerCornerRadius:(UIRectCorner)bannerCornerRadius{
    objc_setAssociatedObject(self, @selector(bannerCornerRadius), @(bannerCornerRadius), OBJC_ASSOCIATION_ASSIGN);
}
- (void)setBannerScale:(BOOL)bannerScale{
    objc_setAssociatedObject(self, @selector(bannerScale), @(bannerScale), OBJC_ASSOCIATION_ASSIGN);
}
- (void)setBannerRadius:(CGFloat)bannerRadius{
    objc_setAssociatedObject(self, @selector(bannerRadius), @(bannerRadius), OBJC_ASSOCIATION_ASSIGN);
}
- (void)setPlaceholderImage:(UIImage *)placeholderImage{
    objc_setAssociatedObject(self, @selector(bannerPlaceholder), placeholderImage, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void)setBannerContentMode:(UIViewContentMode)bannerContentMode{
    objc_setAssociatedObject(self, @selector(bannerContentMode), @(bannerContentMode), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
@implementation KJBannerView (KJBannerBlock)
- (void (^)(KJBannerView*,NSInteger))kSelectBlock{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setKSelectBlock:(void (^)(KJBannerView*,NSInteger))kSelectBlock{
    objc_setAssociatedObject(self, @selector(kSelectBlock), kSelectBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^)(KJBannerView*,NSInteger))kScrollBlock{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setKScrollBlock:(void (^)(KJBannerView*,NSInteger))kScrollBlock{
    objc_setAssociatedObject(self, @selector(kScrollBlock), kScrollBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
