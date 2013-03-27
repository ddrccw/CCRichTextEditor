//
//  CCDimView.h
//  CCRichTextEditor
//
//  Created by ddrccw on 13-3-12.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCMaskView;
@protocol CCMaskViewDelegate <NSObject>
- (BOOL)maskViewShouldDismiss:(CCMaskView *)maskView;
- (void)maskViewWillDismiss:(CCMaskView *)maskView;
@end

@interface CCMaskView : UIView
@property (assign, nonatomic) BOOL shouldDimBackground;
@property (assign, nonatomic) CGFloat opacity;
@property (assign, nonatomic) id <CCMaskViewDelegate> delegate;
@property (retain, nonatomic) UIView *centerView;

- (void)hide;
- (void)show:(CGFloat)animationDuration;
@end
