//
//  CommonUtility.m
//  SearchV3Demo
//
//  Created by songjian on 13-8-22.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "CommonUtility.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
//#import <EaseUI.h>
#import <UserNotifications/UserNotifications.h>
#import <Security/Security.h>
#import <AudioToolbox/AudioToolbox.h>
static NSDateFormatter *formater;

NSString * const KEY_UDID_INSTEAD = @"YJLUNUEHT5.pengzuxin.Smallsaltclub";


@implementation CommonUtility

//+ (NSString*) userHeaderImageUrl:(NSString*)ids
//{
//    return [NSString stringWithFormat:@"%@getMHeadIcon?id=%@&token=%@",kserviceURL,
//     ids,
//     [GlobalData sharedInstance].user.session];
//}


+ (void) callTelphone:(NSString*)number
{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",number]]];
}

+ (void) sendMessage:(NSString*)number
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@",number]]];
}

+ (BOOL) validateParams:(NSString*)params withRegular:(NSString*)regular
{
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regular];
    return [numberPre evaluateWithObject:params];
}

+ (BOOL) validateNumber:(NSString*)params
{
    ///(^\d+(\.)?)?\d+$
    NSString *number=@"(^\\d+(\\.)?)?\\d+$";//@"^\\d+\\.?\\d+$";//^\d+\.?\d+$ @"^[0-9]+$"
    return [CommonUtility validateParams:params withRegular:number];
}
+ (BOOL) validateSizeForm:(NSString*)params
{
    NSString *size = @"^\\d+(x|X)\\d+(x|X)\\d+$";
    return [CommonUtility validateParams:params withRegular:size];
}

+ (BOOL) validatePhoneNumber:(NSString*)param
{
    NSString *regular = @"^1[3|4|5|7|8]\\d[0-9]\\d{7}$";
    return [CommonUtility validateParams:param withRegular:regular];
}

+ (NSString*)versions
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString*)builds
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (NSString*)getUUID
{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

+ (NSString *)getIPAddress{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

+(NSString *)deviceWANIPAdress{
    NSError *error;
    NSURL *ipURL = [NSURL URLWithString:@"http://pv.sohu.com/cityjson?ie=utf-8"];
    NSMutableString *ip = [NSMutableString stringWithContentsOfURL:ipURL encoding:NSUTF8StringEncoding error:&error];
    //判断返回字符串是否为所需数据
    if ([ip hasPrefix:@"var returnCitySN = "]) {
        //对字符串进行处理，然后进行json解析
        //删除字符串多余字符串
        NSRange range = NSMakeRange(0, 19);
        [ip deleteCharactersInRange:range];
        NSString * nowIp =[ip substringToIndex:ip.length-1];
        //将字符串转换成二进制进行Json解析
        NSData * data = [nowIp dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        return [dict objectForKey:@"cip"];
    }
    return nil;
}

+(void)showShado:(UIView *)view{
    view.layer.cornerRadius = 5;
    //    _headView.layer.masksToBounds = YES;
    view.layer.shadowColor = [UIColor blackColor].CGColor;//设置阴影的颜色
    view.layer.shadowOpacity = 0.3f;//设置阴影的透明度
    view.layer.shadowRadius = 3;//设置阴影的圆角
    view.layer.shadowOffset = CGSizeMake(0, 0);//设置阴影的偏移量
}

/**
 * 开始到结束的时间差
 */
+ (NSDictionary *)getBabyDetailAge:(NSString *)date{
    NSTimeInterval interval    =[date doubleValue] / 1000.0;
    NSDate *dates               = [NSDate dateWithTimeIntervalSince1970:interval];
    
    // 获得日期对象
    NSDateFormatter *formatter_ = [[NSDateFormatter alloc] init];
    formatter_.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString * ddd = [formatter_ stringFromDate:dates];

    NSDate *createDate = [formatter_ dateFromString:ddd];
    
    NSCalendar *gregorian = [[ NSCalendar alloc ] initWithCalendarIdentifier : NSCalendarIdentifierGregorian];
    NSUInteger unitFlags = NSCalendarUnitYear |NSCalendarUnitMonth|NSCalendarUnitDay |   NSCalendarUnitHour | NSCalendarUnitMinute ;
    NSDateComponents *components = [gregorian components:unitFlags fromDate:createDate toDate:[NSDate date] options: 0 ];
    
    int years = abs((short)[components year]) ;
    int months = abs((short)[components month]);
    int days = abs((short)[components day]);
    int hour = abs((short)[components hour ]);
    int minute = abs((short)[components minute ]) ;
    NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)years],@"years",[NSString stringWithFormat:@"%ld",(long)months],@"months",[NSString stringWithFormat:@"%ld",(long)days],@"days",[NSString stringWithFormat:@"%ld",(long)hour],@"hour",[NSString stringWithFormat:@"%ld",(long)minute],@"minute", nil];
    return dic;
}
/**
 *  是否为同一天
 */
+ (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}


#pragma mark 倒计时
+(void)startTime:(UIButton *)sender{
    sender.selected = YES;
    __block int timeout=59; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                sender.selected = NO;
                //设置界面的按钮显示 根据自己需求设置 特别注明：UI的改变一定要在主线程中进行
                [sender setTitle:@"重新获取" forState:UIControlStateNormal];
                [sender setBackgroundColor:[UIColor clearColor]];
                [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                sender.userInteractionEnabled = YES;
                if (sender.layer.borderWidth) {
                    sender.layer.borderColor = [UIColor redColor].CGColor;
                }
                
            });
        }else{
            //            int minutes = timeout / 60;
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [sender setTitle:[NSString stringWithFormat:@"%@秒",strTime] forState:UIControlStateNormal];
                [sender setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                [sender setBackgroundColor:[UIColor clearColor]];
                if (sender.layer.borderWidth) {
                    sender.layer.borderColor = [UIColor lightGrayColor].CGColor;
                }
                sender.userInteractionEnabled = NO;
                
            });
            timeout--;
            
        }
    });
    dispatch_resume(_timer);
    
}

#pragma mark 注册成功
//+(void)loginSuccess:(id)response{


//    [UserModel sharedInstance].introduce = [NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"introduce"]];
//    [UserModel sharedInstance].invite_code = [NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"invite_code"]];
//    [UserModel sharedInstance].weixin_auth = [NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"weixin_auth"]];
//    [UserModel sharedInstance].gravatar = [NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"gravatar"]];
//    [UserModel sharedInstance].user_name_modify_num = [NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"user_name_modify_num"]];
//    [UserModel sharedInstance].sex = [NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"sex"]];
//    [UserModel sharedInstance].score = [NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"score"]];
//    [UserModel sharedInstance].company_auth = [NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"company_auth"]];
//    [UserModel sharedInstance].city_name = [NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"city_name"]];
//    [UserModel sharedInstance].industry_tag = [NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"industry_tag"]];
//    [UserModel sharedInstance].school_name = [NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"school_name"]];
//    [UserModel sharedInstance].pay_pwd_flag = [NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"pay_pwd_flag"]];
//    [UserModel sharedInstance].industry_ids = [NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"industry_ids"]];
//    [UserModel sharedInstance].uid = [NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"uid"]];
//    [UserModel sharedInstance].phone = [NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"phone"]];
//    [UserModel sharedInstance].personal_auth = [NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"personal_auth"]];
//    [UserModel sharedInstance].student_auth = [NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"student_auth"]];
//    [UserModel sharedInstance].experience = [NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"experience"]];
//    [UserModel sharedInstance].alipay_auth = [NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"alipay_auth"]];
//    [UserModel sharedInstance].user_name = [NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"user_name"]];
//    [UserModel sharedInstance].email = [NSString stringWithFormat:@"%@",[[response objectForKey:@"data"] objectForKey:@"email"]];
//
//    [USERDEFAULTS setObject:[response objectForKey:@"data"] forKey:@"USERINFO"];
//    [CloudPushSDK bindAccount:[UserModel sharedInstance].uid withCallback:^(CloudPushCallbackResult *res) {
//        NSLog(@"阿里推送注册成功！");
//    }];
//    EMError *error = [[EMClient sharedClient] loginWithUsername:[UserModel sharedInstance].uid password:[CommonUtility sha1:[UserModel sharedInstance].phone]];
//    if (!error)
//    {
//        [[EMClient sharedClient].options setIsAutoLogin:YES];
//        NSLog(@"登录成功");
//    }
//}

//保持原来的长宽比，生成一个缩略图
+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }
    else{
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }
        else{
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}

#pragma mark 裁剪出的图片尺寸按照size的尺寸，但图片不拉伸，但多余部分会被裁减掉
+ (UIImage *)thumbnailWithImage:(UIImage *)originalImage size:(CGSize)size
{
    CGSize originalsize = [originalImage size];
    //原图长宽均小于标准长宽的，不作处理返回原图
    if (originalsize.width<size.width && originalsize.height<size.height)
    {
        return originalImage;
    }
    //原图长宽均大于标准长宽的，按比例缩小至最大适应值
    else if(originalsize.width>size.width && originalsize.height>size.height)
    {
        CGFloat rate = 1.0;
        CGFloat widthRate = originalsize.width/size.width;
        CGFloat heightRate = originalsize.height/size.height;
        rate = widthRate>heightRate?heightRate:widthRate;
        CGImageRef imageRef = nil;
        if (heightRate>widthRate)
        {
            imageRef = CGImageCreateWithImageInRect([originalImage CGImage], CGRectMake(0, originalsize.height/2-size.height*rate/2, originalsize.width, size.height*rate));//获取图片整体部分
        }
        else
        {
            imageRef = CGImageCreateWithImageInRect([originalImage CGImage], CGRectMake(originalsize.width/2-size.width*rate/2, 0, size.width*rate, originalsize.height));//获取图片整体部分
        }
        UIGraphicsBeginImageContext(size);//指定要绘画图片的大小
        CGContextRef con = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(con, 0.0, size.height);
        CGContextScaleCTM(con, 1.0, -1.0);
        CGContextDrawImage(con, CGRectMake(0, 0, size.width, size.height), imageRef);
        UIImage *standardImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CGImageRelease(imageRef);
        return standardImage;
    }
    //原图长宽有一项大于标准长宽的，对大于标准的那一项进行裁剪，另一项保持不变
    else if(originalsize.height>size.height || originalsize.width>size.width)
    {
        CGImageRef imageRef = nil;
        if(originalsize.height>size.height)
        {
            imageRef = CGImageCreateWithImageInRect([originalImage CGImage], CGRectMake(0, originalsize.height/2-size.height/2, originalsize.width, size.height));//获取图片整体部分
        }
        else if (originalsize.width>size.width)
        {
            imageRef = CGImageCreateWithImageInRect([originalImage CGImage], CGRectMake(originalsize.width/2-size.width/2, 0, size.width, originalsize.height));//获取图片整体部分
        }
        UIGraphicsBeginImageContext(size);//指定要绘画图片的大小
        CGContextRef con = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(con, 0.0, size.height);
        CGContextScaleCTM(con, 1.0, -1.0);
        CGContextDrawImage(con, CGRectMake(0, 0, size.width, size.height), imageRef);
        UIImage *standardImage = UIGraphicsGetImageFromCurrentImageContext();
        NSLog(@"改变后图片的宽度为%f,图片的高度为%f",[standardImage size].width,[standardImage size].height);
        UIGraphicsEndImageContext();
        CGImageRelease(imageRef);
        return standardImage;
    }
    //原图为标准长宽的，不做处理
    else
    {
        return originalImage;
    }
}

#pragma mark 简单粗暴地图片裁剪方法 裁剪出的图片尺寸按照size的尺寸，但图片可能会被拉伸
+ (UIImage *)thumbnailWithImageLa:(UIImage *)originalImage size:(CGSize)size
{
    UIImage *newimage;
    if (nil == originalImage) {
        newimage = nil;
    }
    else{
        UIGraphicsBeginImageContext(size);
        [originalImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
    
}





+ (NSString *)timeWithTimeIntervalString:(NSString *)timeString
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]/ 1000.0];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}

+ (NSString *)timeWithMonthDay:(NSString *)timeString
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"MM月dd日"];
    
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]/ 1000.0];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}



/**
 1）1分钟以内 显示 : 刚刚
 2）1小时以内 显示 : X分钟前
 3）今天或者昨天 显示 : 今天 09:30 昨天 09:30
 
 今年 显示 : 09-12
 大于本年 显示 : 2013-09-09
 */
+ (NSString *)formateDate:(NSString *)dateString
{
    
    @try {
        
        // ------实例化一个NSDateFormatter对象
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];//这里的格式必须和DateString格式一致
        
        NSDate * nowDate = [NSDate date];
        
        // ------将需要转换的时间转换成 NSDate 对象
        NSDate * needFormatDate = [dateFormatter dateFromString:dateString];
        
        // ------取当前时间和转换时间两个日期对象的时间间隔
        NSTimeInterval time = [nowDate timeIntervalSinceDate:needFormatDate];
        
        // ------再然后，把间隔的秒数折算成天数和小时数：
        
        NSString *dateStr = [[NSString alloc] init];
        
        if (time<=60) {  //1分钟以内的
            
            dateStr = @"刚刚";
            
        }else if(time<=60*60){  //一个小时以内的
            
            int mins = time/60;
            dateStr = [NSString stringWithFormat:@"%d分钟前",mins];
            
        }else if(time<=60*60*24){  //在两天内的
            
            [dateFormatter setDateFormat:@"YYYY-MM-dd"];
            NSString * need_yMd = [dateFormatter stringFromDate:needFormatDate];
            NSString *now_yMd = [dateFormatter stringFromDate:nowDate];
            
            [dateFormatter setDateFormat:@"HH:mm"];
            if ([need_yMd isEqualToString:now_yMd]) {
                //在同一天
                dateStr = [NSString stringWithFormat:@"今天 %@",[dateFormatter stringFromDate:needFormatDate]];
            }else{
                //昨天
                dateStr = [NSString stringWithFormat:@"昨天 %@",[dateFormatter stringFromDate:needFormatDate]];
            }
        }else {
            
            [dateFormatter setDateFormat:@"yyyy"];
            NSString * yearStr = [dateFormatter stringFromDate:needFormatDate];
            NSString *nowYear = [dateFormatter stringFromDate:nowDate];
            
            if ([yearStr isEqualToString:nowYear]) {
                //在同一年
                [dateFormatter setDateFormat:@"MM-dd"];
                dateStr = [dateFormatter stringFromDate:needFormatDate];
            }else{
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                dateStr = [dateFormatter stringFromDate:needFormatDate];
            }
        }
        
        return dateStr;
    }
    @catch (NSException *exception) {
        return @"";
    }
    
    
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        return nil;
    }
    
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (void)showBadgeHidden:(NSString *)place hidden:(NSString *)isbool{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BADGENOTIFICATION" object:@{@"place":place,@"hidden":isbool}];
}

//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [CommonUtility getCurrentVCFrom:rootViewController];
    
    return currentVC;
}

+ (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    } else {
        // 根视图为非导航类
        
        currentVC = rootVC;
    }
    
    return currentVC;
}

+(BOOL) getFloatBool:(NSString *)string{

    if ([string isEqualToString:@"."]) {
        return NO;
    }
    if ([string isEqualToString:@"00"]) {
        return NO;
    }
    if ([string doubleValue] >= 1000000.00) {
        return NO;
    }
    NSArray *array = [string componentsSeparatedByString:@"."]; //从字符A中分隔成2个元素的数组
    if (array.count>2) {
        return NO;
    }
    if ([NSString stringWithFormat:@"%@",array[0]].length == 0) {
        return NO;
    }
    if (array.count>=2) {
        if ([NSString stringWithFormat:@"%@",array[1]].length > 2) {
            return NO;
        }
    }

    return YES;
}

+(NSString *) imageToBase64:(UIImage *)image size:(float)size{
    
    NSData *data = UIImageJPEGRepresentation(image, size);
    NSString *str =  [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    return str;
    
}

+ (BOOL) checkProxySetting {
    NSDictionary *proxySettings = (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
    NSArray *proxies = (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef _Nonnull)([NSURL URLWithString:@"https://www.baidu.com"]), (__bridge CFDictionaryRef _Nonnull)(proxySettings)));
//    NSLog(@"\n%@",proxies);
    NSDictionary *settings = proxies[0];
//    NSLog(@"%@",[settings objectForKey:(NSString *)kCFProxyHostNameKey]);
//    NSLog(@"%@",[settings objectForKey:(NSString *)kCFProxyPortNumberKey]);
//    NSLog(@"%@",[settings objectForKey:(NSString *)kCFProxyTypeKey]);
    if ([[settings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"])
    {
//        NSLog(@"没设置代理");
        return NO;
    }
    else
    {
        NSLog(@"设置了代理");
        return YES;
    }
}


+ (BOOL)isVPNOn
{
   BOOL flag = NO;
   NSString *version = [UIDevice currentDevice].systemVersion;
   // need two ways to judge this.
   if (version.doubleValue >= 9.0)
   {
       NSDictionary *dict = CFBridgingRelease(CFNetworkCopySystemProxySettings());
       NSArray *keys = [dict[@"__SCOPED__"] allKeys];
       for (NSString *key in keys) {
           if ([key rangeOfString:@"tap"].location != NSNotFound ||
               [key rangeOfString:@"tun"].location != NSNotFound ||
               [key rangeOfString:@"ipsec"].location != NSNotFound ||
               [key rangeOfString:@"ppp"].location != NSNotFound){
               flag = YES;
               break;
           }
       }
   }
   else
   {
       struct ifaddrs *interfaces = NULL;
       struct ifaddrs *temp_addr = NULL;
       int success = 0;
       
       // retrieve the current interfaces - returns 0 on success
       success = getifaddrs(&interfaces);
       if (success == 0)
       {
           // Loop through linked list of interfaces
           temp_addr = interfaces;
           while (temp_addr != NULL)
           {
               NSString *string = [NSString stringWithFormat:@"%s" , temp_addr->ifa_name];
               if ([string rangeOfString:@"tap"].location != NSNotFound ||
                   [string rangeOfString:@"tun"].location != NSNotFound ||
                   [string rangeOfString:@"ipsec"].location != NSNotFound ||
                   [string rangeOfString:@"ppp"].location != NSNotFound)
               {
                   flag = YES;
                   break;
               }
               temp_addr = temp_addr->ifa_next;
           }
       }
       
       // Free memory
       freeifaddrs(interfaces);
   }


   return flag;
}

+ (UIViewController *)findSuperViewController:(UIView *)view
{
    UIResponder *responder = view;
    // 循环获取下一个响应者,直到响应者是一个UIViewController类的一个对象为止,然后返回该对象.
    while ((responder = [responder nextResponder])) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
    }
    return nil;
}

//date时间转字符串
+(NSString *)dateToString:(NSDate *)date{
    // 实例化NSDateFormatter
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置日期格式
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];

    NSString *currentDateString = [formatter stringFromDate:date];
    
    return currentDateString;
}

//字符串转date时间
+(NSDate *)stringToDate:(NSString *)string{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];//解决8小时时间差问题
    NSDate *birthdayDate = [dateFormatter dateFromString:string];
    return birthdayDate;
}


// 判断用户是否允许接收通知
+ (BOOL)isUserNotificationEnable {
    
     dispatch_semaphore_t sem;
    sem = dispatch_semaphore_create(0);

   static BOOL isEnable = NO;
  
    
        
        if (@available(iOS 10.0, *)) {
            [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings){
                
                if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined){
                    
                    isEnable = NO;
                    NSLog(@"未选择---没有选择允许或者不允许，按不允许处理");
                }else if (settings.authorizationStatus == UNAuthorizationStatusDenied){
                    NSLog(@"未授权--不允许推送");
                    isEnable = NO;
                    
                }else if (settings.authorizationStatus == UNAuthorizationStatusAuthorized){
                    isEnable = YES;
                    NSLog(@"已授权--允许推送");
                    
                }
                dispatch_semaphore_signal(sem);

            }];
        } else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0f) { // iOS版本 >=8.0 处理逻辑
            
            UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
            isEnable = (UIUserNotificationTypeNone == setting.types) ? NO : YES;
            dispatch_semaphore_signal(sem);

        } else { // iOS版本 <8.0 处理逻辑
            UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
            isEnable = (UIRemoteNotificationTypeNone == type) ? NO : YES;
            dispatch_semaphore_signal(sem);

        }
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER); //获取通知设置的过程是异步的，这里需要等待

    
 
    return isEnable;

    
}

// 如果用户关闭了接收通知功能，该方法可以跳转到APP设置页面进行修改  iOS版本 >=8.0 处理逻辑
+ (void)goToAppSystemSetting {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([application canOpenURL:url]) {
        if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            if (@available(iOS 10.0, *)) {
                [application openURL:url options:@{} completionHandler:nil];
            } else {
                // Fallback on earlier versions
                [application openURL:url];

            }
        } else {
            [application openURL:url];
        }
    }
}

+(void)viewSnakeWithControl:(UIView *)control{//左右抖动动画
    
    
    AudioServicesPlaySystemSound(1521);
    

    CABasicAnimation* shake = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    shake.fromValue = [NSNumber numberWithFloat:-5];
    shake.toValue = [NSNumber numberWithFloat:5];
    shake.duration = 0.1;//执行时间
    shake.autoreverses = YES; //是否重复
    shake.repeatCount = 2;//次数
    [control.layer addAnimation:shake forKey:@"shakeAnimation"];
    control.alpha = 1.0;
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction animations:^{
        //self.infoLabel.alpha = 0.0; //透明度变0则消失
    } completion:nil];
    
 
}

/**
 得到一个颜色的原始值 RGBA
 
 @param originColor 传入颜色
 @return 颜色值数组
 */
+ (NSArray *)getRGBDictionaryByColor:(UIColor *)originColor {
    CGFloat r = 0,g = 0,b = 0,a = 0;
    if ([self respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [originColor getRed:&r green:&g blue:&b alpha:&a];
    }
    else {
        const CGFloat *components = CGColorGetComponents(originColor.CGColor);
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }
    return @[@(r),@(g),@(b)];
}


/**
 得到两个值的色差
 
 @param beginColor 起始颜色
 @param endColor 终止颜色
 @return 色差数组
 */
+ (NSArray *)transColorBeginColor:(UIColor *)beginColor andEndColor:(UIColor *)endColor {
    
    NSArray<NSNumber *> *beginColorArr = [self getRGBDictionaryByColor:beginColor];
    NSArray<NSNumber *> *endColorArr = [self getRGBDictionaryByColor:endColor];
    return @[@([endColorArr[0] doubleValue] - [beginColorArr[0] doubleValue]),@([endColorArr[1] doubleValue] - [beginColorArr[1] doubleValue]),@([endColorArr[2] doubleValue] - [beginColorArr[2] doubleValue])];

}

/**
 传入两个颜色和系数
 
 @param beginColor 开始颜色
 @param coe 系数（0->1）
 @param endColor 终止颜色
 @return 过度颜色
 */

+ (UIColor *)getColorWithColor:(UIColor *)beginColor andCoe:(double)coe  andEndColor:(UIColor *)endColor {
    
    NSArray *beginColorArr = [self getRGBDictionaryByColor:beginColor];
    
    NSArray *marginArray = [self transColorBeginColor:beginColor andEndColor:endColor];
    
    double red = [beginColorArr[0] doubleValue] + coe * [marginArray[0] doubleValue];
    double green = [beginColorArr[1] doubleValue] + coe * [marginArray[1] doubleValue];
    double blue = [beginColorArr[2] doubleValue] + coe * [marginArray[2] doubleValue];
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

+(void)test{
    
//    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Account Number"

}

+ (BOOL)isBlankArray:(NSArray *)array{
    
    if (array == NULL || array == nil || [array isKindOfClass:[NSNull class]] || array.count == 0){
        
        return YES;
        
    }
    
    return NO;
    
}




//获取当前的时间

+(NSString*)getCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    [formatter setDateFormat:@"YYYYMMddHHmmss"];
    
    //现在时间,你可以输出来看下是什么格式
    
    NSDate *datenow = [NSDate date];
    
    //----------将nsdate按formatter格式转成nsstring
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    NSLog(@"currentTimeString =  %@",currentTimeString);
    
    return currentTimeString;
    
}


+ (void)addShadowToView:(UIView *)theView withColor:(UIColor *)theColor {
    
    theView.layer.shadowColor = theColor.CGColor;
    theView.layer.shadowOffset = CGSizeMake(0,0);
    theView.layer.shadowOpacity = 0.5;
    theView.layer.shadowRadius = 15;
    // 单边阴影 顶边
    float shadowPathWidth = theView.layer.shadowRadius;
    CGRect shadowRect = CGRectMake(0, 0-shadowPathWidth/2.0, theView.bounds.size.width, shadowPathWidth);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:shadowRect];
    theView.layer.shadowPath = path.CGPath;
    
}



+ (NSData *)zipNSDataWithImage:(UIImage *)sourceImage {
    //进行图像尺寸的压缩
    CGSize imageSize = sourceImage.size;//取出要压缩的image尺寸
    CGFloat width = imageSize.width;    //图片宽度
    CGFloat height = imageSize.height;  //图片高度
    //1.宽高大于1280(宽高比不按照2来算，按照1来算)
    if (width>1280||height>1280) {
        if (width>height) {
            CGFloat scale = height/width;
            width = 1280;
            height = width*scale;
        }else{
            CGFloat scale = width/height;
            height = 1280;
            width = height*scale;
        }
        //2.宽大于1280高小于1280
    }else if(width>1280||height<1280){
        CGFloat scale = height/width;
        width = 1280;
        height = width*scale;
        //3.宽小于1280高大于1280
    }else if(width<1280||height>1280){
        CGFloat scale = width/height;
        height = 1280;
        width = height*scale;
        //4.宽高都小于1280
    }else{
    }
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [sourceImage drawInRect:CGRectMake(0,0,width,height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    //进行图像的画面质量压缩
    NSData *data=UIImageJPEGRepresentation(newImage, 1.0);
    if (data.length>100*1024) {
        if (data.length>1024*1024) {//1M以及以上
            data=UIImageJPEGRepresentation(newImage, 0.7);
        }else if (data.length>512*1024) {//0.5M-1M
            data=UIImageJPEGRepresentation(newImage, 0.8);
        }else if (data.length>200*1024) {
            //0.25M-0.5M
            data=UIImageJPEGRepresentation(newImage, 0.9);
        }
    }
    return data;
}
@end
