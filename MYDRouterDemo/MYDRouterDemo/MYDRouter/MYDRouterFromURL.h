//
//  MYDRouterFromURL.h
//  JKHealth724
//
//  Created by 裴启瑞 on 2018/3/8.
//  Copyright © 2018年 裴启瑞. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MYDRouterFromURL : NSObject

/**
 *根据url来跳转
 */
- (id)routerFromUrlString:(NSString*)originalUrlString;

@end
