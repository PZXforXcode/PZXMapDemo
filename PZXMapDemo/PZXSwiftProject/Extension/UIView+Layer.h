//
//  UIView+Layer.h
//  xinyuancar
//
//  Created by 博识iOS One on 2020/11/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Layer)

#pragma mark - storyboard 属性
@property(nonatomic,assign) IBInspectable CGFloat cornerRadius;
@property(nonatomic,assign) IBInspectable CGFloat borderWidth;
@property(nonatomic,assign) IBInspectable UIColor *borderColor;
@property(nonatomic,assign) IBInspectable UIColor *shadowColor;
@property(nonatomic,assign) IBInspectable BOOL masksToBounds;

- (void)drawLineOfDashByCAShapeLayerWithLineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor isHorizontalLine:(BOOL)isHorizonal;

@end

NS_ASSUME_NONNULL_END
