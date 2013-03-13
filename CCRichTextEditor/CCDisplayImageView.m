//
//  CCDisplayImageView.m
//  CCRichTextEditor
//
//  Created by chenche on 13-3-12.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import "CCDisplayImageView.h"

static const UInt8 kPadding = 5;
static const UInt8 kDefaultOffset = 0;

@interface CCDisplayImageView ()
{
  CGSize closeBtnSize_;
}
@property (retain, nonatomic) UIView *containerView;
@property (retain, nonatomic) UIView *imageFrameView;
@property (retain, nonatomic) UIImageView *imageDisplayView;
@property (retain, nonatomic) UIButton *closeBtn;
@end

@implementation CCDisplayImageView

- (void)dealloc {
  [_containerView release];
  [_imageFrameView release];
  [_imageDisplayView release];
  [_closeBtn release];
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

- (id)initWithImage:(UIImage *)image
      maxImageWidth:(CGFloat)maxImageWidth
     maxImageHeight:(CGFloat)maxImageHeight
{
  if (self = [super init]) {
    _containerView = [[UIView alloc] init];
    _containerView.backgroundColor = [UIColor clearColor];
    [self addSubview:_containerView];
    _imageFrameView = [[UIView alloc] init];
    _imageFrameView.backgroundColor = [UIColor whiteColor];
    _imageFrameView.layer.cornerRadius = 8.0f;
    _imageFrameView.layer.borderWidth = 3.0f;
    _imageFrameView.layer.borderColor = [UIColor blackColor].CGColor;
    [self.containerView addSubview:_imageFrameView];
    _imageDisplayView = [[UIImageView alloc] init];
    [self.imageFrameView addSubview:_imageDisplayView];
    UIImage *closeBtnImg = [UIImage imageNamed:@"closeBtn"];
    closeBtnSize_ = closeBtnImg.size;
    CGRect rect = CGRectMake(0, 0, closeBtnSize_.width, closeBtnSize_.height);
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeBtn.bounds = rect;
    [_closeBtn setImage:closeBtnImg forState:UIControlStateNormal];
    [self.containerView addSubview:_closeBtn];
    [self.closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    self.backgroundColor = [UIColor clearColor];
    
    self.maxImageWidth = maxImageWidth;
    self.maxImageHeight = maxImageHeight;
    [self sizeToFitImage:image];
  }
  return self;
}


- (void)sizeToFitImage:(UIImage *)aImage {
  CGRect rect = CGRectZero;
  rect.origin.x = kPadding;
  rect.origin.y = kPadding;
  rect.size.width = aImage.size.width;
  rect.size.height = aImage.size.height;
  
  float scale = 0;
  if (rect.size.width > rect.size.height) {
    if (rect.size.width > self.maxImageWidth) {
      scale = self.maxImageWidth / rect.size.width;
      rect.size.width = self.maxImageWidth;
      rect.size.height *= scale;
    }
  }
  else {
    if (rect.size.height > self.maxImageHeight) {
      scale = self.maxImageHeight / rect.size.height;
      rect.size.height = self.maxImageHeight;
      rect.size.width *= scale;
    }
  }
  self.imageDisplayView.frame = rect;
  self.imageDisplayView.image = aImage;

  rect.origin.x = 0;
  rect.origin.y = closeBtnSize_.height / 2;
  rect.size.width = self.imageDisplayView.frame.size.width + kPadding * 2;
  rect.size.height = self.imageDisplayView.frame.size.height + kPadding * 2;
  self.imageFrameView.frame = rect;
  
  UInt16 x = kDefaultOffset;
  UInt16 y = kDefaultOffset;
  UInt16 width = self.imageDisplayView.frame.size.width + closeBtnSize_.width / 2 + kPadding * 2;
  UInt16 height = self.imageDisplayView.frame.size.height + closeBtnSize_.height / 2 + kPadding * 2;
  rect = CGRectMake(x, y, width, height);
  self.containerView.frame = rect;

  _closeBtn.center = CGPointMake(self.containerView.bounds.size.width - closeBtnSize_.width / 2,
                                 closeBtnSize_.height / 2);
  
  rect.origin = CGPointZero;
  rect.size.width = self.containerView.bounds.size.width + kDefaultOffset * 2;
  rect.size.height = self.containerView.bounds.size.height + kDefaultOffset * 2;
  self.bounds = rect;
}

- (void)setDisplayImage:(UIImage *)image {
  if (![self.imageDisplayView.image isEqual:image]) {
    [self sizeToFitImage:image];
  }
}

- (void)close {
  if ([self.delegate respondsToSelector:@selector(displayImageViewWillClose:)]) {
    [self.delegate displayImageViewWillClose:self];
  }
}
@end
