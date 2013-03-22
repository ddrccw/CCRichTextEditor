//
//  CCCircleProgressView.m
//  CCRichTextEditor
//
//  Created by ddrccw on 13-3-20.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import "CCCircleProgressView.h"

#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) / M_PI * 180.0)

static const UInt8 kShadowLineWidth = 1;
static const UInt8 kProgressBarInset = 1;
static const float kStripePaddingDegree = 5;
static const float kStripeDegree = 5;


/*    θ=endAngle   a=b=offset
 *    (x-a)^2 + (y-b)^2 = r^2
 *    x=r*cosθ+a, y=r*sinθ+b
 */
static CGPoint GetPointOnCircle(float offset, float radius, float angleInDegree) {
  CGPoint p = CGPointZero;
  float radian = DEGREES_TO_RADIANS(angleInDegree);
  float cos = cosf(radian);
  float sin = sinf(radian);
  
  p.x = offset + radius * cos;
  p.y = offset + radius * sin;
  
  return p;
}

@interface CCCircleProgressView () {
  float progressOutRadius_;
  float progressInRadius_;
  float progressBarOutRadius_;
  float progressBarInRadius_;
  CGPoint progressCenter_;
  float progressAngle_;
  UIBezierPath *progressBarPath_;
}
@end

@implementation CCCircleProgressView

- (void)dealloc {
  [_progressBarBackgroundColor release];
  [super dealloc];
}

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//      self.backgroundColor = [UIColor clearColor];
//      self.progressBarBackgroundColor = [UIColor colorWithRed:0.0980f
//                                                        green:0.1137f
//                                                         blue:0.1294f
//                                                        alpha:1.0f];
//      progressOutRadius_ = self.frame.size.height / 2;
//      progressBarOutRadius_ = progressOutRadius_ - kProgressBarInset;
//    }
//    return self;
//}

- (void)awakeFromNib {
  self.backgroundColor = [UIColor clearColor];
  self.progressBarBackgroundColor = [UIColor colorWithRed:0.0980f  //25,29,33
                                                    green:0.1137f
                                                     blue:0.1294f
                                                    alpha:1.0f];
  progressOutRadius_ = self.frame.size.height / 2;
  progressBarOutRadius_ = progressOutRadius_ - kProgressBarInset;
  progressCenter_ = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
  self.progressWidth = 5;
}

- (void)setProgressWidth:(CGFloat)progressWidth {
  if (_progressWidth != progressWidth) {
    _progressWidth = progressWidth;
    progressInRadius_ = self.frame.size.height / 2 - self.progressWidth;
    progressBarInRadius_ = progressInRadius_;
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
    [self drawStripesWithRect:rect];
    [self drawGlossWithRect:rect];
  }
}

- (void)drawBackgroundWithRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  
  CGMutablePathRef paths = CGPathCreateMutable();
  float endAngle = 1.5 * M_PI;
  // Draw the white shadow
  [[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.2] set];
  UIBezierPath *outerFrame = [UIBezierPath bezierPathWithArcCenter:progressCenter_
                                                            radius:progressOutRadius_
                                                        startAngle:-M_PI_2
                                                          endAngle:endAngle
                                                         clockwise:YES];
  [outerFrame stroke];
  CGPathAddPath(paths, NULL, [outerFrame CGPath]);
  UIBezierPath *innerShadow = [UIBezierPath bezierPathWithArcCenter:progressCenter_
                                                             radius:progressInRadius_ - kShadowLineWidth
                                                         startAngle:-M_PI_2
                                                           endAngle:endAngle
                                                          clockwise:YES];
  [innerShadow stroke];
  UIBezierPath *innerFrame = [UIBezierPath bezierPathWithArcCenter:progressCenter_
                                                            radius:progressInRadius_
                                                        startAngle:-M_PI_2
                                                          endAngle:endAngle
                                                         clockwise:YES];
  CGPathAddPath(paths, NULL, [innerFrame CGPath]);
  // Draw the track
  [self.progressBarBackgroundColor set];
  CGContextAddPath(context, paths);
  CGContextEOFillPath(context);
  CGPathRelease(paths);
  
  CGContextRestoreGState(context);
}

- (void)drawProgressBarWithRect:(CGRect)rect {
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGColorSpaceRef colorSpace  = CGColorSpaceCreateDeviceRGB();
  
  CGContextSaveGState(context);
  assert(CGContextIsPathEmpty(context));
  
  float startAngle = -M_PI_2;
  float endAngle = startAngle + self.progress * 2 * M_PI;
  progressAngle_ = self.progress * 360 - 90;
  UIBezierPath *path = [UIBezierPath bezierPath];
  [path moveToPoint:CGPointMake(progressCenter_.x, kProgressBarInset)];
  [path addLineToPoint:CGPointMake(progressCenter_.x, self.progressWidth)];
  
  [path addArcWithCenter:progressCenter_
                  radius:progressBarInRadius_
              startAngle:startAngle
                endAngle:endAngle clockwise:YES];
  
  float capRadius = (self.progressWidth - kProgressBarInset) / 2;
  float arcRadius = progressBarInRadius_ + capRadius;
  CGPoint p = GetPointOnCircle(progressCenter_.x, arcRadius, progressAngle_);
  [path addArcWithCenter:p
                  radius:capRadius
              startAngle:0
                endAngle:2 * M_PI
               clockwise:NO];
  
  //  NSLog(@"ox=%f,oy=%f, ix=%f, iy=%f", outX, outY, inX, inY);
  
  [path addArcWithCenter:progressCenter_
                  radius:progressBarOutRadius_
              startAngle:endAngle
                endAngle:startAngle
               clockwise:NO];
  
  CGContextAddPath(context, [path CGPath]);
  progressBarPath_ = [path retain];
  CGContextClip(context);
  
  size_t num_locations = 2;
  CGFloat locations[] = {0.0, 1.0};
  CGFloat progressComponents[] = {0.2824f, 0.1961f, 0.4431f, 1.000f,
    0.7569f, 0.2706f, 0.7608f, 1.000f};
  
  CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, progressComponents, locations, num_locations);
  CGContextDrawRadialGradient(context, gradient,
                              progressCenter_, progressBarInRadius_,
                              progressCenter_, progressBarOutRadius_,
                              0);
  CGGradientRelease(gradient);
  
  CGContextRestoreGState(context);
  CGColorSpaceRelease(colorSpace);
}

- (void)drawStripesWithRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGColorSpaceRef colorSpace  = CGColorSpaceCreateDeviceRGB();
  
  CGContextSaveGState(context);
  assert(CGContextIsPathEmpty(context));
  
  CGContextAddPath(context, [progressBarPath_ CGPath]);
  CGContextClip(context);
  
  CGContextSaveGState(context);
  assert(CGContextIsPathEmpty(context));
  {
    static const UInt8 kInsetAngle = 10;
    int numberOfStrips = abs(progressAngle_ + 90 + kInsetAngle) / (kStripePaddingDegree + kStripeDegree) + 1;
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint p = CGPointZero;
    float offset = progressCenter_.x;
    float endAngle = progressAngle_ + kInsetAngle;
    float startAngle = endAngle - kStripeDegree;
    float startAngleInRadian = DEGREES_TO_RADIANS(startAngle);
    float endAngleInRadian = DEGREES_TO_RADIANS(endAngle);
    for (int i = 0; i < numberOfStrips; ++i) {
      UIBezierPath *stripe = [UIBezierPath bezierPath];
      p = GetPointOnCircle(offset, progressBarOutRadius_, startAngle);
      [stripe moveToPoint:p];
      p = GetPointOnCircle(offset, progressBarInRadius_, startAngle);
      [stripe addLineToPoint:p];
      
      [stripe addArcWithCenter:progressCenter_
                        radius:progressBarInRadius_
                    startAngle:startAngleInRadian
                      endAngle:endAngleInRadian
                     clockwise:YES];
      
      p = GetPointOnCircle(offset, progressBarOutRadius_, endAngle);
      [stripe addLineToPoint:p];
      [stripe addArcWithCenter:progressCenter_
                        radius:progressBarOutRadius_
                    startAngle:endAngleInRadian
                      endAngle:startAngleInRadian
                     clockwise:NO];
      
      [path appendPath:stripe];
      
      startAngle -= (kStripeDegree + kStripePaddingDegree);
      endAngle = startAngle + kStripeDegree;
      startAngleInRadian = DEGREES_TO_RADIANS(startAngle);
      endAngleInRadian = DEGREES_TO_RADIANS(endAngle);
    }
    
    CGContextAddPath(context, [path CGPath]);
    CGContextClip(context);
    
    const CGFloat stripesColorComponents[] = { 0.0f, 0.0f, 0.0f, 0.28f };
    CGColorRef stripesColor = CGColorCreate(colorSpace, stripesColorComponents);
    CGContextSetFillColorWithColor(context, stripesColor);
    CGContextFillRect(context, rect);
    CGColorRelease(stripesColor);
  }
  CGContextRestoreGState(context);
  [progressBarPath_ release];
  
  CGContextRestoreGState(context);
  CGColorSpaceRelease(colorSpace);
}

- (void)drawGlossWithRect:(CGRect)rect {
  
}
@end

















