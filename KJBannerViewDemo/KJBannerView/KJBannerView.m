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

@interface KJBannerView()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) KJBannerViewFlowLayout *layout;
@property (nonatomic,strong) KJPageView *pageControl;
@property (nonatomic,strong) CALayer *topLayer;
@property (nonatomic,strong) NSMutableArray *temps;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign) NSUInteger nums;
@property (nonatomic,assign) NSInteger dragIndex;
@property (nonatomic,assign) CGFloat lastX;
@property (nonatomic,assign) BOOL useCustomCell;
@property (nonatomic,assign) BOOL useDataSource;
@end

@implementation KJBannerView
/// 设置默认参数
- (void)kConfig{
    _infiniteLoop = YES;
    _autoScroll = YES;
    _isZoom = NO;
    _itemWidth = self.bounds.size.width;
    _itemSpace = 0;
    _bannerRadius = 0;
    _autoTime = 2;
    _bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
    _rollType = KJBannerViewRollDirectionTypeRightToLeft;
    _imageType = KJBannerViewImageTypeNetIamge;
    _placeholderImage = [UIImage imageNamed:@"KJBannerView.bundle/KJBannerPlaceholderImage"];
    _useCustomCell = NO;
    _bannerScale = NO;
    _useDataSource = NO;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.itemClass = [KJBannerViewCell class];
#pragma clang diagnostic pop
}
- (instancetype)initWithCoder:(NSCoder*)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self kConfig];
        [self addSubview:self.collectionView];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self kConfig];
        [self addSubview:self.collectionView];
    }
    return self;
}
- (void)willMoveToSuperview:(UIView*)newSuperview{
    [super willMoveToSuperview:newSuperview];
    [self invalidateTimer];
}
#pragma mark - public
/// 暂停计时器滚动处理
- (void)kj_pauseTimer{
    if (_timer) {
        [_timer setFireDate:[NSDate distantFuture]];
    }
}
/// 继续计时器滚动
- (void)kj_repauseTimer{
    if (_timer) {
        [_timer setFireDate:[NSDate date]];
    }
}
#pragma mark - setter/getter
- (void)setDelegate:(id<KJBannerViewDelegate>)delegate{
    _delegate = delegate;
    if ([delegate respondsToSelector:@selector(kj_BannerView:CurrentIndex:)]) {
        BOOL boo = [delegate kj_BannerView:self CurrentIndex:0];
        if (boo && self.pageControl.superview) {
            [self.pageControl removeFromSuperview];
        }
    }
}
- (void)setDataSource:(id<KJBannerViewDataSource>)dataSource{
    _dataSource = dataSource;
    self.useDataSource = YES;
}
- (void)setItemClass:(Class)itemClass{
    _itemClass = itemClass;
    if (![NSStringFromClass(itemClass) isEqualToString:@"KJBannerViewCell"]) {
        self.useCustomCell = YES;
    }
    [self.collectionView registerClass:itemClass forCellWithReuseIdentifier:@"KJBannerViewCell"];
}
- (void)setItemWidth:(CGFloat)itemWidth{
    _itemWidth = itemWidth;
    self.layout.itemSize = CGSizeMake(itemWidth, self.bounds.size.height);
}
- (void)setItemSpace:(CGFloat)itemSpace{
    _itemSpace = itemSpace;
    self.layout.minimumLineSpacing = itemSpace;
}
- (void)setIsZoom:(BOOL)isZoom{
    _isZoom = isZoom;
    self.layout.isZoom = isZoom;
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
    if (imageDatas.count == 0) {
        [self.layer addSublayer:self.topLayer];
        self.pageControl.hidden = YES;
        [self.collectionView removeFromSuperview];
        [self invalidateTimer];
        return;
    }else{
        if (self.collectionView.superview == nil) {
            [self.topLayer removeFromSuperlayer];
            [self addSubview:self.collectionView];
        }
    }
    _imageDatas = imageDatas;
    if (self.useCustomCell == NO && self.useDataSource == NO) {
        [self.temps removeAllObjects];
        for (int i=0; i<imageDatas.count; i++) {
            KJBannerDatasInfo *info = [[KJBannerDatasInfo alloc]init];
            info.superType = self.imageType;
            info.imageUrl = imageDatas[i];
            [self.temps addObject:info];
        }
    }
    [self kj_dealImageDatas:imageDatas];
}
#pragma mark - private
/// 处理数据的相关操作
- (void)kj_dealImageDatas:(NSArray*)imageDatas{
    if (imageDatas.count > 1) {
        _nums = self.infiniteLoop ? imageDatas.count * 1000 : imageDatas.count;
        self.pageControl.hidden = NO;
        self.collectionView.scrollEnabled = YES;
        [self setAutoScroll:self.autoScroll];
        self.pageControl.totalPages = imageDatas.count;
    }else{
        _nums = 10;
        self.pageControl.hidden = YES;
        self.collectionView.scrollEnabled = NO;
        [self invalidateTimer];
    }
    [self.collectionView reloadData];
    [self kSetCollectionItemIndexPlace];
}
/// 设置初始滚动位置
- (void)kSetCollectionItemIndexPlace{
    self.collectionView.frame = self.bounds;
    self.layout.itemSize = CGSizeMake(self.itemWidth, self.bounds.size.height);
    self.layout.minimumLineSpacing = self.itemSpace;
    if(self.collectionView.contentOffset.x == 0 && _nums > 0) {
        NSInteger targeIndex = self.infiniteLoop ? _nums * 0.5 : 0;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:targeIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        self.lastX = self.collectionView.contentOffset.x;
        self.collectionView.userInteractionEnabled = YES;
    }
}
/// 开启计时器
- (void)setupTimer{
    [self invalidateTimer];
    __weak typeof(self) weakself = self;
    __block NSUInteger index = 0;
    self.timer = [NSTimer kj_bannerScheduledTimerWithTimeInterval:self.autoTime Repeats:YES Block:^(NSTimer *timer) {
        if (index++>1) [weakself automaticScroll];
    }];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer fire];
}
/// 释放计时器
- (void)invalidateTimer{
    [_timer invalidate];
    _timer = nil;
}
/// 自动滚动
- (void)automaticScroll{
    if(_nums == 0) return;
    NSInteger currentIndex = [self currentIndex];
    NSInteger targetIndex;
    if (_rollType == KJBannerViewRollDirectionTypeRightToLeft) {
        targetIndex = currentIndex + 1;
    }else{
        if (currentIndex == 0) currentIndex = _nums;
        targetIndex = currentIndex - 1;
    }
    [self scrollToIndex:targetIndex];
}
/// 当前位置
- (NSInteger)currentIndex{
    if(self.collectionView.frame.size.width == 0 || self.collectionView.frame.size.height == 0) return 0;
    NSInteger index = 0;
    if (_layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        index = (self.collectionView.contentOffset.x + (self.itemWidth + self.itemSpace) * 0.5) / (self.itemSpace + self.itemWidth);
    }else{
        index = (self.collectionView.contentOffset.y + _layout.itemSize.height * 0.5) / _layout.itemSize.height;
    }
    return MAX(0,index);
}
/// 滚动到指定位置
- (void)scrollToIndex:(NSInteger)index{
    NSInteger idx = index % _imageDatas.count;
    if ([self.delegate respondsToSelector:@selector(kj_BannerView:CurrentIndex:)]) {
        [self.delegate kj_BannerView:self CurrentIndex:idx];
    }
    if (self.kScrollBlock) self.kScrollBlock(self,idx);
    if (index >= _nums) {
        if (self.infiniteLoop) {
            index = _nums * 0.5;
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        }
        return;
    }
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView*)scrollView{
    self.collectionView.userInteractionEnabled = NO;
    if (!self.imageDatas.count) return;
    self.pageControl.currentIndex = [self currentIndex] % self.imageDatas.count;
    if ([self.delegate respondsToSelector:@selector(kj_BannerViewDidScroll:)]) {
        [self.delegate kj_BannerViewDidScroll:self];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView*)scrollView{
    _lastX = scrollView.contentOffset.x;
    if (self.autoScroll) {
        [self invalidateTimer];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate{
    if (self.autoScroll) {
        [self setupTimer];
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
    CGFloat currentX = scrollView.contentOffset.x;
    CGFloat moveWidth = currentX - self.lastX;
    NSInteger shouldPage = moveWidth / (self.itemWidth*.5);
    if (velocity.x > 0 || shouldPage > 0) {
        _dragIndex = 1;
    }else if (velocity.x < 0 || shouldPage < 0) {
        _dragIndex = -1;
    }else{
        _dragIndex = 0;
    }
    self.collectionView.userInteractionEnabled = NO;
    NSInteger idx = (_lastX + (self.itemWidth + self.itemSpace) * 0.5) / (self.itemSpace + self.itemWidth);
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:idx + _dragIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}
/// 松开手指滑动开始减速的时候设置滑动动画
- (void)scrollViewWillBeginDecelerating:(UIScrollView*)scrollView{
    NSInteger idx = (_lastX + (self.itemWidth + self.itemSpace) * 0.5) / (self.itemSpace + self.itemWidth);
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:idx + _dragIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.nums;
}
- (__kindof UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath{
    KJBannerViewCell *bannerViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"KJBannerViewCell" forIndexPath:indexPath];
    NSInteger itemIndex = indexPath.item % self.imageDatas.count;
    if (self.useDataSource) {
        bannerViewCell.itemView = [_dataSource kj_BannerView:self BannerViewCell:bannerViewCell ImageDatas:self.imageDatas Index:itemIndex];
    }else if (self.useCustomCell) {
        bannerViewCell.model = self.imageDatas[itemIndex];
    }else{ /// 自带Cell处理
        bannerViewCell.kj_scale = self.bannerScale;
        bannerViewCell.imgCornerRadius  = self.bannerRadius;
        bannerViewCell.placeholderImage = self.placeholderImage;
        bannerViewCell.contentMode = self.bannerImageViewContentMode;
        bannerViewCell.info = self.temps[itemIndex];
    }
    return bannerViewCell;
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath{
    NSInteger idx = [self currentIndex] % self.imageDatas.count;
    if ([self.delegate respondsToSelector:@selector(kj_BannerView:SelectIndex:)]) {
        [self.delegate kj_BannerView:self SelectIndex:idx];
    }
    if (self.kSelectBlock) {
        self.kSelectBlock(self,idx);
    }
}
#pragma mark - lazy
- (NSMutableArray*)temps{
    if (!_temps){
        _temps = [NSMutableArray array];
    }
    return _temps;
}
- (CALayer*)topLayer{
    if (!_topLayer){
        CALayer *topLayer = [[CALayer alloc]init];
        [topLayer setBounds:self.bounds];
        [topLayer setPosition:CGPointMake(self.bounds.size.width*.5, self.bounds.size.height*.5)];
        [topLayer setContents:(id)self.placeholderImage.CGImage];
        _topLayer = topLayer;
    }
    return _topLayer;
}
- (KJBannerViewFlowLayout*)layout{
    if(!_layout){
        _layout = [[KJBannerViewFlowLayout alloc]init];
        _layout.isZoom = self.isZoom;
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.minimumLineSpacing = 0;
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
    }
    return _collectionView;
}
- (KJPageView*)pageControl{
    if(!_pageControl){
        [self layoutIfNeeded];
        _pageControl = [[KJPageView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height - 15, self.bounds.size.width, 15)];
        [self addSubview:_pageControl];
    }
    return _pageControl;
}

@end


