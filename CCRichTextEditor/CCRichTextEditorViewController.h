//
//  ViewController.h
//  CCRichTextEditor
//
//  Created by ddrccw on 13-3-1.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCRTEAccessorySwitch;

@interface CCRichTextEditorViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIButton *fontBtn;
@property (retain, nonatomic) IBOutlet UIButton *fontSizeUpBtn;
@property (retain, nonatomic) IBOutlet UIButton *fontSizeDownBtn;
@property (retain, nonatomic) IBOutlet UIButton *fontColorBtn;
@property (retain, nonatomic) IBOutlet CCRTEAccessorySwitch *boldSwitch;
@property (retain, nonatomic) IBOutlet CCRTEAccessorySwitch *italicSwitch;
@property (retain, nonatomic) IBOutlet CCRTEAccessorySwitch *underlineSwitch;
@property (retain, nonatomic) IBOutlet CCRTEAccessorySwitch *strikeThroughSwitch;
@property (retain, nonatomic) IBOutlet CCRTEAccessorySwitch *highlightSwitch;
@property (retain, nonatomic) IBOutlet UIButton *undoBtn;
@property (retain, nonatomic) IBOutlet UIButton *redoBtn;

@end
