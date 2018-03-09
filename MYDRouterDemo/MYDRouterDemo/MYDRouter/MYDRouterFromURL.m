//
//  MYDRouterFromURL.m
//  JKHealth724
//
//  Created by 裴启瑞 on 2018/3/8.
//  Copyright © 2018年 裴启瑞. All rights reserved.
//

#import "MYDRouterFromURL.h"
#define MYD_SCHEM @"myd://"

@interface MYDRouterFromURL()

@end

@implementation MYDRouterFromURL

- (id)routerFromUrlString:(NSString *)originalUrlString{

#warning 注意，在这里可以处理特殊的url，并直接return 一个页面字典，比如一级页面的啦什么的
    
    
    NSString* url = originalUrlString;//[self removeUrlSchem:originalUrlString];
    
    __block NSDictionary* routerDic = nil;
    
    [[self routerDictionaryFromFile] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        NSString* objRe = [obj objectForKey:@"urlREString"];
        
        NSRegularExpression* regEx = [NSRegularExpression regularExpressionWithPattern:objRe options:0 error:nil];
        
        [regEx enumerateMatchesInString:url options:0 range:(NSRange){0, url.length} usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            
            routerDic = obj;
        }];
        
    }];
    
    //如果匹配到了路由字典，则返回一个路由字典，否则，返回一个URLString
    if (routerDic) {
        routerDic = [self setvaluesAsRouterDic:routerDic urlString:url];
        return routerDic;
    }else{
        return originalUrlString;
        
    }
    return @"none-observer";
}

- (NSDictionary*)setvaluesAsRouterDic:(NSDictionary*)originalRouterDic urlString:(NSString*)urlString{
    
    NSMutableDictionary* routerDic = [originalRouterDic mutableCopy];
    
    NSString* h5Router = [routerDic objectForKey:@"urlRouter"];
    
    //接下来需要将URL中的:string参数解析成Native可识别的参数:Dictionary
    
    NSDictionary* vcParam = [self stringParamTransDictionaryParam:urlString routerDicH5url:h5Router];
    
    NSMutableDictionary* oriVcParam = [[originalRouterDic objectForKey:@"VCParams"] mutableCopy];
    
    for (NSString* key in vcParam) {
        [oriVcParam setValue:vcParam[key] forKey:key];
    }
    
    [routerDic setValue:urlString forKey:@"urlRouter"];
    
    [routerDic setValue:oriVcParam forKey:@"VCParams"];
    
    return [routerDic copy];
}

- (NSDictionary*)stringParamTransDictionaryParam:(NSString*)urlString routerDicH5url:(NSString*)h5Url{
    
    NSString* url = urlString;
    NSString* REurl = h5Url;
    
    NSMutableDictionary* mudic = [NSMutableDictionary dictionary];
    if ([REurl containsString:@"?"] && [url containsString:@"?"]) {
        
        NSArray* REMutiArr = [REurl componentsSeparatedByString:@"?"];
        NSArray* urlMutiArr = [url componentsSeparatedByString:@"?"];
        NSString* prifix_REUrl = REMutiArr.firstObject;
        NSString* prifix_Url = urlMutiArr.firstObject;
        NSString* suffix_Url = urlMutiArr.lastObject;
        NSArray* paraArr = [suffix_Url componentsSeparatedByString:@"&"];
        for (NSString* kvStr in paraArr) {
            [mudic setValue:[kvStr componentsSeparatedByString:@"="].lastObject forKey:[kvStr componentsSeparatedByString:@"="].firstObject];
        }
        NSArray* rearr = [prifix_REUrl componentsSeparatedByString:@"/"];
        NSArray* urlArr = [prifix_Url componentsSeparatedByString:@"/"];
        for (int i = 0; i < urlArr.count; i ++) {
            NSString* valuStr = urlArr[i];
            NSString*  keyStr= rearr[i];
            if (![keyStr isEqual:valuStr]) {
                [mudic setValue:valuStr forKey:[keyStr substringFromIndex:1]];
            }
        }
    }else{
        NSArray* keyArr = [REurl componentsSeparatedByString:@"/"];
        NSArray* valueArr = [url componentsSeparatedByString:@"/"];
        for (int i = 0; i < keyArr.count; i ++) {
            NSString* valuStr = valueArr[i];
            NSString*  keyStr= keyArr[i];
            if (![keyStr isEqual:valuStr]) {
                [mudic setValue:valuStr forKey:[keyStr substringFromIndex:1]];
            }
        }
    }
    return [mudic copy];
}



//从router.plist文件中招待路由字典
- (NSDictionary*)routerDictionaryFromFile{
    
//    NSString* documenPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingFormat:@"/MYDModulePlist.plist"];
//    
//    NSDictionary* routerDic = nil;
//    
//    routerDic = [NSDictionary dictionaryWithContentsOfFile:documenPath];

    NSString* path = [[NSBundle mainBundle]pathForResource:@"MYDModulePlist" ofType:@".plist"];
    NSDictionary* routerDic = nil;
    routerDic = [NSDictionary dictionaryWithContentsOfFile:path];
    
    return routerDic;
    
}
//将url中的scheme和host去掉，只留下间接地址,这里可以根据自己需求来定义
- (NSString*)removeUrlSchem:(NSString*)urlString{
    
    NSString* newUrl = urlString;
    
    NSString* urlSchem = MYD_SCHEM;
    
    if ([newUrl containsString:urlSchem]) {
        newUrl = [newUrl substringFromIndex:urlSchem.length];
    }else if ([newUrl hasPrefix:@"/"]){
        newUrl = [newUrl substringFromIndex:1];
    }
    
    return newUrl;
    
}

@end
