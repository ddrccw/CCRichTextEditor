//
//  CCRTEMovePictureGestureRegnizer.h
//  CCRichTextEditor
//
//  Created by chenche on 13-3-6.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TouchEventBlock_t)(NSSet *touches, UIEvent *event);

@interface CCRTEGestureRegnizer : UIGestureRecognizer
@property (assign, nonatomic) CGPoint startPoint;
@property (copy) TouchEventBlock_t touchesBeganCallback;
@property (copy) TouchEventBlock_t touchesEndedCallback;
@end
