//
//  CCRTEAccessoryItem.h
//  CCRichTextEditor
//
//  Created by ddrccw on 13-3-1.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCRTEAccessorySwitch : UIControl
- (void)setTitle:(NSAttributedString *)title
   selectedTitle:(NSAttributedString *)selectedTitle
      frontImage:(UIImage *)frontImage
 backgroundImage:(UIImage *)backgroundImage
selectedBackgroundImage:(UIImage *)selectedBackgroundImage;
@end
