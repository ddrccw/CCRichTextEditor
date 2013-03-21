//
//  CCRTEMovePictureGestureRegnizer.h
//  CCRichTextEditor
//
//  Created by ddrccw on 13-3-6.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TouchEventBlock_t)(NSSet *touches, UIEvent *event);

@interface CCRTEGestureRegnizer : UIGestureRecognizer
@property (assign, nonatomic) int numberOfTapsRequired;
@property (assign, nonatomic) CGPoint startPoint;
@property (assign, nonatomic) BOOL shouldCancelTouch;
@property (copy) TouchEventBlock_t touchesBeganCallback;
@property (copy) TouchEventBlock_t touchesEndedCallback;
@end
