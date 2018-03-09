//
//  MYDWebViewController.m
//  JKHealth724
//
//  Created by 裴启瑞 on 2018/3/8.
//  Copyright © 2018年 裴启瑞. All rights reserved.
//

#import "MYDWebViewController.h"
#import <WebKit/WebKit.h>
@interface MYDWebViewController ()<WKNavigationDelegate>
@property (strong, nonatomic) WKWebView* webView;
@end

@implementation MYDWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:_linkUrl]];
    [self.webView loadRequest:request];
}

- (WKWebView *)webView{
    if (!_webView) {
        WKWebViewConfiguration* webConfig = [[WKWebViewConfiguration alloc]init];
        _webView = [[WKWebView alloc]initWithFrame:(CGRect){0, 0, 414, 700} configuration:webConfig];
        _webView.allowsBackForwardNavigationGestures = YES;
    }
    return _webView;
}
@end
