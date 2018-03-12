//
//  MYDViewController.m
//  JKHealth724
//
//  Created by 裴启瑞 on 2018/3/8.
//  Copyright © 2018年 裴启瑞. All rights reserved.
//

#import "MYDViewController.h"

@interface MYDViewController ()

@end

@implementation MYDViewController
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = _navititle;
    NSLog(@"title == %@,\n   goodsid = %@", _navititle, _goodsId);
    
    UIButton* mybutton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [mybutton2 setTitle:_goodsId forState:UIControlStateNormal];
    [mybutton2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    mybutton2.titleLabel.font = [UIFont systemFontOfSize:15];
    [mybutton2 setFrame:(CGRect){60, 240, 310, 40}];
    [mybutton2 setBackgroundColor:[UIColor greenColor]];
    
    [self.view addSubview:mybutton2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
