//
//  CCCircleProgressView.m
//  CCRichTextEditor
//
//  Created by chenche on 13-3-20.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import "CCCircleProgressView.h"

static const UInt8 kShadowLineWidth = 1;
static const UInt8 kProgressBarInset = 1;

@interface CCCircleProgressView () {
  float progressOutRadius_;
  float progressInRadius_;
  float progressBarOutRadius_;
  float progerssBarInRadius_;
}
@property (retain, nonatomic) UIColor *progressBarBackgroundColor;
@end

@implementation CCCircleProgressView

- (void)dealloc {
  [_progressBarBackgroundColor release];
  [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      self.backgroundColor = [UIColor clearColor];
      self.progressBarBackgroundColor = [UIColor colorWithRed:0.0980f
                                                        green:0.1137f
                                                         blue:0.1294f
                                                        alpha:1.0f];
      progressOutRadius_ = self.frame.size.height / 2;
      progressBarOutRadius_ = progressOutRadius_ - kProgressBarInset;
    }
    return self;
}

- (void)setProgressWidth:(CGFloat)progressWidth {
  if (_progressWidth != progressWidth) {
    _progressWidth = progressWidth;
    progressInRadius_ = self.frame.size.height / 2 - self.progressWidth;
    progerssBarInRadius_ = progressInRadius_;
  }
}

- (void)setProgress:(CGFloat)progress {
  if (_progress != progress) {
    _progress = progress;
    [self setNeedsDisplay];
  }
}

- (void)drawRect:(CGRect)rect
{
  [self drawBackgroundWithRect:rect];
  if (self.progress > 0) {
    [self drawProgressBarWithRect:rect];
  }
}

- (void)drawBackgroundWithRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  
  CGMutablePathRef paths = CGPathCreateMutable();
  float endAngle = 1.5 * M_PI_2;
  // Draw the white shadow
  [[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.2] set];
  UIBezierPath *outerFrame = [UIBezierPath bezierPathWithArcCenter:self.center
                                                        radius:progressOutRadius_
                                                    startAngle:-M_PI_2
                                                      endAngle:endAngle
                                                     clockwise:YES];
  [outerFrame stroke];
  CGPathAddPath(paths, NULL, [outerFrame CGPath]);
  UIBezierPath *innerShadow = [UIBezierPath bezierPathWithArcCenter:self.center
                                                             radius:progressInRadius_ - kShadowLineWidth
                                                         startAngle:-M_PI_2
                                                           endAngle:endAngle
                                                          clockwise:YES];
  [innerShadow stroke];
  UIBezierPath *innerFrame = [UIBezierPath bezierPathWithArcCenter:self.center
                                                            radius:progressInRadius_
                                                        startAngle:-M_PI_2
                                                          endAngle:endAngle
                                                         clockwise:YES];
  CGPathAddPath(paths, NULL, [innerFrame CGPath]);
  // Draw the track
  [self.progressBarBackgroundColor set];
  CGContextEOFillPath(context);
  CGPathRelease(paths);
  
  CGContextRestoreGState(context);
}

- (void)drawProgressBarWithRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGColorSpaceRef colorSpace  = CGColorSpaceCreateDeviceRGB();
  CGContextSaveGState(context);

  float endAngle = -M_PI_2 + self.progress * 2 * M_PI;
  CGMutablePathRef paths = CGPathCreateMutable();
  CGContextMoveToPoint(context, self.bounds.size.width / 2, progressBarOutRadius_);
  CGPathAddLineToPoint(paths, NULL, self.bounds.size.width / 2, progerssBarInRadius_);
  
  UIBezierPath *innerFrame = [UIBezierPath bezierPathWithArcCenter:self.center
                                                            radius:progerssBarInRadius_
                                                        startAngle:-M_PI_2
                                                          endAngle:endAngle
                                                         clockwise:YES];
  CGPathAddPath(paths, NULL, [innerFrame CGPath]);

  /*    θ=endAngle
   *    [-pi/2, 0]   x=r+cosθ, y=r-sinθ
   *    [0, pi/2]    x=r+cosθ, y=r+sinθ
   *    [pi/2, pi]   x=r-cos(pi-θ)=r+cosθ, y=r+sin(pi-θ)=r+sinθ;
   *    [pi, 3*pi/2] x=r-cos(θ-pi)=r+cosθ, y=r-sin(θ-pi)=r+sinθ;
   */
  
  float capRadius = (self.progressWidth - kProgressBarInset) / 2;
  float outX = 0;
  float outY = 0;
  float inX = 0;
  float inY = 0;
  float cos = cosf(endAngle);
  float sin = sinf(endAngle);
  if (self.progress <= .25) {
    outX = progressBarOutRadius_ + cos;
    outY = progressBarOutRadius_ - sin;
    inX = progerssBarInRadius_ + cos;
    inY = progerssBarInRadius_ - sin;
  }
  else {
    outX = progressBarOutRadius_ + cos;
    outY = progressBarOutRadius_ + sin;
    inX = progerssBarInRadius_ + cos;
    inY = progerssBarInRadius_ + sin;
  }
  
  CGPathAddArcToPoint(paths, NULL, inX, inY, outX, outY, capRadius);
  
  UIBezierPath *outerFrame = [UIBezierPath bezierPathWithArcCenter:self.center
                                                            radius:progressBarOutRadius_
                                                        startAngle:endAngle
                                                          endAngle:-M_PI_2
                                                         clockwise:NO];
  CGPathAddPath(paths, NULL, [outerFrame CGPath]);
  CGContextClip(context);
  
  size_t num_locations = 2;
  CGFloat locations[] = {0.0, 1.0};
  CGFloat progressComponents[] = {0.2824f, 0.1961f, 0.4431f, 1.000f,
                                  0.7569f, 0.2706f, 0.7608f, 1.000f};
  
  CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, progressComponents, locations, num_locations);
  CGContextDrawRadialGradient(context, gradient,
                              self.center, progerssBarInRadius_,
                              self.center, progressBarOutRadius_,
                              kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
  CGGradientRelease(gradient);
  CGPathRelease(paths);
  CGContextRestoreGState(context);
  CGColorSpaceRelease(colorSpace);
}

@end
