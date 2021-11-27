//
//  DownloadViewController.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/1/15.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "DownloadViewController.h"
#import "KJWebImageDownloader.h"
#import "KJBannerHeader.h"
#import "Masonry.h"

@interface DownloadViewController ()
@property (nonatomic,strong) UILabel *downloadLabel;
@property (nonatomic,strong) UILabel *totalLabel;
@property (nonatomic,strong) UILabel *speedLabel;
@property (nonatomic,strong) UILabel *progressLabel;
@property (nonatomic,strong) UIButton *againButton;
@property (nonatomic,strong) UIButton *webButton;

@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
    [self buttonAction];
}

- (void)setupUI{
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.downloadLabel];
    [self.view addSubview:self.totalLabel];
    [self.view addSubview:self.speedLabel];
    [self.view addSubview:self.progressLabel];
    [self.view addSubview:self.againButton];
    [self.view addSubview:self.webButton];
    [self.downloadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(60);
        make.left.equalTo(self.view).offset(20);
    }];
    [self.totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.downloadLabel.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(20);
    }];
    [self.speedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.totalLabel.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(20);
    }];
    [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.speedLabel.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(20);
    }];
    [self.againButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@150);
        make.height.equalTo(@40);
        make.center.equalTo(self.view);
    }];
    [self.webButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(20);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).inset(40);
        make.height.equalTo(@180);
    }];
}

#pragma mark - action

- (void)buttonAction{
    kGCD_banner_async(^{
        __banner_weakself;
        NSString * url = @"https://mp4.vjshi.com/2018-03-30/1f36dd9819eeef0bc508414494d34ad9.mp4";
        [KJWebImageDownloader kj_downloadDataWithURL:url progress:^(KJBannerDownloadProgress * pro) {
            [weakself displayProgress:pro];
        }];
    });
}

- (void)displayProgress:(KJBannerDownloadProgress *)pro{
    kGCD_banner_main(^{
        self.downloadLabel.text = [NSString stringWithFormat:@"已下载：%.2fkb",pro.downloadBytes/1024.];
        self.totalLabel.text = [NSString stringWithFormat:@"总大小：%.2fkb",pro.totalBytes/1024.];
        self.speedLabel.text = [NSString stringWithFormat:@"下载速度：%.2fkb/s",pro.speed];
        self.progressLabel.text = [NSString stringWithFormat:@"下载进度：%.5f",pro.progress];
    });
}

#pragma mark - lazy

- (UILabel *)downloadLabel{
    if (!_downloadLabel) {
        _downloadLabel = [[UILabel alloc] init];
        _downloadLabel.textColor = UIColor.blueColor;
        _downloadLabel.font = [UIFont systemFontOfSize:14];
    }
    return _downloadLabel;
}
- (UILabel *)totalLabel{
    if (!_totalLabel) {
        _totalLabel = [[UILabel alloc] init];
        _totalLabel.textColor = UIColor.blueColor;
        _totalLabel.font = [UIFont systemFontOfSize:14];
    }
    return _totalLabel;
}
- (UILabel *)speedLabel{
    if (!_speedLabel) {
        _speedLabel = [[UILabel alloc] init];
        _speedLabel.textColor = UIColor.blueColor;
        _speedLabel.font = [UIFont systemFontOfSize:14];
    }
    return _speedLabel;
}
- (UILabel *)progressLabel{
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.textColor = UIColor.blueColor;
        _progressLabel.font = [UIFont systemFontOfSize:14];
    }
    return _progressLabel;
}
- (UIButton *)againButton{
    if (!_againButton) {
        _againButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        _againButton.backgroundColor = UIColor.yellowColor;
        [_againButton setTitle:@"重新获取" forState:(UIControlStateNormal)];
        [_againButton setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
        [_againButton addTarget:self action:@selector(buttonAction)
               forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _againButton;
}
- (UIButton *)webButton{
    if (!_webButton) {
        _webButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        _webButton.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.3];
        NSURL * URL = [NSURL URLWithString:@"http://photos.tuchong.com/285606/f/4374153.jpg"];
        [_webButton kj_setImageWithURL:URL provider:nil];
    }
    return _webButton;
}

@end
