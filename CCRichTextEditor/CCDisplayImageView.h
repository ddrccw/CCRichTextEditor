//
//  CCDisplayImageView.h
//  CCRichTextEditor
//
//  Created by chenche on 13-3-12.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCDisplayImageView;
@protocol CCDisplayImageViewDelegate <NSObject>
- (void)displayImageViewWillClose:(CCDisplayImageView *)displayImageView;
@end

@interface CCDisplayImageView : UIView
@property (assign, nonatomic) id <CCDisplayImageViewDelegate> delegate;
@property (assign, nonatomic) CGFloat maxImageWidth;
@property (assign, nonatomic) CGFloat maxImageHeight;

- (id)initWithImage:(UIImage *)image
      maxImageWidth:(CGFloat)maxImageWidth
     maxImageHeight:(CGFloat)maxImageHeight;
- (void)setDisplayImage:(UIImage *)image;
@end
