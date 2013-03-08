//
//  CCRTEDocumentFragmentStatus.h
//  CCRichTextEditor
//
//  Created by chenche on 13-3-7.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCRTEDocumentFragmentStatus : NSObject
@property (retain, atomic) NSString *fontName;
@property (assign, nonatomic) int fontSize;    //webview上的字体大小,不是iOS的计量方法
@property (retain, atomic) UIColor *fontColor;
@property (assign, nonatomic) BOOL bold;
@property (assign, nonatomic) BOOL italic;
@property (assign, nonatomic) BOOL underline;
@property (assign, nonatomic) BOOL strikeThrough;
@property (assign, nonatomic) BOOL highlight;
@property (assign, nonatomic) BOOL undo;
@property (assign, nonatomic) BOOL redo;
@property (assign, nonatomic) int caretOffsetY;  //光标在可视区域内的偏移量

- (UIFont *)font;
- (NSString *)fontColorString;
- (void)setFontColorString:(NSString *)fontColorString;
- (NSString *)highlightColorString;

+ (NSString *)rgbColorStringOfColor:(UIColor *)aColor;
@end
