//
//  CCAudioViewController.h
//  CCRichTextEditor
//
//  Created by ddrccw on 13-3-14.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCAudioViewControllerDelegate <NSObject>

- (void)audioViewControllerDidStopRecord;

@end

@interface CCAudioViewController : UIViewController
@property (assign, nonatomic) id <CCAudioViewControllerDelegate> delegate;

- (void)record:(id)sender;
@end
