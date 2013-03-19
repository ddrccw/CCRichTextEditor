//
//  CCRTEMovePictureGestureRegnizer.m
//  CCRichTextEditor
//
//  Created by ddrccw on 13-3-6.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import "CCRTEGestureRegnizer.h"

@implementation CCRTEGestureRegnizer

- (void)dealloc {
  [_touchesBeganCallback release];
  [_touchesEndedCallback release];
  [super dealloc];
}

- (id)init {
  if (self = [super init]) {
    _numberOfTapsRequired = 1;
  }
  return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (self.numberOfTapsRequired == [[touches anyObject] tapCount]) {
    if (_touchesBeganCallback)
      _touchesBeganCallback(touches, event);
  }
  
//  UITouch *touch = [touches anyObject];
//  NSLog(@"touchesBegan=%d, UITouchPhase=%d", [touch tapCount], [touch phase]);
  
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//  if (self.numberOfTapsRequired == [[touches anyObject] tapCount]) {
    if (_touchesEndedCallback)
      _touchesEndedCallback(touches, event);
//  }
//  UITouch *touch = [touches anyObject];
//  NSLog(@"touchesEnded=%d, UITouchPhase=%d", [touch tapCount], [touch phase]);
}

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//  NSLog(@"shouldBegin-%@", gestureRecognizer);
//  return YES;
//}
//
//- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer {
//  NSLog(@"%@", preventingGestureRecognizer);
//  if ([[preventingGestureRecognizer description] rangeOfString:@"UIScrollViewPanGestureRecognizer"].location != NSNotFound)
//    return NO;
//  return [super canBePreventedByGestureRecognizer:preventingGestureRecognizer];
//}

@end
