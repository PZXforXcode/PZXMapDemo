//
//  CommonUtility.h
//  SearchV3Demo
//
//  Created by songjian on 13-8-22.
//  Copyright (c) 2013年 songjian. All rights reserved.
//  PHONE_NUMBER 手机号

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface CommonUtility : NSObject

+ (BOOL)checkNetWorkingState;//判断连接

+ (NSString*) userHeaderImageUrl:(NSString*)ids;

+ (void) callTelphone:(NSString*)number;
+ (void) sendMessage:(NSString*)number;

+ (NSString*) getArticalUrl:(NSString*)ids type:(NSString *)type;

+ (NSString*) convertDateToString:(NSDate*)date;

+ (NSString*) convertDateToString:(NSDate*)data withFormat:(NSString*)formater;

+ (id) fetchDataFromArrayByIndex:(NSArray*)data withIndex:(NSInteger)index;

+ (NSString*)versions;
+ (NSString*)builds;
+ (NSString*)getUUID;
+ (NSString *)getIPAddress;

#pragma mark 外网ip
+(NSString *)deviceWANIPAdress;

+ (BOOL) validateParams:(NSString*)params withRegular:(NSString*)regular;
+ (BOOL) validateNumber:(NSString*)params;
+ (BOOL) validateSizeForm:(NSString*)params;
+ (BOOL) validatePhoneNumber:(NSString*)param;
+(void)showShado:(UIView *)view;

/**
 * 开始到结束的时间差
 */
+ (NSDictionary *)getBabyDetailAge:(NSString *)date;

/**
 *  是否为同一天
 */ 
+ (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2;

#pragma mark 倒计时
+(void)startTime:(UIButton *)sender;

#pragma mark 登录成功
+(void)loginSuccess:(id)response;

#pragma mark 保持原来的长宽比，生成一个缩略图
+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize;

#pragma mark 裁剪出的图片尺寸按照size的尺寸，但图片不拉伸，但多余部分会被裁减掉
+ (UIImage *)thumbnailWithImage:(UIImage *)originalImage size:(CGSize)size;

#pragma mark 简单粗暴地图片裁剪方法 裁剪出的图片尺寸按照size的尺寸，但图片可能会被拉伸
+ (UIImage *)thumbnailWithImageLa:(UIImage *)originalImage size:(CGSize)size;

#pragma mark 保存个人资料
+(void)saveUserDefaultData:(NSString *)value key:(NSString *)key;


/**
 调起分享页面

 @param thumImage 缩略图（UIImage或者NSData类型，或者image_url）
 @param title 标题                
 @param descr 描述
 @param webpageUr 网页的url地址
 @param currentViewController 用于弹出类似邮件分享、短信分享等这样的系统页面
 @param completion 回调
 */
//+(void)showShareUI:(id)thumImage
//             title:(NSString *)title
//             descr:(NSString *)descr
//        webpageUrl:(NSString *)webpageUr
//currentViewController:(id)currentViewController
//        completion:(UMSocialRequestCompletionHandler)completion;

#pragma mark 时间戳转时间
+ (NSString *)timeWithTimeIntervalString:(NSString *)timeString;
+ (NSString *)timeWithMonthDay:(NSString *)timeString;
+ (NSString *)formateDate:(NSString *)dateString;
//json字符串转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
+ (NSString *) sha1:(NSString *)input;


#pragma mark 环信自动登陆
+(void)EMClientAutoLogin;

/**
 订单和消息红点显示隐藏

 @param place 订单：@"order"     消息:@"message"
 @param isbool 是否隐藏(NSSring  1 or 0)
 */
+ (void)showBadgeHidden:(NSString *)place hidden:(NSString *)isbool;

//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC;
+ (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC;

//限制输入数字以及小数后2位
+(BOOL) getFloatBool:(NSString *)string;

/**图片转base64*/
+(NSString *) imageToBase64:(UIImage *)image size:(float)size;

//是否设置代理
+ (BOOL) checkProxySetting;

//根据view得到当前viewcontroller
+ (UIViewController *)findSuperViewController:(UIView *)view;


//date时间转字符串
+(NSString *)dateToString:(NSDate *)date;

//字符串转date时间
+(NSDate *)stringToDate:(NSString *)string;

//设置按钮样式
+(void)setLoginButtonStyleWith:( NSInteger)style
                    WithButton:(UIButton *)sender;

// 判断用户是否允许接收通知
+ (BOOL)isUserNotificationEnable;
// 如果用户关闭了接收通知功能，该方法可以跳转到APP设置页面进行修改  iOS版本 >=8.0 处理逻辑
+ (void)goToAppSystemSetting;

/**
 左右抖动动画

 @param control 生效view
 */
+(void)viewSnakeWithControl:(UIView *)control;


/**
 得到一个颜色的原始值 RGBA
 
 @param originColor 传入颜色
 @return 颜色值数组
 */
+ (NSArray *)getRGBDictionaryByColor:(UIColor *)originColor;

/**
 得到两个值的色差
 
 @param beginColor 起始颜色
 @param endColor 终止颜色
 @return 色差数组
 */
+ (NSArray *)transColorBeginColor:(UIColor *)beginColor andEndColor:(UIColor *)endColor;

/**
 传入两个颜色和系数
 
 @param beginColor 开始颜色
 @param coe 系数（0->1）
 @param endColor 终止颜色
 @return 过度颜色
 */

+ (UIColor *)getColorWithColor:(UIColor *)beginColor andCoe:(double)coe  andEndColor:(UIColor *)endColor;

/**
 判断数组非空

 @param array 数组
 @return 是否为空 yes为空
 */
+ (BOOL)isBlankArray:(NSArray *)array;


/**
 上传oss

 @param data data文件
 @param objStr w目标

 */
//+(void)upToOssWithData:(NSData *)data WithObjectKey:(NSString *)objStr WithCallBack:(void (^)( BOOL success))callback;


/**
 获取当前时间

 @return s时间字符串
 */
+(NSString*)getCurrentTimes;


/**
 添加顶边阴影

 @param theView s添加阴影view
 @param theColor 颜色
 */
+ (void)addShadowToView:(UIView *)theView withColor:(UIColor *)theColor;

/// 获取视频第一帧
/// @param path 视频地址
+ (UIImage*) getVideoPreViewImage:(NSURL *)path;


/// 是否打开vpn
+ (BOOL)isVPNOn;

//压缩图
+ (NSData *)zipNSDataWithImage:(UIImage *)sourceImage;
@end
