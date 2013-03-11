//
//  CCFontSelectionViewController.h
//  CCRichTextEditor
//
//  Created by ddrccw on 13-3-4.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCRTEFontSelectionViewControllerDelegate <NSObject>

- (void)didSelectFont:(UIFont *)font;

@end

@interface CCRTEFontSelectionViewController : UIViewController
@property (retain, nonatomic) NSArray *customizedFontArray;
@property (assign, nonatomic) id <CCRTEFontSelectionViewControllerDelegate> delegate;
@end
