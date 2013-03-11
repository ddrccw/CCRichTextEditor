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
@property (assign, atomic) int fontSize;    //webview上的字体大小,不是iOS的计量方法
@property (retain, atomic) UIColor *fontColor;
@property (assign, atomic) BOOL bold;
@property (assign, atomic) BOOL italic;
@property (assign, atomic) BOOL underline;
@property (assign, atomic) BOOL strikeThrough;
@property (assign, atomic) BOOL highlight;
@property (assign, atomic) BOOL undo;
@property (assign, atomic) BOOL redo;
@property (assign, atomic) int caretOffsetY;  //光标在可视区域内的偏移量

- (UIFont *)font;
- (NSString *)fontColorString;
- (void)setFontColorString:(NSString *)fontColorString;
- (NSString *)highlightColorString;

+ (NSString *)rgbColorStringOfColor:(UIColor *)aColor;
@end
