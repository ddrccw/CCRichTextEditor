//
//  CCRTEAccessoryItem.h
//  CCRichTextEditor
//
//  Created by chenche on 13-3-1.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCRTEAccessorySwitch : UIControl
- (void)setTitle:(NSAttributedString *)title
   selectedTitle:(NSAttributedString *)seletedTitle
 backgroundImage:(UIImage *)backgroundImage
   selectedImage:(UIImage *)selectedImage;
@end
