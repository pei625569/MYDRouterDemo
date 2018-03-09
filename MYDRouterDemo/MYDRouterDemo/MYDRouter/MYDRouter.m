//
//  MYDRouter.m
//  JKHealth724
//
//  Created by 裴启瑞 on 2018/3/8.
//  Copyright © 2018年 裴启瑞. All rights reserved.
//

#import "MYDRouter.h"
static NSString *specialCharacters = @"|/?&.";

#import "MYDRouterFromURL.h"


@interface MYDRouter()

/*
 *这个里面装的是类似于：
 *@{@"routerKey":@{
                    @"_block_routerKey":handler,
                    @"routerDic":routerDic,
                },
 ...
 }
 */
@property (strong, nonatomic) NSDictionary* routerDictionary;

@property (strong, nonatomic) NSMutableDictionary* currentRouter;



@end

//从本地plist文件读取路由表
static inline NSDictionary* myd_readModuleFromBoudle(){
    
//    NSString* documenPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingFormat:@"/MYDModulePlist.plist"];
    
    NSString* path = [[NSBundle mainBundle]pathForResource:@"MYDModulePlist" ofType:@".plist"];
    NSDictionary* routerDic = nil;
    routerDic = [NSDictionary dictionaryWithContentsOfFile:path];
    
    return routerDic;
}


@implementation MYDRouter

+ (MYDRouter *)sharedInstance{
    static MYDRouter* router = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!router) {
            router = [[MYDRouter alloc]init];
        }
    });
    return router;
}

+ (BOOL)registModuleWithmoduleKey:(NSString *)moduleKey toHandler:(MYDRouterHandler)handler{
    
    return  [[self sharedInstance] addModule:moduleKey toHandler:handler];
    
}
+ (BOOL)deRegistModuleWithmoduleKey:(NSString *)moduleKey{
    if ([[self sharedInstance].routerDictionary objectForKey:moduleKey]) {
        NSMutableDictionary* dic = [[self sharedInstance].routerDictionary mutableCopy];
        
        [dic removeObjectForKey:moduleKey];
        return YES;
    }else{
        return NO;
    }
    
}

//通过key和传入的参数来获得最终要输出的路由
+ (MYDOpenRouterResult)openModuleWithModuleKey:(NSString *)moduleKey moduleParam:(id)param{
    
    NSMutableDictionary* routerDic = [[self sharedInstance].routerDictionary objectForKey:moduleKey];
    
    if (!routerDic) {
        //这个路由没有注册，请注册
        
        return MYDOpenRouterResultNotRegisted;
        
    }else if ([routerDic isEqualToDictionary:@{}]) {
        //没有这个路由，就跳转到一个默认的页面，给一个默认页面
        MYDRouterHandler defHandler = [self sharedInstance].defaultHandler;
        if (defHandler) {
            defHandler(nil);
        }
        return MYDOpenRouterResultFailed;
    }else{
        //获取模块对应的handler
        MYDRouterHandler handler = [[[self sharedInstance].routerDictionary objectForKey:moduleKey] objectForKey:[[self sharedInstance] moduleHandlerKeyName:moduleKey]];
        
        //通过这个函数将param赋值进路由字典，
        //包括把url拼接上参数，和需要的参数赋值
        
        NSDictionary* handlerDic = [[self sharedInstance] appendingParameterWithEnterParam:param moduleKey:moduleKey];
        
        if (handler) {
            handler(handlerDic);
        }
        return MYDOpenRouterResultSuccess;
    }
    
    
    
}

//通过url打开注册的路由
+ (id)openModuleWithUrl:(NSString *)moduleUrl{
    
    MYDRouterFromURL* transManam = [[MYDRouterFromURL alloc]init];
    
    return  [transManam routerFromUrlString:moduleUrl];
    
}

- (BOOL)addModule:(NSString *)moduleKey toHandler:(MYDRouterHandler)handler{
    
    
    NSDictionary* routerDicFile = [self routerDicWithModuleKey:moduleKey];
    NSMutableDictionary *subRoutes = [self.routerDictionary mutableCopy];
    if (!routerDicFile) {
        subRoutes[moduleKey] = @{};
        return NO;
    }else{

        NSMutableDictionary* routerDIc = [NSMutableDictionary dictionary] ;
        
        if (handler) {
            routerDIc[[self moduleHandlerKeyName:moduleKey]] = [handler copy];
        }
        routerDIc[@"routerDic"] = routerDicFile;
        
        subRoutes[moduleKey] = routerDIc;
        
        self.routerDictionary = subRoutes;
        return YES;
    }
    
    
    
}
//通过Key找到在router.plist文件中对应的路由字典,类似于：
/**
 *@{
 @"isNative":@"YES",
 @"VCName":@"ProductDetailViewController",
 @"VMNames":@"JKProductDetailViewModel",
 @"VCParams":@{@"title":@"商品详情",@"productId":@""},
 @"urlRouter":@"product/product-details/:id",
 @"title":@"商品详情"
 };
 */
- (NSDictionary*)routerDicWithModuleKey:(NSString*)routerKey{
    return [self routerDicWithKey:routerKey];
    
}

- (NSDictionary*)appendingParameterWithEnterParam:(NSDictionary*)enterParam moduleKey:(NSString*)moduleKey{
    //获取注册的路由字典
    @synchronized(self){
        self.currentRouter = [[[self.routerDictionary objectForKey:moduleKey] objectForKey:@"routerDic"] mutableCopy];
        
        if (enterParam) {
            
            //1、先拼接好native的参数
            NSDictionary* needParam = [self.currentRouter objectForKey:@"VCParams"];//这个是页面或者模块的参数
            
            NSDictionary* appdedParam = [self appendingParameter:needParam enterParam:enterParam];
            
            self.currentRouter[@"VCParams"] = appdedParam;
            //2、拼接url中的参数
            NSString* routerUrl = [self.currentRouter objectForKey:@"urlRouter"];
            //得到url中的参数列表
            NSArray* urlParamList = [self urlParamsFromURL:routerUrl];
            
            self.currentRouter[@"urlRouter"] = [self appendingUrlWithParameter:enterParam urlNeedParams:urlParamList originalUrlString:routerUrl];
            
        }
    }
        return self.currentRouter;
}


//获取路由字典中url中需要的参数列表；其依据是H5REString：url的正则表达式(RegularExpressing)
//参数规则可以自己定义，我暂且简单定义为‘:’

- (NSArray*)urlParamsFromURL:(NSString*)URL
{
    NSArray *pathComponents = [NSArray array];
    
    if (![URL containsString:@":"]) {
        //        NSLog(@"这个H5的url不需要参数");
    }else{
        pathComponents = [URL componentsSeparatedByString:@":"];
    }
    NSMutableArray* paramsKeyArray = [NSMutableArray array];
    
    for (int i = 1; i < pathComponents.count; i ++) {
        
        NSString* key = [self removeOtherCharacters:pathComponents[i]];
        
        [paramsKeyArray addObject:key];
    }
    
    return paramsKeyArray;
}
- (NSString*)removeOtherCharacters:(NSString*)key{
    
    NSCharacterSet *specialCharactersSet = [NSCharacterSet characterSetWithCharactersInString:specialCharacters];
    
    return [key stringByTrimmingCharactersInSet:specialCharactersSet];
    
}
//将获取的参数拼接到url后面,得到一个完整的url
- (NSString*)appendingUrlWithParameter:(NSDictionary*)enterParameter urlNeedParams:(NSArray*)urlParamList originalUrlString:(NSString*)originalUrl{
    
    NSString* finalUrl = originalUrl;
    
    if ([originalUrl containsString:@"?"]) {
        //包含‘？’的话，就应该找到其对应的参数列表
        //还要考虑类似于：product-brand?(keyword|keyword|id)=&key1=0909
        NSArray* paramArr = [originalUrl componentsSeparatedByString:@"?"];
        
        __block NSString* hUrlPrifix = paramArr.firstObject;
        
        __block NSString* hUrlSuffix = [self multiParmsUrl:paramArr.lastObject sendParams:enterParameter];
        
        [enterParameter enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([urlParamList containsObject:key]) {
                NSString* reStr_pri = [NSString stringWithFormat:@":%@",key];
                
                hUrlPrifix = [hUrlPrifix stringByReplacingOccurrencesOfString:reStr_pri withString:obj options:NSRegularExpressionSearch range:(NSRange){0,hUrlPrifix.length}];
                
                NSString* reStr_suf = [NSString stringWithFormat:@"%@=",key];
                
                hUrlSuffix = [hUrlSuffix stringByReplacingOccurrencesOfString:reStr_suf withString:[NSString stringWithFormat:@"%@=%@",key,obj] options:NSRegularExpressionSearch range:(NSRange){0,hUrlSuffix.length}];
            }
        }];
        
        finalUrl = [hUrlPrifix stringByAppendingFormat:@"?%@",hUrlSuffix];
    }else{
        
        __block NSString* reUrl = originalUrl;
        
        [enterParameter enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            NSString* reStr_pri = [NSString stringWithFormat:@":%@",key];
            if ([obj isKindOfClass:[NSNumber class]]) {
                obj = [NSString stringWithFormat:@"%@",obj];
            }
            reUrl = [reUrl stringByReplacingOccurrencesOfString:reStr_pri withString:obj options:NSRegularExpressionSearch range:(NSRange){0,reUrl.length}];
        }];
        
        finalUrl = reUrl;
    }
    
    return finalUrl;
}
//(keyword|keyword|id)=&key1=
- (NSString*)multiParmsUrl:(NSString*)string sendParams:(NSDictionary*)paDic{
    
    NSString* paramStr = nil;
    
    NSArray* pas = [string componentsSeparatedByString:@"&"];
    
    for (int i = 0; i < pas.count; i ++) {
        
        __block NSString* keySTr = [pas[i] componentsSeparatedByString:@"="].firstObject;
        
        if ([keySTr containsString:@"|"] && [keySTr containsString:@"("]) {
            keySTr = [keySTr substringWithRange:(NSRange){1,keySTr.length - 2}];
            NSArray* mutiKey = [keySTr componentsSeparatedByString:@"|"];
            
            [paDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([mutiKey containsObject:key]) {
                    keySTr = key;
                }
            }];
        }
        keySTr = [NSString stringWithFormat:@"%@=%@",keySTr,[pas[i] componentsSeparatedByString:@"="].lastObject];
        
        if (!paramStr) {
            paramStr = keySTr;
        }else{
            paramStr = [paramStr stringByAppendingFormat:@"&%@",keySTr];
        }
        
    }
    
    return paramStr;
    
}
//通过模块或者页面的key在本地路由表中找到当前的路由字典（keyRouterDic）
- (NSDictionary*)routerDicWithKey:(NSString*)routerKey{
    
    NSMutableDictionary* keyRouterDic = nil;
    
    NSDictionary* fileDic = myd_readModuleFromBoudle();
    
    if ([fileDic objectForKey:routerKey]) {
        
        NSDictionary* fileModuleDic = [fileDic objectForKey:routerKey];
        
        keyRouterDic = [fileModuleDic mutableCopy];
        
    }
    return keyRouterDic;
}

//把传入的参数的值赋予给页面或者模块需要的参数
- (NSDictionary*)appendingParameter:(NSDictionary*)needParameter enterParam:(NSDictionary*)enterParam{
    
    __block NSMutableDictionary* producedParam = [needParameter mutableCopy];
    
    [enterParam enumerateKeysAndObjectsUsingBlock:^(NSString* key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        //遍历传入的参数字典，
        if ([needParameter objectForKey:key]) {//如果这个传入的参数是需要的参数就把值赋过来，可以过滤多余参数
            [producedParam setObject:obj forKey:key];
        }
    }];
    
    return producedParam;
}



//通过模块或者页面名称来构建handler的名称
- (NSString*)moduleHandlerKeyName:(NSString*)routerKey{
    
    NSString* keyName = [NSString stringWithFormat:@"_block_%@",routerKey];
    
    return keyName;
}









#pragma mark ---- initalized some propertyties

- (NSDictionary *)routerDictionary{
    if (!_routerDictionary) {
        _routerDictionary = [NSDictionary dictionary];
    }
    return _routerDictionary;
}
- (NSMutableDictionary *)currentRouter{
    if (!_currentRouter) {
        _currentRouter = [NSMutableDictionary dictionary];
    }
    return _currentRouter;
}
@end

