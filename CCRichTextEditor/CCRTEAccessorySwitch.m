//
//  CCRTEAccessorySwitch.m
//  CCRichTextEditor
//
//  Created by chenche on 13-3-1.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import "CCRTEAccessorySwitch.h"
#import <CoreText/CoreText.h>

@interface CCRTEAccessorySwitch ()
@property (retain, nonatomic) UIImage *backgroundImage;
@property (retain, nonatomic) UIImage *selectedImage;
@property (retain, nonatomic) UIImageView *backgroundImageView;
@property (retain, nonatomic) NSAttributedString *title;
@property (retain, nonatomic) NSAttributedString *selectedTitle;
@property (retain, nonatomic) CATextLayer *titleTextLayer;
@end

@implementation CCRTEAccessorySwitch

- (void)dealloc {
  [_backgroundImage release];
  [_selectedImage release];
  [_backgroundImageView release];
  [_title release];
  [_selectedTitle release];
  [_titleTextLayer release];
  [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setTitle:(NSAttributedString *)title
   selectedTitle:(NSAttributedString *)selectedTitle
 backgroundImage:(UIImage *)backgroundImage
   selectedImage:(UIImage *)selectedImage
{
  self.backgroundImage = backgroundImage;
  self.selectedImage = selectedImage;
  if (!_backgroundImageView) {
    _backgroundImageView = [[UIImageView alloc] initWithImage:self.backgroundImage];
    _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |
                                            UIViewAutoresizingFlexibleLeftMargin |
                                            UIViewAutoresizingFlexibleTopMargin |
                                            UIViewAutoresizingFlexibleRightMargin |
                                            UIViewAutoresizingFlexibleHeight |
                                            UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.backgroundImageView];
  }
  
  self.title = title;
  self.selectedTitle = selectedTitle;
  if (title) {
    self.titleTextLayer = [CATextLayer layer];
    self.titleTextLayer.wrapped = NO;
    self.titleTextLayer.foregroundColor = [[UIColor blackColor] CGColor];
    self.titleTextLayer.alignmentMode = kCAAlignmentCenter;
    [self setTitleTextLayerWithAttributedString:title];
    [self.layer addSublayer:self.titleTextLayer];
  }
}

- (void)setSelected:(BOOL)selected {
  [super setSelected:selected];
  if (selected) {
    self.backgroundImageView.image = self.selectedImage;
    [self setTitleTextLayerWithAttributedString:self.selectedTitle];
  }
  else {
    self.backgroundImageView.image = self.backgroundImage;
    [self setTitleTextLayerWithAttributedString:self.title];
  }
}

- (CGFloat)boundingHeightForWidth:(CGFloat)inWidth withAttributedString:(NSAttributedString *)attributedString {
  CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
  CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [attributedString length]), NULL, CGSizeMake(inWidth, CGFLOAT_MAX), NULL);
  CFRelease(framesetter);
  return suggestedSize.height;
}

- (void)setTitleTextLayerWithAttributedString:(NSAttributedString *)attributedString {
  int height = [self boundingHeightForWidth:self.frame.size.width withAttributedString:self.title];
  self.titleTextLayer.string = attributedString;
  int kFixTextOffSet = 3;
  self.titleTextLayer.frame = CGRectMake(0,
                                         self.frame.size.height / 2 - height / 2 + kFixTextOffSet,
                                         self.frame.size.width,
                                         height);

}

@end
