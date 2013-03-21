//
//  CCAudioViewController.h
//  CCRichTextEditor
//
//  Created by ddrccw on 13-3-14.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCAudioViewControllerDelegate <NSObject>

- (void)audioViewControllerDidStopRecord:(NSString *)audioFilePath;

@end

@interface CCAudioViewController : UIViewController
@property (assign, nonatomic) id <CCAudioViewControllerDelegate> delegate;
@property (assign, nonatomic) BOOL playing;
- (void)stopPlayQueue;
- (void)pausePlayQueue;
- (void)stopRecord;

- (void)play:(NSString *)fileName;
- (void)record:(NSString *)fileName;
- (void)replay;
@end
