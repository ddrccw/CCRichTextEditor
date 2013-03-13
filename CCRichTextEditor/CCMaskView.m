//
//  CCMaskView.m
//  CCRichTextEditor
//
//  Created by chenche on 13-3-12.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import "CCMaskView.h"

@implementation CCMaskView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Transparent background
    self.opaque = NO;
    self.backgroundColor = [UIColor whiteColor];
    // Make it invisible for now
    self.alpha = 0.0f;
    self.opacity = 0.8f;
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
		CGFloat gradLocations[2] = {0.0f, 1.0f};
		CGFloat gradColors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
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
  
  // Set background rect color
  if (self.color) {
    CGContextSetFillColorWithColor(context, self.color.CGColor);
  }
  else {
    CGContextSetGrayFillColor(context, 0.0f, self.opacity);
  }
  
  CGContextFillRect(context, self.bounds);
  UIGraphicsPopContext();
}

- (void)dismiss:(id)sender {
  if ([self.delegate respondsToSelector:@selector(maskViewWillDismiss:)]) {
    [self.delegate maskViewWillDismiss:self];
  }
}

@end
