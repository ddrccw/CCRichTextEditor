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
- (void)maskViewWillDismiss:(CCMaskView *)maskView;
@end

@interface CCMaskView : UIView
@property (assign, nonatomic) BOOL shouldDimBackground;
@property (retain, nonatomic) UIColor *color;
@property (assign, nonatomic) CGFloat opacity;
@property (assign, nonatomic) id <CCMaskViewDelegate> delegate;
@end
