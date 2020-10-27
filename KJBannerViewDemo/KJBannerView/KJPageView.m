//
//  KJPageView.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2019/5/27.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "KJPageView.h"

/// 大小点控件
@interface KJDotPageView : UIView
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, assign) NSInteger pages;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) UIColor *normalColor,*selectColor;
@property (nonatomic, assign) CGFloat margin,normalheight;
@property (nonatomic, assign) CGFloat normalWidth,selectWidth;
/// 初始化方法
- (instancetype)initWithFrame:(CGRect)frame Margin:(CGFloat)margin NormalWidth:(CGFloat)normalw SelectWidth:(CGFloat)selectw Height:(CGFloat)height;
@end

@implementation KJDotPageView
- (instancetype)initWithFrame:(CGRect)frame Margin:(CGFloat)margin NormalWidth:(CGFloat)normalw SelectWidth:(CGFloat)selectw Height:(CGFloat)height{
    if (self = [super initWithFrame:frame]) {
        self.backView = [[UIView alloc] initWithFrame:frame];
        [self addSubview:_backView];
        _pages = _currentPage = 0;
        self.normalWidth = normalw;
        self.margin = margin;
        self.selectWidth = selectw;
        self.normalheight = height;
    }
    return self;
}
- (void)setCurrentPage:(NSInteger)currentPage{
    if (_currentPage == currentPage) return;
    _currentPage = MIN(currentPage, _pages - 1);
    CGFloat x = 0;
    for (NSInteger i = 0; i < _pages; i++) {
        UIView * view = [self.backView viewWithTag:520+i];
        if (i == _currentPage) {
            view.frame = CGRectMake(x, 0, _selectWidth, _normalheight);
            x += _selectWidth + _margin;
            view.backgroundColor = _selectColor;
        }else {
            view.frame = CGRectMake(x, 0, _normalWidth, _normalheight);
            x += _normalWidth + _margin;
            view.backgroundColor = _normalColor;
        }
    }
}
- (void)setPages:(NSInteger)pages{
    if (pages <= 0 || _pages == pages) return;
    _pages = pages;
    [self.backView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview) withObject:self];
    CGFloat width = _selectWidth + (pages-1)*_normalWidth + (pages-1)*_margin;
    self.backView.frame = CGRectMake(0, 0, width, _normalheight);
    self.backView.center = CGPointMake(self.frame.size.width*.5, _normalheight-2);
    CGFloat x = 0;
    for (NSInteger i = 0; i < pages; i++) {
        UIView *view = [UIView new];
        view.tag = 520 + i;
        view.layer.cornerRadius = _normalheight*.5;
        if (i == _currentPage) {
            view.frame = CGRectMake(x, 0, _selectWidth, _normalheight);
            view.backgroundColor = _selectColor;
            x += _selectWidth + _margin;
        }else{
            view.frame = CGRectMake(x, 0, _normalWidth, _normalheight);
            view.backgroundColor = _normalColor;
            x += _normalWidth + _margin;
        }
        [self.backView addSubview:view];
    }
}

@end
@interface KJPageView ()
@property(nonatomic,strong)UIView *backView;
@end
@implementation KJPageView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self==[super initWithFrame:frame]) {
        _pageType = PageControlStyleRectangle;
        _normalColor = UIColor.lightGrayColor;
        _selectColor = UIColor.whiteColor;
        _currentIndex = 0;
        self.backView = [[UIView alloc] initWithFrame:frame];
        [self addSubview:_backView];
    }
    return self;
}
/// 设置PageView
- (void)setTotalPages:(NSInteger)pages{
    _totalPages = pages;
    if (_pageType == PageControlStyleSizeDot) {
        self.loopPageView.pages = pages;
        return;
    }
    [self.backView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview) withObject:self];
    CGFloat margin = self.margin?:8;
    CGFloat dotwidth,dotheight = 0.0;
    if (self.dotwidth && self.dotheight) {
        dotwidth  = self.dotwidth;
        dotheight = self.dotheight;
    }else{
        dotwidth = (self.frame.size.width - (pages-1)*margin) / pages;
        dotwidth = dotwidth > self.frame.size.height/2. ? self.frame.size.height/2. : dotwidth;
        if (_pageType == PageControlStyleCircle || _pageType == PageControlStyleSquare ) {
            dotheight = dotwidth;
        }else if (_pageType == PageControlStyleRectangle) {
            dotheight = dotwidth/4.;
            dotwidth *= 1.5;
        }
    }
    self.backView.frame  = CGRectMake(0, 0, (pages)*(dotwidth+margin), self.frame.size.height);
    self.backView.center = CGPointMake(self.frame.size.width*.5, self.backView.center.y);
    CGFloat x = 0;
    for (NSInteger i = 0; i < pages; i++) {
        UIView *view = [UIView new];
        [self.backView addSubview:view];
        view.tag = 520 + i;
        view.backgroundColor = i == _currentIndex ? _selectColor : _normalColor;
        switch (_pageType) {
            case PageControlStyleCircle:
                view.frame = CGRectMake(x, 0, dotwidth, dotheight);
                view.layer.cornerRadius = dotwidth / 2;
                break;
            case PageControlStyleSquare:
                view.frame = CGRectMake(x, 0, dotwidth, dotheight);
                break;
            case PageControlStyleRectangle:
                view.frame = CGRectMake(x, 0, dotwidth, dotheight);
                break;
            default:
                break;
        }
        x += dotwidth + margin;
    }
}
/// 当前的currentPage
- (void)setCurrentIndex:(NSInteger)currentIndex{
    if (_pageType == PageControlStyleSizeDot) {
        self.loopPageView.currentPage = currentIndex;
        return;
    }
    if (_currentIndex != currentIndex) {
        _currentIndex = MIN(currentIndex, _totalPages - 1);
        [self.backView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.backgroundColor = idx == currentIndex ? self.selectColor : self.normalColor;
        }];
    }
}

#pragma mark - lazy
- (KJDotPageView*)loopPageView{
    if (!_loopPageView) {
        CGFloat w = self.dotwidth?:5;
        _loopPageView = [[KJDotPageView alloc] initWithFrame:self.bounds Margin:self.margin?:5. NormalWidth:w SelectWidth:w*2 Height:self.dotheight?:5];
        _loopPageView.normalColor = _normalColor;
        _loopPageView.selectColor = _selectColor;
        [self addSubview:_loopPageView];
    }
    return _loopPageView;
}

@end
