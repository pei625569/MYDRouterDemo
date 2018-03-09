//
//  MYDRouter.h
//  JKHealth724
//
//  Created by 裴启瑞 on 2018/3/8.
//  Copyright © 2018年 裴启瑞. All rights reserved.
//
/*
 *MYDRouter
 *是一个路由器，主要的功能就是对传入的一些参数进行解析和分发，将一些复杂参数解析为某一模块或者页面可以识别使用的参数；
 *具体的比如：
 *1、native ---> native/H5
 *2、H5 -- ---->native/H5
 *3、其他外部链接(通知、其他app) ------>native/H5;
 */

/**
 *1、路由模快的数据是从MYDModulePlist.plist文件中获取的，这个文件是需要人维护的，每实现一个模块或者页面都是需要往这个表中去添加；
 *2、这个文件可以本地存储，可以后端接口实现，怎么玩都可以
 *3、路由的实现方式是： open  -----> 如果没有注册----->去注册，并缓存 ----->  打开
                          |
                          |_____>直接打开
 
 */



#import <Foundation/Foundation.h>

/**r
 *  routerParameters 里内置的几个参数会用到上面定义的 string
 */
typedef void (^MYDRouterHandler)(NSDictionary* routerParameters);
/**
 *  routerContent 有可能是StringURL，有可能是一个路由字典
 */
typedef void (^MYDURLRouterHandler)(id routerContent);

typedef NS_ENUM(NSInteger, MYDOpenRouterResult){
    MYDOpenRouterResultNotRegisted = 0,//未注册，需要注册，再打开
    MYDOpenRouterResultFailed ,//没有这个路由,还未实现这个页面或者模块
    MYDOpenRouterResultSuccess,//路由已经缓存，可以随时打开
    
};
@interface MYDRouter : NSObject



@property (copy, nonatomic) MYDRouterHandler defaultHandler;

+ (MYDRouter*)sharedInstance;

/**
 *将已经实现的页面或者模块注册进入路由器中,并保存处理block；
 *moduleKey：页面或者模块的别名，需要是唯一识别号，将来作为路由字典的key
 *handler：是一个完整的，页面或者模块可识别的处理中心
 */
+ (BOOL)registModuleWithmoduleKey:(NSString*)moduleKey toHandler:(MYDRouterHandler)handler;


+ (BOOL)deRegistModuleWithmoduleKey:(NSString*)moduleKey;
/**
 * 通过key来打开对应的页面，通过key打开是需要注册的
 * moduleKey: 页面key
 * param: 页面参数
 */
+ (MYDOpenRouterResult)openModuleWithModuleKey:(NSString*)moduleKey moduleParam:(id)param;

/**
 * 通过URL来打开对应的页面，这个url严格意义上需要和RERouter正则匹配的，不匹配的话，就会使用文本View打开
 * urlString: url
 */
+ (id)openModuleWithUrl:(NSString*)moduleUrl;

@end
