//
//  UIView+Layer.m
//  xinyuancar
//
//  Created by 博识iOS One on 2020/11/20.
//

#import "UIView+Layer.h"

@implementation UIView (Layer)

#pragma mark - storyboard 属性
// cornerRadius
-(void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
}

- (CGFloat)cornerRadius
{
    return self.layer.cornerRadius;
}

// borderColor
-(void)setBorderColor:(UIColor *)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
}

- (UIColor *)borderColor
{
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

// borderWidth
-(void)setBorderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
}

- (CGFloat)borderWidth
{
    return self.layer.borderWidth;
}

// shadowColor
- (void)setShadowColor:(UIColor *)shadowColor
{
    self.layer.shadowColor = shadowColor.CGColor;
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowOffset = CGSizeMake(0, 0);
}

- (UIColor *)shadowColor
{
    return [UIColor colorWithCGColor:self.layer.shadowColor];
}

-(void)setMasksToBounds:(BOOL)masksToBounds
{
    self.layer.masksToBounds = true;
}

- (BOOL)masksToBounds
{
    return self.layer.masksToBounds;
}

@end
