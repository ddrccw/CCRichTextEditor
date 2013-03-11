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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (_touchesBeganCallback)
    _touchesBeganCallback(touches, event);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (_touchesEndedCallback)
    _touchesEndedCallback(touches, event);
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
