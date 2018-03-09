//
//  MYDRouterManager.m
//  JKHealth724
//
//  Created by 裴启瑞 on 2018/3/8.
//  Copyright © 2018年 裴启瑞. All rights reserved.
//

#import "MYDRouterManager.h"
#import <UIKit/UIKit.h>
#import "MYDRouter.h"
@interface MYDRouterManager()


@end

@implementation MYDRouterManager

+ (MYDRouterManager*)sharedInstance{
    static MYDRouterManager* routerManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!routerManager) {
            routerManager = [[MYDRouterManager alloc]init];
        }
    });
    return routerManager;
}


- (void)openPageWithUrlString:(NSString *)urlString{
    
    id result = [MYDRouter openModuleWithUrl:urlString];
    
    if ([result isKindOfClass:[NSDictionary class]]) {
        [self openViewControllerWithParam:(NSDictionary*)result];
    }else if ([result isKindOfClass:[NSString class]]){
        [self openWebPage:result];
    }else{
        NSLog(@"这个链接有问题的...");
    }
    
}


- (void)openPageWithKey:(NSString *)key params:(NSDictionary *)param{
    
    MYDOpenRouterResult result = [MYDRouter openModuleWithModuleKey:key moduleParam:param];
    
    if (result == MYDOpenRouterResultNotRegisted) {
        if ([self registPageWithModuleKey:key]){
            [self openPageWithKey:key params:param];
        }else{
            NSLog(@"注册失败，没有这个模块...请检查");
        }
    }else if (result == MYDOpenRouterResultFailed){
        [MYDRouter sharedInstance].defaultHandler = ^(NSDictionary *routerParameters) {
            
            NSLog(@"没有这个模块...请检查");
        };
    }else if (result == MYDOpenRouterResultSuccess){
        NSLog(@"成功找到这个模块，你马上就打开这个模块了");
    }
}

- (BOOL)registPageWithModuleKey:(NSString*)moudleKey{
    
    __weak typeof(self)weakSelf = self;
    return [MYDRouter registModuleWithmoduleKey:moudleKey toHandler:^(NSDictionary *routerParameters) {
        NSLog(@"回传的路由字典。。。。。%@",routerParameters);
        
        [weakSelf openViewControllerWithParam:routerParameters];
    }];
    
}
- (void)openViewControllerWithParam:(NSDictionary*)routerDic{
    
    BOOL isNative = [[routerDic objectForKey:@"isNative"] boolValue];
    
    if (isNative) {
        NSString* vcName = [routerDic objectForKey:@"VCName"];
        
        NSDictionary* vcParam = [routerDic objectForKey:@"VCParams"];
        [self openNative:vcName VCParam:vcParam];
        
    }else{
        
        NSString* urlString = [routerDic objectForKey:@"H5Router"];
        
        [self openWebPage:urlString];
    }
    
}
- (void)openNative:(NSString*)vcClassName VCParam:(NSDictionary*)param{
    
    id moudleInstance = [[NSClassFromString(vcClassName) alloc]init];
    
    if ([moudleInstance isKindOfClass:[UIViewController class]]) {
        UIViewController* vc = (UIViewController *)moudleInstance;
        [vc setValuesForKeysWithDictionary:param];
        
        //super ViewController
        [[self currentViewController].navigationController pushViewController:vc animated:YES];
        
    }else{
        NSLog(@"非view Controller...");
    }
    
}
- (void)openWebPage:(NSString*)urlString{
    UIViewController* vc = [[NSClassFromString(@"MYDWebViewController") alloc]init];
    [vc setValue:urlString forKey:@"linkUrl"];
    
    [[self currentViewController].navigationController pushViewController:vc animated:YES];
}

- (UIViewController *)currentViewController{
    
    UIViewController* topVc = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    return [self currentViewControllerFrom:topVc];
    
}

- (UIViewController *)currentViewControllerFrom:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        return [self currentViewControllerFrom:navigationController.viewControllers.lastObject];
    } else if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tableBarController = (UITabBarController *)viewController;
        return [self currentViewControllerFrom:tableBarController.selectedViewController];
    } else if (viewController.presentedViewController != nil) {
        return [self currentViewControllerFrom:viewController.presentedViewController];
    } else {
        return viewController;
    }
}
@end
