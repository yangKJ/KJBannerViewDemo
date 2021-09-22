//
//  DownloadViewController.m
//  KJBannerViewDemo
//
//  Created by 杨科军 on 2020/1/15.
//  Copyright © 2020 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJBannerViewDemo

#import "DownloadViewController.h"
#import "KJBannerHeader.h"
#import "KJBannerViewLoadManager.h"

@interface DownloadViewController ()
@property (nonatomic,strong) UILabel *label1,*label2,*label3,*label4;
@property (nonatomic,strong) UIButton *imageView;
@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self test];
    
    self.view.backgroundColor = UIColor.whiteColor;
    CGFloat w = self.view.frame.size.width;
//    CGFloat h = self.view.frame.size.height;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 64 + 60, w-40, 20)];
    self.label1 = label;
    label.textColor = UIColor.blueColor;
    label.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:label];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(label.frame) + 20, w-40, 20)];
    self.label2 = label2;
    label2.textColor = UIColor.blueColor;
    label2.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(label2.frame) + 20, w-40, 20)];
    self.label3 = label3;
    label3.textColor = UIColor.blueColor;
    label3.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:label3];
    
    UILabel *label4 = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(label3.frame) + 20, w-40, 20)];
    self.label4 = label4;
    label4.textColor = UIColor.blueColor;
    label4.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:label4];
        
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame = CGRectMake(0, 0, 150, 40);
    button.center = self.view.center;
    button.backgroundColor = UIColor.yellowColor;
    [button setTitle:@"重新获取" forState:(UIControlStateNormal)];
    [button setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIButton *imageView = [[UIButton alloc]initWithFrame:CGRectZero];
    imageView.frame = CGRectMake(20, self.view.frame.size.height-180-40, w-40, 180);
    imageView.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.3];
    [self.view addSubview:imageView];
    self.imageView = imageView;
    NSURL * URL = [NSURL URLWithString:@"http://photos.tuchong.com/285606/f/4374153.jpg"];
    [imageView kj_setImageWithURL:URL handle:^(id<KJBannerWebImageHandle>  _Nonnull handle) {
            
    }];
    
    [self buttonAction];
}
- (void)buttonAction{
    kGCD_banner_async(^{
        NSString * url = @"https://mp4.vjshi.com/2018-03-30/1f36dd9819eeef0bc508414494d34ad9.mp4";
        [KJBannerViewLoadManager kj_downloadDataWithURL:url progress:^(KJBannerDownloadProgress * __progress) {
            kGCD_banner_main(^{
                self.label1.text = [NSString stringWithFormat:@"已下载：%.2fkb",__progress.downloadBytes/1024.];
                self.label2.text = [NSString stringWithFormat:@"总大小：%.2fkb",__progress.totalBytes/1024.];
                self.label3.text = [NSString stringWithFormat:@"下载速度：%.2fkb/s",__progress.speed];
                self.label4.text = [NSString stringWithFormat:@"下载进度：%.5f",__progress.progress];
            });
        }];
    });
}

- (void)test{
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).lastObject;
    NSString *path = [document stringByAppendingPathComponent:@"KJLoadImages"];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    NSMutableArray *temps = [NSMutableArray array];
    NSString *imageName;
    while((imageName = [enumerator nextObject]) != nil) {
        [temps addObject:imageName];
    }
    NSLog(@"\n视频文件,%@",temps);
}

@end
