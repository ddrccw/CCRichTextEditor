//
//  CCRTEColorSelectionViewController.h
//  CCRichTextEditor
//
//  Created by ddrccw on 13-3-5.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCRTEColorSelectionViewControllerDelegate <NSObject>
- (void)didSelectColor:(UIColor *)color;
@end

@interface CCRTEColorSelectionViewController : UIViewController
@property (assign, nonatomic) id<CCRTEColorSelectionViewControllerDelegate> delegate;
@end
