//
//  MYDRouterManager.h
//  JKHealth724
//
//  Created by 裴启瑞 on 2018/3/8.
//  Copyright © 2018年 裴启瑞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MYDRouterManager : NSObject

+ (MYDRouterManager *)sharedInstance;

/*
 *通过传入的页面key和相应的参数，打开
 */
- (void)openPageWithKey:(NSString*)key params:(NSDictionary*)param;
/*
 *通url，打开,例如：https://wx.jk724.com/product-brand/JHGH76TY9FD65, 是需要先进入MYDModulePlist.plist
 *进行匹配，然后判断是Native还是H5，然后打开
 */
- (void)openPageWithUrlString:(NSString *)urlString;

@end
