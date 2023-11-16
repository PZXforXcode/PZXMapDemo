//
//  UtilTool.m
//  cplus
//
//  Created by hsyouyou on 13-4-27.
//  Copyright (c) 2013年 parsec. All rights reserved.
//

#import <objc/message.h>
#import "UtilTool.h"
//#import "AppDelegate.h"
//#import "Constants.h"
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#import <dlfcn.h>
#import <sys/utsname.h>


@implementation UtilTool

/**
* status: 1 表示没有返回的数据 2 表示访问URL成功  3 表示已经从缓存中读取数据
* isReload: YES 表示从网络获取  NO 表示从缓存中获取
*/
+(NSString *)sendUrlRequestByCache:(NSString *)urlString paramValue:(NSString *)paramValue method:(HTTPRequestMethodType) method isReload:(BOOL)reload status:(NSNumber **)status
{

    NSArray *ar = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentPath = [ar objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingString:@"/fileCache.plist"];
    
    
    
    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (!jsonDic) {
        jsonDic = [[NSMutableDictionary alloc] init];
    }
    
    NSString *keyString = [NSString stringWithFormat:@"%@%@",urlString,paramValue];
    
    if (!reload) { //从缓存中读取
        if ([jsonDic valueForKey:keyString] && [[jsonDic valueForKey:keyString] length]>0 ) {
            *status = @3; //表示从缓存中取得数据
            return [jsonDic valueForKey:keyString];
        }
    }


    NSString* urlEncoding = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlEncoding] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    [UIApplication sharedApplication].networkActivityIndicatorVisible =NO;

//
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
//    request.timeoutInterval = 20;

    if(method == HTTPRequestMethodPost){
        [request setHTTPMethod:@"POST"];
    }else{
        [request setHTTPMethod:@"GET"];
    }

    if (paramValue && [paramValue length]>0) {
        [request setHTTPBody:[paramValue dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
    NSHTTPURLResponse *response;
    NSError* error ;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error){
        NSLog(@"====%@",[error localizedDescription]);
    }
    
    if (data==nil) {
        *status = [[NSNumber alloc] initWithInt:1];



        return nil;
    }

    
    
    if (response.statusCode!=200) {

        *status = [[NSNumber alloc] initWithInt:1];
        return nil;
    }
    
    
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];



    [jsonDic setValue:jsonString forKey:keyString];
    [jsonDic writeToFile:path atomically:YES];
    
    *status  = [[NSNumber alloc] initWithInt:2];//2表示从服务器中取得数据
    
    return jsonString;
    
}


+ (NSString *)getJSONFromCache:(NSString *)urlString paramValue:(NSString *)paramValue {

    NSArray *ar = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [ar objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingString:@"/fileCache.plist"];



    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (!jsonDic) {
        jsonDic = [[NSMutableDictionary alloc] init];
    }

    NSString *keyString = [NSString stringWithFormat:@"%@%@",urlString,paramValue];

    if ([jsonDic valueForKey:keyString] && [[jsonDic valueForKey:keyString] length]>0 ) {

            return [jsonDic valueForKey:keyString];
    }

    return nil;
}

+ (void)doRequestWithCallBack:(NSString *)urlString paramValue:(NSString *)paramValue method:(HTTPRequestMethodType)method target:(id)target callBack:(SEL)selector {




    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    request.timeoutInterval = 20;
    if(method == HTTPRequestMethodPost){
        [request setHTTPMethod:@"POST"];
    }else{
        [request setHTTPMethod:@"GET"];
    }

    if (paramValue && [paramValue length]>0) {
        [request setHTTPBody:[paramValue dataUsingEncoding:NSUTF8StringEncoding]];
    }


    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    //    NSLog(urlString);

    if (data==nil) {
        return;
    }


    if (response.statusCode!=200) {
        return;
    }


    NSArray *ar = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [ar objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingString:@"/fileCache.plist"];



    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionaryWithContentsOfFile:path];

    if (!jsonDic) {
        jsonDic = [[NSMutableDictionary alloc] init];
    }

    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *keyString = [NSString stringWithFormat:@"%@%@",urlString,paramValue];

    [jsonDic setValue:jsonString forKey:keyString];
    [jsonDic writeToFile:path atomically:YES];

    //回调一下 不知道为什么iOS8 下报错，我注释掉了这行，就无法完成回调了
//    objc_msgSend(target, selector,jsonString);
    
    if([target respondsToSelector:selector]){
        @try {
            [target performSelector:selector withObject:jsonString];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
      
    }
    

}


+(void)saveJSONStringWithUrl:(NSString *)keyValue JSONString:(NSString *)jsonString{
    
    NSArray *ar = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentPath = [ar objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingString:@"/fileCache.plist"];
    
    
    
    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
   
    if (!jsonDic) {
        jsonDic = [[NSMutableDictionary alloc] init];
    }

    [jsonDic setValue:jsonString forKey:keyValue];
    [jsonDic writeToFile:path atomically:YES];
 
}

//+(int)getAppVersion
//{
//    return VERSION_SEQ;
//}

+ (UIColor *) colorWithHexString: (NSString *) stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+(NSMutableDictionary *)getUserDic{
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arr objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingString:@"/UserInfo.plist"];
//    NSLog(@"===%@",path);
    NSMutableDictionary *userDic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (!userDic) {
        return nil;
    }
    return userDic;
}

+(NSString *)getToken{
    NSDictionary *dic=[UtilTool getUserDic];
    return [dic objectForKey:@"token"];
}

+(void)removeUserDic{
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arr objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingString:@"/UserInfo.plist"];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if(fileManager){
        NSError *error;
        [fileManager removeItemAtPath:path error:&error];

    }
}

+(void)saveUserDic:(NSDictionary *)userInf{
    
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arr objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingString:@"/UserInfo.plist"];
    
    [userInf writeToFile:path atomically:YES];

}

+(BOOL)saveFile:(NSMutableDictionary *)fileDict filename:(NSString *)filename
{
    //获取应用程序沙盒的Documents目录
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arr objectAtIndex:0];
     //得到完整的文件名
    NSString *path = [documentPath stringByAppendingPathComponent:filename];
    //输入写入
    return [fileDict writeToFile:path atomically:YES];
}


+(BOOL)saveArrFile:(NSMutableArray *)fileArr filename:(NSString *)filename
{
    //获取应用程序沙盒的Documents目录
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arr objectAtIndex:0];
    //得到完整的文件名
    NSString *path = [documentPath stringByAppendingPathComponent:filename];
    //输入写入
    return [fileArr writeToFile:path atomically:YES];
}

+(void)removeFile:(NSString *)filename
{
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arr objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingString:filename];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if(fileManager){
        NSError *error;
        [fileManager removeItemAtPath:path error:&error];
    }
}

+(NSMutableDictionary *)getDictionaryFile:(NSString *)filename
{
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arr objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingPathComponent:filename];

    NSMutableDictionary *fileDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (!fileDict) {
        return [[NSMutableDictionary alloc]init];
    }
    return fileDict;
}

+(NSMutableArray *)getArrFile:(NSString *)filename
{
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arr objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingPathComponent:filename];
    
    NSMutableArray *fileArr = [NSMutableArray arrayWithContentsOfFile:path];
    if (!fileArr) {
        return [[NSMutableArray alloc]init];
    }
    return fileArr;
}

+ (NSString *)getFilePathWithFileName:(NSString *)filename
{
    
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arr objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingString:filename];
    return path;
}



+(NSString *)getHostURL{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"host" ofType:@"plist"];
    NSDictionary *hostDic = [NSDictionary dictionaryWithContentsOfFile:path];
    return [hostDic objectForKey:@"hostUrl"];
}

+(NSDictionary *)getHostDic{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"host" ofType:@"plist"];
    NSDictionary *hostDic = [NSDictionary dictionaryWithContentsOfFile:path];
//    return [hostDic objectForKey:@"postfix"];
    return hostDic;
}

+(NSString *)getRootHostURL{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"host" ofType:@"plist"];
    NSDictionary *hostDic = [NSDictionary dictionaryWithContentsOfFile:path];
    return [hostDic objectForKey:@"rootUrl"];

}



+(NSString *)replaceString:(NSString *)searchStr replaceToString:(NSString *)replaceStr originalString:(NSString *)oldString{
    NSMutableString *oldStringMutable = [NSMutableString stringWithString:oldString];

    NSRange subrange = [oldStringMutable rangeOfString:searchStr];
    while (subrange.location != NSNotFound) {
        [oldStringMutable replaceCharactersInRange:subrange withString:replaceStr];
        subrange = [oldStringMutable rangeOfString:searchStr];
    }

    return [oldStringMutable substringFromIndex:0];
}




+(BOOL)isInteger:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

+(BOOL)isFloat:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

+(NSString *)getStringByDate:(NSDate *)date formatString:(NSString *)fs
{
    NSDateFormatter *dateformat = [[NSDateFormatter alloc]init];
    [dateformat setDateFormat:fs];
    return [dateformat stringFromDate:date];
}




+(UIImage*)screenshot
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
//    else
//        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

+(UIImage *)changeImg:(UIImage *)image max:(float)maxSize{
    if (image.size.width>maxSize || image.size.height>maxSize) {
        CGSize newSize;
        if (image.size.width > image.size.height) {
            newSize = CGSizeMake(maxSize, maxSize * (image.size.height/image.size.width));
        }else{
            newSize = CGSizeMake(maxSize*(image.size.width/image.size.height), maxSize);
        }
        UIGraphicsBeginImageContext(newSize);
        [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        // End the context
        UIGraphicsEndImageContext();
    }
    return image;
}

+ (void)saveDeviceToken:(NSString *)token {

    
    NSMutableDictionary *deviceDic = [[NSMutableDictionary alloc] init];
    [deviceDic setValue:token forKey:@"token"];
    
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arr objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingString:@"/device.plist"];

    [deviceDic writeToFile:path atomically:YES];

}

+(NSDictionary *)getDeviceToken{
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arr objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingString:@"/device.plist"];
    NSDictionary *deviceDic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (!deviceDic) {
        return nil;
    }
    return deviceDic;
}

+(void)removeDeviceToken{
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arr objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingString:@"/device.plist"];
    [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
}




+ (void)saveMsgTime:(NSString *)time {
    
    
    NSMutableDictionary *timeDic = [[NSMutableDictionary alloc] init];
    [timeDic setValue:time forKey:@"time"];
    
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arr objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingString:@"/time.plist"];
    
    [timeDic writeToFile:path atomically:YES];
    
}

+(NSDictionary *)getMsgTime{
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arr objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingString:@"/time.plist"];
    NSDictionary *timeDic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (!timeDic) {
        return nil;
    }
    return timeDic;
}

+(NSArray *)getAddr{
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arr objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingString:@"/addrs.plist"];
    //    NSLog(@"===%@",path);
    NSArray *addrs=[NSMutableArray arrayWithContentsOfFile:path];
    if (!addrs) {
        return nil;
    }
    return addrs;
}

+(void)savePerson:(NSDictionary *)person{
    NSMutableArray *array=(NSMutableArray *)[self getPersons];
    if(array==nil)
        array=[[NSMutableArray alloc]init];
    [array addObject:person];
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arr objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingString:@"/persons.plist"];
    NSLog(@"%@",path);
    [array writeToFile:path atomically:YES];
}

+(NSArray *)getPersons{
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentPath = [arr objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingString:@"/persons.plist"];
    NSArray *persons=[NSMutableArray arrayWithContentsOfFile:path];
    if (!persons) {
        return nil;
    }
    return persons;
}

+(NSArray *)deletePersons:(NSArray *)array{
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arr objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingString:@"/persons.plist"];
    NSArray *ps=[NSMutableArray arrayWithContentsOfFile:path];
    
    NSMutableArray *persons=[[NSMutableArray alloc]initWithArray:ps];
    
    for(NSDictionary *dic in array){
        [persons removeObject:dic];
    }
    
    [persons writeToFile:path atomically:YES];
    
    return persons;
}

+(NSString *)savePic:(UIImage *)image{
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arr objectAtIndex:0];
    
    NSDate *date=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *locationString=[dateformatter stringFromDate:date];
    
    NSString *path=[NSString stringWithFormat:@"%@/%@.png",documentPath,locationString];
    
    [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
    return path;
}


+(void)ShowAlertView:(NSString *)title setMsg:(NSString *)msg
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction  *ok =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
                
    }];

    [alert addAction:ok];
    [[UtilTool getCurrentViewController] presentViewController:alert animated:YES completion:nil];

}

+ (UIViewController *)getCurrentViewController {
    UIWindowScene *windowScene = (UIWindowScene *)[[[UIApplication sharedApplication] connectedScenes] anyObject];
    UIViewController *viewController = windowScene.windows.firstObject.rootViewController;
    while (viewController.presentedViewController) {
        viewController = viewController.presentedViewController;
    }
    return viewController;
}

+(BOOL)validateMobile:(NSString *)phone
{
    NSString *regex = @"^((13[0-9])|(15[0-9])|(18[0-9]))\\d{8}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ( ![predicate evaluateWithObject:phone] ) {
        [UtilTool ShowAlertView:nil setMsg:@"请输入一个正确的电话号码"];
        return NO;
    }else
        return YES;
}

+ (UIFont *)currentSystemFont:(CGFloat)size {
    return [UIFont fontWithName:@"MicrosoftYaHei" size:size];


}

+ (UIDeviceResolution) currentResolution {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            result = CGSizeMake(result.width * [UIScreen mainScreen].scale, result.height * [UIScreen mainScreen].scale);
            if (result.height <= 480.0f)
                return UIDevice_iPhoneStandardRes;
            return (result.height > 960 ? UIDevice_iPhoneTallerHiRes : UIDevice_iPhoneHiRes);
        } else
            return UIDevice_iPhoneStandardRes;
    } else
        return (([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) ? UIDevice_iPadHiRes : UIDevice_iPadStandardRes);
}


+(NSMutableDictionary *) getMsgReadStatus{
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arr objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingString:@"/msgReadStatus.plist"];
    NSMutableDictionary *msgReadDic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (!msgReadDic) {
        return nil;
    }
    return msgReadDic;
}


+(void)saveMsgReadStatus:(NSMutableDictionary *)msgStatusDic{
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arr objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingString:@"/msgReadStatus.plist"];

    [msgStatusDic writeToFile:path atomically:YES];
}

+(float)getiOSVersion{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
    
}

+(UIViewController *) getCurrentViewController:(UIView *)view
{
    id target= view;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

+(BOOL)judgeIsLogin {
    NSDictionary *dic = [UtilTool getUserDic];
    if (dic == nil) {
        return false;
    }else {
        return true;
    }
}

+(void)createNotification:(NSDictionary *)dict
{
    UILocalNotification *notifi = [[UILocalNotification alloc]init];
    if (notifi) {
        
        NSDate *currentDate   = [NSDate date];
        notifi.timeZone = [NSTimeZone defaultTimeZone]; // 使用本地时区
        notifi.fireDate = [currentDate dateByAddingTimeInterval:3];
        
        notifi.alertBody = [dict objectForKey:@"content"];
        notifi.alertAction =  [dict objectForKey:@"title"];
        notifi.soundName = UILocalNotificationDefaultSoundName;
        notifi.applicationIconBadgeNumber ++;
        
        
        [[UIApplication sharedApplication]scheduleLocalNotification:notifi];
    }
    
}

/**
 *如果用户没有打开推送，则弹出一个对话框询问用户是否打开
 */
+(void)openRemoteNotificationSetting:(id)delegate
{

//    if ([self getiOSVersion] >= 8.0) {
//        UIUserNotificationType unt = [[[UIApplication sharedApplication] currentUserNotificationSettings]types];
//        if (unt == UIUserNotificationTypeNone) {
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"车痒痒将向您推送消息\n是否允许？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"设置",nil];
//            alert.tag = 13579;//区分界面中其它的对话框
//            alert.delegate = delegate;
//            [alert show];
//        }
//
//    }else{
//        if ([UIApplication sharedApplication].enabledRemoteNotificationTypes == UIRemoteNotificationTypeNone) {
//            [UtilTool ShowAlertView:nil setMsg:@"请打开系统设置中“通知→易装房”\n打开允许通知"];
//        }
//    }

}

/**
 *如果用户没有打开定位，则弹出一个对话框询问用户是否打开
 */
+(void)openLocationSetting:(id)delegate userLocationManger:(CLLocationManager *)lm
{
    if ([self getiOSVersion] >= 8.0) {
        CLAuthorizationStatus stat = [CLLocationManager authorizationStatus];
        if ( stat == kCLAuthorizationStatusNotDetermined || stat == kCLAuthorizationStatusDenied || stat == kCLAuthorizationStatusRestricted) {
//            [UtilTool ShowAlertView:nil setMsg:@"请打开系统设置中“隐私→定位服务”\n允许“大晶装饰”使用您的位置"];
            [lm requestAlwaysAuthorization];
            
        }
    }else{
        if(![CLLocationManager locationServicesEnabled]) {
//            [UtilTool ShowAlertView:nil setMsg:@"请打开系统设置中“隐私→定位服务”\n允许“易装房”使用您的位置"];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"请打开系统设置中“隐私→定位服务”\n允许“车痒痒”使用您的位置" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"设置",nil];
            alert.tag = 24680;//区分界面中其它的对话框
            alert.delegate = delegate;
            [alert show];
        }
    }
}

+(BOOL)validateNumber:(NSString *)num{
    NSString *p = @"(^[1-9]$)|(^[1-9][0-9]$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", p];
    if (![predicate evaluateWithObject:num]) {
//        [UtilTool ShowAlertView:nil setMsg:@"请输入正确的数量"];
        return NO;
    }else{
        return YES;
    }
}
//校验车牌号
+(BOOL)validateCarNumber:(NSString *)num{
    NSString *carRegex = @"^[\u4e00-\u9fa5]{1}[A-Za-z]{1}[A-Za-z_0-9]{5}$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    return [carTest evaluateWithObject:num];
}

+ (NSMutableDictionary *)getUserCityDic
{
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"cityDic"];
}
+ (NSString *) localWiFiIPAddress
{
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"])  // Wi-Fi adapter
                    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return nil;
}

+ (void)setLabelText:(UILabel *)label
            WithName:(NSString *)iconName
            WithSize:(CGFloat )size
{
    
    label.font = [UIFont fontWithName:@"iconfont" size:size];
    label.text = iconName;
}


+ (BOOL)validateEmail:(NSString *)email
{
    BOOL flag;
    //如果不输入身份证也可以通过.
    if (email.length <= 0) {
        flag = YES;
        return flag;
    }

    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)validatePhone:(NSString *)phone
{
    NSString *phoneRegex = @"1[3|5|7|8|][0-9]{9}";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:phone];
}


//判断登陆状态
+(BOOL)loginVC{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL loginVC = [userDefaults boolForKey: @"loginVC"];
    return loginVC;
}
//存登陆状态
+(void)setLoginVC:(BOOL)loginVC{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:loginVC forKey:@"loginVC"];
    [userDefaults synchronize];
}
////身份证号
+ (BOOL) validateIdentityCard: (NSString *)identityCard
{
    BOOL flag;
    //如果不输入身份证也可以通过.
    if (identityCard.length <= 0) {
        flag = YES;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
}
+ (void)saveUserToken:(NSString *)token
{
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arr objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingString:@"/token.plist"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (dic == nil) {
        dic = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    [dic setObject:token forKey:@"token"];
    [dic writeToFile:path atomically:YES];
}
+ (NSString *)getUserToken
{
    NSArray *arr  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [arr objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingString:@"/token.plist"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    return  dic[@"token"];
}

// 数组转json字符串方法
+(NSString *)convertToJsonData:(id )arr
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arr options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}




+ (NSDictionary *)UriToDict:(NSString *)uri {
    NSURLComponents* wxNASAURLComponents =  [NSURLComponents componentsWithString:uri];
    NSMutableDictionary* queryItemDict = [NSMutableDictionary dictionary];
    NSArray* queryItems = wxNASAURLComponents.queryItems;
    for (NSURLQueryItem* item in queryItems) {
        [queryItemDict setObject:item.value forKey:item.name];
    }
    return queryItemDict;
}

+(void)ShowAlertView:(NSString *)title setMsg:(NSString *)msg leftButtonTitle:(NSString *)leftTitle leftStyle:(UIAlertActionStyle)leftStyle rightButtonTitle:(NSString *)rightTitle rightStyle:(UIAlertActionStyle)rightStyle VC:(UIViewController *)vc leftblock:(OKbuttonBlock)leftblock rightbuttonBlock:(CancelbuttonBlock)rightblock{
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction  *ok =[UIAlertAction actionWithTitle:leftTitle style:leftStyle handler:^(UIAlertAction * _Nonnull action) {
        
        leftblock();
        
        
    }];
    UIAlertAction  *cancel =[UIAlertAction actionWithTitle:rightTitle style:rightStyle handler:^(UIAlertAction * _Nonnull action) {
        
        rightblock();
    }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [vc presentViewController:alert animated:YES completion:nil];
    
    
}

+(void)ShowAlertSheetWithTitle:(NSString *)title setMsg:(NSString *)msg WithButtonTitles:(NSArray *)buttonTitles WithButtonStyleArray:(NSArray *)buttonStyles VC:(UIViewController *)vc buttonBlock:(AlertSheetButtonBlock )buttonBlock{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleActionSheet];
    for (int i = 0; i<[buttonTitles count]; i++) {
        
        UIAlertAction  *button =[UIAlertAction actionWithTitle:buttonTitles[i] style:(UIAlertActionStyle)[buttonStyles[i] intValue] handler:^(UIAlertAction * _Nonnull action) {
                        
            buttonBlock(i);
            
        }];
        [alert addAction:button];
    }
    [vc presentViewController:alert animated:YES completion:nil];


}

+(NSAttributedString *)SetDeleteWithString:(NSString *)string{
    
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc]initWithString:string];
    NSUInteger length = [string length];
    [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, length)];
    [attri addAttribute:NSStrikethroughColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, length)];

    return attri;
}

+(BOOL)isFirstLaunchApp{
    
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstStart"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstStart"];

        return YES;
        
        
    }else{
        
        return NO;
    }
}


+ (NSData *)compressQualityWithMaxLength:(NSInteger)maxLength WithImage:(UIImage *)image {//通过二分法来优化。
    
   CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    
    if (data.length < maxLength) return data;
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    
    return data;
}


/*!
 *  @brief 使图片压缩后刚好小于指定大小
 *
 *  @param image 当前要压缩的图 maxLength 压缩后的大小
 *
 *  @return 图片对象
 */
//图片质量压缩到某一范围内，如果后面用到多，可以抽成分类或者工具类,这里压缩递减比二分的运行时间长，二分可以限制下限。
+ (UIImage *)compressImageSize:(UIImage *)image toByte:(NSUInteger)maxLength{
    //首先判断原图大小是否在要求内，如果满足要求则不进行压缩，over
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return image;
    //原图大小超过范围，先进行“压处理”，这里 压缩比 采用二分法进行处理，6次二分后的最小压缩比是0.015625，已经够小了
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    //判断“压处理”的结果是否符合要求，符合要求就over
    UIImage *resultImage = [UIImage imageWithData:data];
    if (data.length < maxLength) return resultImage;
    
    //缩处理，直接用大小的比例作为缩处理的比例进行处理，因为有取整处理，所以一般是需要两次处理
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        //获取处理后的尺寸
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio)));
        //通过图片上下文进行处理图片
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //获取处理后图片的大小
        data = UIImageJPEGRepresentation(resultImage, compression);
    }
    
    return resultImage;
}


+ (NSString *)getCurrentDeviceModel{
   struct utsname systemInfo;
   uname(&systemInfo);
   
   NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
   
   
if ([deviceModel isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
if ([deviceModel isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
if ([deviceModel isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
if ([deviceModel isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
if ([deviceModel isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
if ([deviceModel isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
if ([deviceModel isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
if ([deviceModel isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
if ([deviceModel isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
if ([deviceModel isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
if ([deviceModel isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
if ([deviceModel isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
if ([deviceModel isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
if ([deviceModel isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
if ([deviceModel isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
// 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
if ([deviceModel isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
if ([deviceModel isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
if ([deviceModel isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
if ([deviceModel isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
if ([deviceModel isEqualToString:@"iPhone10,1"])   return @"iPhone_8";
if ([deviceModel isEqualToString:@"iPhone10,4"])   return @"iPhone_8";
if ([deviceModel isEqualToString:@"iPhone10,2"])   return @"iPhone_8_Plus";
if ([deviceModel isEqualToString:@"iPhone10,5"])   return @"iPhone_8_Plus";
if ([deviceModel isEqualToString:@"iPhone10,3"])   return @"iPhone X";
if ([deviceModel isEqualToString:@"iPhone10,6"])   return @"iPhone X";
if ([deviceModel isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
if ([deviceModel isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
if ([deviceModel isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
if ([deviceModel isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
if ([deviceModel isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
if ([deviceModel isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
if ([deviceModel isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
if ([deviceModel isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
if ([deviceModel isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
if ([deviceModel isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
if ([deviceModel isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
if ([deviceModel isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
if ([deviceModel isEqualToString:@"iPad1,1"])      return @"iPad";
if ([deviceModel isEqualToString:@"iPad1,2"])      return @"iPad 3G";
if ([deviceModel isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
if ([deviceModel isEqualToString:@"iPad2,2"])      return @"iPad 2";
if ([deviceModel isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
if ([deviceModel isEqualToString:@"iPad2,4"])      return @"iPad 2";
if ([deviceModel isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
if ([deviceModel isEqualToString:@"iPad2,6"])      return @"iPad Mini";
if ([deviceModel isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
if ([deviceModel isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
if ([deviceModel isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
if ([deviceModel isEqualToString:@"iPad3,3"])      return @"iPad 3";
if ([deviceModel isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
if ([deviceModel isEqualToString:@"iPad3,5"])      return @"iPad 4";
if ([deviceModel isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
if ([deviceModel isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
if ([deviceModel isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
if ([deviceModel isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
if ([deviceModel isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
if ([deviceModel isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
if ([deviceModel isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
if ([deviceModel isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
if ([deviceModel isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
if ([deviceModel isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
if ([deviceModel isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
if ([deviceModel isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
if ([deviceModel isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
if ([deviceModel isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
if ([deviceModel isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
if ([deviceModel isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
if ([deviceModel isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";

if ([deviceModel isEqualToString:@"AppleTV2,1"])      return @"Apple TV 2";
if ([deviceModel isEqualToString:@"AppleTV3,1"])      return @"Apple TV 3";
if ([deviceModel isEqualToString:@"AppleTV3,2"])      return @"Apple TV 3";
if ([deviceModel isEqualToString:@"AppleTV5,3"])      return @"Apple TV 4";

if ([deviceModel isEqualToString:@"i386"])         return @"Simulator";
if ([deviceModel isEqualToString:@"x86_64"])       return @"Simulator";
    return deviceModel;
}
@end
