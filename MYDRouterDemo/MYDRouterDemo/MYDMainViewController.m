//
//  MYDMainViewController.m
//  JKHealth724
//
//  Created by 裴启瑞 on 2018/3/8.
//  Copyright © 2018年 裴启瑞. All rights reserved.
//

#import "MYDMainViewController.h"
#import "MYDRouterManager.h"
@interface MYDMainViewController ()

@end

@implementation MYDMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIButton* mybutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mybutton setTitle:@"已实现模块 别名跳转:product" forState:UIControlStateNormal];
    [mybutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    mybutton.titleLabel.font = [UIFont systemFontOfSize:17];
    [mybutton setFrame:(CGRect){50, 100, 340, 40}];
    [mybutton setBackgroundColor:[UIColor greenColor]];
    [mybutton addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mybutton];
    
    
    UIButton* mybutton11 = [UIButton buttonWithType:UIButtonTypeCustom];
    [mybutton11 setTitle:@"未实现模块 别名跳转" forState:UIControlStateNormal];
    [mybutton11 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    mybutton11.titleLabel.font = [UIFont systemFontOfSize:17];
    [mybutton11 setFrame:(CGRect){50, 170, 340, 40}];
    [mybutton11 setBackgroundColor:[UIColor greenColor]];
    [mybutton11 addTarget:self action:@selector(submitur11) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mybutton11];
    
    UIButton* mybutton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [mybutton1 setTitle:@"已实现模块  url跳转:myd://product/product-details/goods090511" forState:UIControlStateNormal];
    [mybutton1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    mybutton1.titleLabel.font = [UIFont systemFontOfSize:17];
    [mybutton1 setFrame:(CGRect){50, 240, 340, 40}];
    [mybutton1 setBackgroundColor:[UIColor greenColor]];
    [mybutton1 addTarget:self action:@selector(submiturl) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mybutton1];
    
    
    
    UIButton* mybutton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [mybutton2 setTitle:@"未实现模块 url跳转1:myd://usercenter" forState:UIControlStateNormal];
    [mybutton2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    mybutton2.titleLabel.font = [UIFont systemFontOfSize:17];
    [mybutton2 setFrame:(CGRect){50, 310, 340, 40}];
    [mybutton2 setBackgroundColor:[UIColor greenColor]];
    [mybutton2 addTarget:self action:@selector(submitur2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mybutton2];
    
    UIButton* mybutton3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [mybutton3 setTitle:@"错误url跳转2:myd://usercenter" forState:UIControlStateNormal];
    [mybutton3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    mybutton3.titleLabel.font = [UIFont systemFontOfSize:17];
    [mybutton3 setFrame:(CGRect){50, 380, 340, 40}];
    [mybutton3 setBackgroundColor:[UIColor greenColor]];
    [mybutton3 addTarget:self action:@selector(submitur3) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mybutton3];

}
- (void)submit{
    [[MYDRouterManager sharedInstance]openPageWithKey:@"product" params:@{@"navititle":@"我的标题",@"goodsId":@"7878hj-9898ui-90-1s"}];
}
- (void)submitur11{
    [[MYDRouterManager sharedInstance]openPageWithKey:@"usercenter" params:@{@"navititle":@"个人中心"}];
}
- (void)submiturl{
    [[MYDRouterManager sharedInstance]openPageWithUrlString:@"myd://product/product-details/goods090511"];
}
- (void)submitur2{
    [[MYDRouterManager sharedInstance]openPageWithUrlString:@"myd://usercenter"];
}
- (void)submitur3{
    [[MYDRouterManager sharedInstance]openPageWithUrlString:@"https://www.baidu.com"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
