//
//  CCRTEDocumentFragmentStatus.m
//  CCRichTextEditor
//
//  Created by ddrccw on 13-3-7.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import "CCRTEDocumentFragmentStatus.h"

@interface CCRTEDocumentFragmentStatus ()
{
  NSString *highlightColorString_;
}
@property (retain, nonatomic) UIColor *highlightColor;
@end

@implementation CCRTEDocumentFragmentStatus

- (void)dealloc {
  [highlightColorString_ release];
  [_fontName release];
  [_fontColor release];
  [super dealloc];
}

- (id)init {
  if (self = [super init]) {
    _highlightColor = [[UIColor colorWithRed:0.9608
                                       green:0.9412
                                        blue:0.8000
                                       alpha:0] retain];
  }
  return self;
}

- (UIFont *)font {
  return [UIFont fontWithName:self.fontName size:15];
}

- (NSString *)fontColorString {    //不能包含小数
  return [[self class] rgbColorStringOfColor:self.fontColor];
}

- (void)setFontColorString:(NSString *)fontColorString {   //format rgb(red, green, blue)
  if (!fontColorString) {
    self.fontColor = [UIColor blackColor];
  }
  
  const char *target = [fontColorString UTF8String];
  float r = 0;
  float g = 0;
  float b = 0;
  int ret = sscanf(target, "rgb(%f, %f, %f)", &r, &g, &b);
  
  if (EOF != ret) {
    if (self.fontColor) {
      const float *rgb = CGColorGetComponents(self.fontColor.CGColor);
      if (rgb[0] != (r / 255) || rgb[1] != (g / 255) || rgb[2] != (b / 255)) {
        self.fontColor = [UIColor colorWithRed:(r / 255) green:(g / 255) blue:(b / 255) alpha:1];
      }
    }
  }
  else {
    self.fontColor = [UIColor blackColor];
  }
}

- (NSString *)highlightColorString {    //不能包含小数
  if (!highlightColorString_) {
    highlightColorString_ = [[[self class] rgbColorStringOfColor:self.highlightColor] copy];
  }
  return highlightColorString_;
}

+ (NSString *)rgbColorStringOfColor:(UIColor *)aColor {
  float rgb[4] = {0};
  [aColor getRed:&rgb[0] green:&rgb[1] blue:&rgb[2] alpha:&rgb[3]];
  return [NSString stringWithFormat:@"rgb(%.0f, %.0f, %.0f)", rgb[0] * 255, rgb[1] * 255, rgb[2] * 255];
}

@end
