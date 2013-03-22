//
//  CCCircleProgressView.h
//  CCRichTextEditor
//
//  Created by ddrccw on 13-3-20.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCCircleProgressView : UIView
@property (assign, nonatomic) CGFloat progress;
@property (assign, nonatomic) CGFloat progressWidth; //out.radius - in.radius
@property (retain, nonatomic) UIColor *progressBarBackgroundColor;
@end
