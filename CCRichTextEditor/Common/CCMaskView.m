//
//  CCMaskView.m
//  CCRichTextEditor
//
//  Created by ddrccw on 13-3-12.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import "CCMaskView.h"

@interface CCMaskView ()
@end

@implementation CCMaskView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Transparent background
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    // Make it invisible for now
    self.alpha = 0.0f;
    self.opacity = 0.95f;
    self.autoresizingMask = UIViewAutoResizingFlexibleAll;
    UIControl *maskControl = [[UIControl alloc] initWithFrame:self.bounds];
    [maskControl addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:maskControl];
    [maskControl release];
  }
  return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
  CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);
  
	if (self.shouldDimBackground) {
		//Gradient colours
		size_t gradLocationsNum = 2;
		CGFloat gradLocations[2] = {0.1, 0.9};
		CGFloat gradColors[8] = {68.0/255.0, 68.0/255.0, 68.0/255.0, 1.0,
                             32.0/255.0, 36.0/255.0, 41.0/255.0, 1.0};
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocationsNum);
		CGColorSpaceRelease(colorSpace);
		//Gradient center
		CGPoint gradCenter= CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
		//Gradient radius
		float gradRadius = MIN(self.bounds.size.width , self.bounds.size.height) ;
		//Gradient draw
		CGContextDrawRadialGradient (context, gradient, gradCenter,
                                 0, gradCenter, gradRadius,
                                 kCGGradientDrawsAfterEndLocation);
		CGGradientRelease(gradient);
	}
  
  UIGraphicsPopContext();
  
  // Blend the noize texture to the background
//  UIImage *noizeImage = [UIImage imageNamed:@"noise"];
//  CGSize textureSize                  = [noizeImage size];
//  CGContextDrawTiledImage(context, CGRectMake(0, 0, textureSize.width, textureSize.height), noizeImage.CGImage);

}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.centerView.center = self.center;
}

- (void)dismiss:(id)sender {
  if ([self.delegate respondsToSelector:@selector(maskViewShouldDismiss:)]) {
    BOOL status = [self.delegate maskViewShouldDismiss:self];
    if (!status) return;
  }
  
  if ([self.delegate respondsToSelector:@selector(maskViewWillDismiss:)]) {
    [self.delegate maskViewWillDismiss:self];
  }
  [self hide];
}

- (void)setCenterView:(UIView *)centerView {
  if (_centerView != centerView) {
    [_centerView removeFromSuperview];
    [_centerView release];
    _centerView = [centerView retain];
    [self addSubview:_centerView];
    _centerView.center = self.center;
  }
}

- (void)hide {
  CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
  opacityAnimation.fromValue = @(self.opacity);
  opacityAnimation.toValue = @(0);
  opacityAnimation.duration = .3f;
  [self.layer addAnimation:opacityAnimation forKey:@"dismissMask"];
  self.alpha = 0;
}

- (void)show:(CGFloat)animationDuration {
  CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
  opacityAnimation.fromValue = @(0);
  opacityAnimation.toValue = @(self.opacity);
  opacityAnimation.duration = animationDuration;
  [self.layer addAnimation:opacityAnimation forKey:@"showMask"];
  [self.superview bringSubviewToFront:self];
  self.alpha = self.opacity;
}

@end
