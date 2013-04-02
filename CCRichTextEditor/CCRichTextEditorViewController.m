//
//  ViewController.m
//  CCRichTextEditor
//
//  Created by ddrccw on 13-3-1.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import "CCRichTextEditorViewController.h"
#import "CCRTEDocumentFragmentStatus.h"
#import "CCRTEAccessorySwitch.h"
#import "CCRTEFontSelectionViewController.h"
#import "CCRTEColorSelectionViewController.h"
#import "CCRTEGestureRegnizer.h"
#import "CCMaskView.h"
#import "CCDisplayImageView.h"
#import "CCAudioViewController.h"

#import <CoreText/CoreText.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define DOCUMENT_EXECCMD_CMD(CMD) [NSString stringWithFormat:@"document.execCommand('%@')", CMD]
#define DOCUMENT_EXECCMD_CMD_STRING_VALUE(CMD, VALUE) [NSString stringWithFormat:@"document.execCommand('%@', false, '%@')", CMD, VALUE]
#define DOCUMENT_EXECCMD_CMD_NONSTRING_VALUE(CMD, VALUE) [NSString stringWithFormat:@"document.execCommand('%@', false, '%d')", CMD, VALUE]
#define DOCUMENT_QUERYCMDVALUE(CMD) [NSString stringWithFormat:@"document.queryCommandValue('%@')", CMD]
#define DOCUMENT_QUERYCMDSTATE(CMD) [NSString stringWithFormat:@"document.queryCommandState('%@')", CMD]
#define DOCUMENT_QUERYCMDENABLED(CMD) [NSString stringWithFormat:@"document.queryCommandEnabled('%@')", CMD]

#define DOM_ELEMENT_FORMPOINT_ATTRIBUTE(X, Y, NAME) [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).getAttribute('%@')", X, Y, NAME]

enum {
  kClientRectTop,
  kClientRectRight,
  kClientRectBottom,
  kClientRectLeft,
  kClientRectWidth,
  kClientRectHeight
};

@interface CCRTEContent : NSObject
@property (retain, nonatomic) NSMutableDictionary *picturePaths;
@property (retain, nonatomic) NSMutableArray *audioPaths;
@property (copy, nonatomic) NSString *htmlContent;
@end

@implementation CCRTEContent

- (void)dealloc {
  [_picturePaths release];
  [_audioPaths release];
  [_htmlContent release];
  [super dealloc];
}

- (id)init {
  if (self = [super init]) {
    _picturePaths = [[NSMutableDictionary alloc] init];
    _audioPaths = [[NSMutableArray alloc] init];
  }
  return self;
}

@end


////////////////////////////////////////////////////////////////////////////////
@interface CCRichTextEditorViewController ()
<UIActionSheetDelegate, UIWebViewDelegate,
UINavigationControllerDelegate, UIImagePickerControllerDelegate,
CCRTEFontSelectionViewControllerDelegate, CCRTEColorSelectionViewControllerDelegate,
CCMaskViewDelegate, CCDisplayImageViewDelegate, CCAudioViewControllerDelegate>

@property (retain, atomic) IBOutlet UIWebView *contentWebView;
@property (retain, nonatomic) IBOutlet UIView *inputAccessoryView;
@property (retain, nonatomic) UIPopoverController *fontPopController;
@property (retain, nonatomic) UIPopoverController *fontColorPopController;
@property (retain, nonatomic) UIActionSheet *photoActionSheet;
@property (retain, nonatomic) UIPopoverController *photoPopController;
@property (retain, nonatomic) NSTimer *timer;
@property (retain, nonatomic) CCRTEDocumentFragmentStatus *documentFragmentStatus;
@property (retain, nonatomic) UIMenuController *accessoryMenuController;
@property (retain, nonatomic) CCRTEContent *content;
@property (retain, nonatomic) CCMaskView *maskView;
@property (retain, nonatomic) CCDisplayImageView *displayImageView;
@property (retain, nonatomic) CCAudioViewController *audioViewController;
@end

@implementation CCRichTextEditorViewController

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_contentWebView release];
  [_fontBtn release];
  [_fontPopController release];
  [_fontColorPopController release];
  [_photoActionSheet release];
  [_photoPopController release];
  [_timer release];
  [_documentFragmentStatus release];
  [_accessoryMenuController release];
  [_content release];
  [_maskView release];
  [_displayImageView release];
  [_audioViewController release];
  [_fontSizeUpBtn release];
  [_fontSizeDownBtn release];
  [_fontColorBtn release];
  [_boldSwitch release];
  [_italicSwitch release];
  [_underlineSwitch release];
  [_strikeThroughSwitch release];
  [_highlightSwitch release];
  [_undoBtn release];
  [_redoBtn release];
  [_photoBtn release];
  [_audioBtn release];
  [super dealloc];
}

- (void)viewDidUnload {
  [self setContentWebView:nil];
  self.fontPopController = nil;
  self.fontColorPopController = nil;
  self.photoActionSheet = nil;
  self.photoPopController = nil;
  self.timer = nil;
  self.documentFragmentStatus = nil;
  self.accessoryMenuController = nil;
  self.content = nil;
  self.maskView = nil;
  self.displayImageView = nil;
  self.audioViewController = nil;
  [self setFontBtn:nil];
  [self setFontSizeUpBtn:nil];
  [self setFontSizeDownBtn:nil];
  [self setFontColorBtn:nil];
  [self setBoldSwitch:nil];
  [self setItalicSwitch:nil];
  [self setStrikeThroughSwitch:nil];
  [self setHighlightSwitch:nil];
  [self setUnderlineSwitch:nil];
  [self setUndoBtn:nil];
  [self setRedoBtn:nil];
  [self setPhotoBtn:nil];
  [self setAudioBtn:nil];
  [super viewDidUnload];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [_contentWebView setBackgroundColor:[UIColor clearColor]];
  _contentWebView.delegate = self;
  _content = [CCRTEContent new];
  
  NSBundle *bundle = [NSBundle mainBundle];
  NSURL *indexFileURL = [bundle URLForResource:@"index" withExtension:@"html"];
  [self.contentWebView loadRequest:[NSURLRequest requestWithURL:indexFileURL]];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
  [self initAccessoryView];
  [self initDocumentStatus];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{  
  NSString *requestString = [[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
  //NSLog(@"%@", requestString);
  
  if ([requestString hasPrefix:@"ios-log:"]) {
    NSString* logString = [[requestString componentsSeparatedByString:@":#iOS#"] objectAtIndex:1];
    CC_ERRORLOG(@"UIWebView console: %@", logString);
    return NO;
  }
  
  if ([requestString hasPrefix:@"js-frame:"]) {
    NSArray *components = [requestString componentsSeparatedByString:@"|"];
    NSString *function = (NSString*)[components objectAtIndex:1];
		int callbackId = [((NSString*)[components objectAtIndex:2]) intValue];
    NSString *argsAsString = [(NSString*)[components objectAtIndex:3]
                              stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSData *JSONData = [argsAsString dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *args = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:nil];
    [self handleCall:function callbackId:callbackId args:args];
    return NO;
  }
  
  return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
  static BOOL isInit = YES;
  if (isInit) {
    [self.contentWebView stringByEvaluatingJavaScriptFromString:@"var editor = new CCRichTextEditor();"];
    isInit = NO;
  }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - native bridge between iOS and js
- (void)handleCall:(NSString *)functionName callbackId:(int)callbackId args:(NSArray *)args {
  [self performSelector:sel_getUid([functionName UTF8String]) withObject:args];
}

- (void)updatePictureData:(NSArray *)pictureData {
  NSMutableDictionary *pictures = [NSMutableDictionary dictionaryWithCapacity:[pictureData count]];
  for (NSDictionary *picture in pictureData) {
    [pictures addEntriesFromDictionary:@{picture[@"key"]: picture[@"value"]}];
  }
  
  self.content.picturePaths = pictures;
  NSLog(@"%@",self.content.picturePaths);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - private method
- (void)initDocumentStatus {
  _documentFragmentStatus = [CCRTEDocumentFragmentStatus new];
  _documentFragmentStatus.fontName = self.fontBtn.titleLabel.font.fontName;
  _documentFragmentStatus.fontSize = 3;
  _documentFragmentStatus.fontColor = [UIColor blackColor];
  _documentFragmentStatus.bold = NO;
  _documentFragmentStatus.italic = NO;
  _documentFragmentStatus.underline = NO;
  _documentFragmentStatus.strikeThrough = NO;
  _documentFragmentStatus.undo = NO;
  _documentFragmentStatus.redo = NO;

  [self.contentWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@;%@;%@;%@;%@;%@;%@;",
                                                               DOCUMENT_EXECCMD_CMD_STRING_VALUE(@"fontName", _documentFragmentStatus.fontName),
                                                               DOCUMENT_EXECCMD_CMD_NONSTRING_VALUE(@"fontSize", 3),
                                                               DOCUMENT_EXECCMD_CMD_STRING_VALUE(@"foreColor", _documentFragmentStatus.fontColorString),
                                                               DOCUMENT_EXECCMD_CMD_NONSTRING_VALUE(@"bold", false),
                                                               DOCUMENT_EXECCMD_CMD_NONSTRING_VALUE(@"italic", false),
                                                               DOCUMENT_EXECCMD_CMD_NONSTRING_VALUE(@"underline", false),
                                                               DOCUMENT_EXECCMD_CMD_NONSTRING_VALUE(@"strikeThrough", false)]];
  
  [self addGesture];

  if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0) {
    UIMenuItem *boldItem = [[[UIMenuItem alloc] initWithTitle:@"加粗"
                                                       action:@selector(boldAction)] autorelease];
    UIMenuItem *italicItem = [[[UIMenuItem alloc] initWithTitle:@"斜体"
                                                         action:@selector(italicAction)] autorelease];
    UIMenuItem *underlineItem = [[[UIMenuItem alloc] initWithTitle:@"下划线"
                                                            action:@selector(underlineAction)] autorelease];
    UIMenuItem *highlightItem = [[[UIMenuItem alloc] initWithTitle:@"高亮"
                                                            action:@selector(highlightAction)] autorelease];
    [[UIMenuController sharedMenuController] setMenuItems:@[boldItem,
                                                            italicItem,
                                                            underlineItem,
                                                            highlightItem]];
  }
}

- (void)addGesture {
  CCRTEGestureRegnizer *moveImageGesture = [[[CCRTEGestureRegnizer alloc] init] autorelease];
  moveImageGesture.touchesBeganCallback = ^(NSSet *touches, UIEvent *event) {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    NSString *javascript = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).tagName.toString()",
                            touchPoint.x, touchPoint.y];
    NSString *elementNameAtPoint = [self.contentWebView stringByEvaluatingJavaScriptFromString:javascript];
    if ([elementNameAtPoint isEqualToString:@"IMG"]) {
      moveImageGesture.shouldCancelTouch = NO;
      // We set the inital point of the image for use latter on when we actually move it
      moveImageGesture.startPoint = touchPoint;
      // In order to make moving the image easy we must disable scrolling otherwise the view will just scroll and prevent fully detecting movement on the image.
      self.contentWebView.scrollView.scrollEnabled = NO;
    }
    else {
      moveImageGesture.shouldCancelTouch = YES;
      moveImageGesture.startPoint = CGPointZero;
      self.contentWebView.scrollView.scrollEnabled = YES;
    }
  };
  moveImageGesture.touchesEndedCallback = ^(NSSet *touches, UIEvent *event) {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    NSString *js = nil;
    self.contentWebView.scrollView.scrollEnabled = YES;
    if (!CGPointEqualToPoint(moveImageGesture.startPoint, touchPoint)) {
      js = [NSString stringWithFormat:@"editor.moveImageAtTo(%f, %f, %f, %f)",
                                      moveImageGesture.startPoint.x, moveImageGesture.startPoint.y,
                                      touchPoint.x, touchPoint.y];
      [self.contentWebView stringByEvaluatingJavaScriptFromString:js];
    }
  };
  [self.contentWebView.scrollView addGestureRecognizer:moveImageGesture];
  
  CCRTEGestureRegnizer *tapImageGesture = [[[CCRTEGestureRegnizer alloc] init] autorelease];
  tapImageGesture.numberOfTapsRequired = 2;
  tapImageGesture.touchesBeganCallback = ^(NSSet *touches, UIEvent *event) {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).tagName.toString()",
                            touchPoint.x, touchPoint.y];
    NSString *elementNameAtPoint = [self.contentWebView stringByEvaluatingJavaScriptFromString:js];
    if ([elementNameAtPoint isEqualToString:@"IMG"]) {
      js = [NSString stringWithFormat:@"editor.audioFileIndexAtPoint(%f, %f)", touchPoint.x, touchPoint.y];
      int audioFileIndex = [[self.contentWebView stringByEvaluatingJavaScriptFromString:js] intValue];
      if (audioFileIndex >= 0) {
        [self showAudioMaskView];
        NSString *fileName = [NSString stringWithFormat:@"audio%d", audioFileIndex];
        [self.audioViewController play:fileName];
      }
      else {
        [self showImageMaskViewFromPoint:touchPoint];
      }
    }
  };
  
  [self.contentWebView.scrollView addGestureRecognizer:tapImageGesture];
}

- (void)checkSelection {
  NSString *fontName = [self.contentWebView stringByEvaluatingJavaScriptFromString:DOCUMENT_QUERYCMDVALUE(@"fontName")];
  if (fontName) {
    self.documentFragmentStatus.fontName = fontName;
  }
  
  int fontSize = [[self.contentWebView stringByEvaluatingJavaScriptFromString:DOCUMENT_QUERYCMDVALUE(@"fontSize")] intValue];
  if (fontSize) {
    self.documentFragmentStatus.fontSize = fontSize;
  }
  
  NSString *fontColorString = [self.contentWebView stringByEvaluatingJavaScriptFromString:DOCUMENT_QUERYCMDVALUE(@"foreColor")];
  if (fontColorString) {
    self.documentFragmentStatus.fontColorString = fontColorString;
  }

  self.documentFragmentStatus.bold = [[self.contentWebView stringByEvaluatingJavaScriptFromString:DOCUMENT_QUERYCMDSTATE(@"bold")] boolValue];
  self.documentFragmentStatus.italic = [[self.contentWebView stringByEvaluatingJavaScriptFromString:DOCUMENT_QUERYCMDSTATE(@"italic")] boolValue];
  self.documentFragmentStatus.underline = [[self.contentWebView stringByEvaluatingJavaScriptFromString:DOCUMENT_QUERYCMDSTATE(@"underline")] boolValue];
  self.documentFragmentStatus.strikeThrough = [[self.contentWebView stringByEvaluatingJavaScriptFromString:DOCUMENT_QUERYCMDSTATE(@"strikeThrough")] boolValue];
  
  NSString *backColorString = [self.contentWebView stringByEvaluatingJavaScriptFromString:DOCUMENT_QUERYCMDVALUE(@"backColor")];
  if ([backColorString isEqualToString:self.documentFragmentStatus.highlightColorString]) {
    self.documentFragmentStatus.highlight = YES;
  }
  else {
    self.documentFragmentStatus.highlight = NO;
  }
  
  self.documentFragmentStatus.undo = [[self.contentWebView stringByEvaluatingJavaScriptFromString:DOCUMENT_QUERYCMDENABLED(@"undo")] boolValue];
  self.documentFragmentStatus.redo = [[self.contentWebView stringByEvaluatingJavaScriptFromString:DOCUMENT_QUERYCMDENABLED(@"redo")] boolValue];

  [self refreshInputAccessoryView];
  [self refreshForScrollingToVisible];
}

- (void)refreshInputAccessoryView {
  self.fontBtn.titleLabel.font = self.documentFragmentStatus.font;
  static const UInt8 kMaxFontSize = 7;
  static const UInt8 kMinFontSize = 1;
  if (kMaxFontSize == self.documentFragmentStatus.fontSize) {
    self.fontSizeUpBtn.enabled = NO;
  }
  else if (kMinFontSize == self.documentFragmentStatus.fontSize) {
    self.fontSizeDownBtn.enabled = NO;
  }
  else {
    self.fontSizeUpBtn.enabled = self.fontSizeDownBtn.enabled = YES;
  }
  
  if (![self.fontColorBtn.titleLabel.textColor isEqual:self.documentFragmentStatus.fontColor] &&
      ![self.fontColorBtn.titleLabel.highlightedTextColor isEqual:self.documentFragmentStatus.fontColor]) {
    [self.fontColorBtn setTitleColor:self.documentFragmentStatus.fontColor forState:UIControlStateNormal];
    [self.fontColorBtn setTitleColor:self.documentFragmentStatus.fontColor forState:UIControlStateHighlighted];
  }
  
  if ((self.boldSwitch.selected ^ self.documentFragmentStatus.bold)) {
    self.boldSwitch.selected = self.documentFragmentStatus.bold;
  }
  
  if ((self.italicSwitch.selected ^ self.documentFragmentStatus.italic)) {
    self.italicSwitch.selected = self.documentFragmentStatus.italic;
  }
 
  if ((self.underlineSwitch.selected ^ self.documentFragmentStatus.underline)) {
    self.underlineSwitch.selected = self.documentFragmentStatus.underline;
  }
  
  if ((self.strikeThroughSwitch.selected ^ self.documentFragmentStatus.strikeThrough)) {
    self.strikeThroughSwitch.selected = self.documentFragmentStatus.strikeThrough;
  }
  
  if ((self.highlightSwitch.selected ^ self.documentFragmentStatus.highlight)) {
    self.highlightSwitch.selected = self.documentFragmentStatus.highlight;
  }
//  NSLog(@"c:b=%d, i=%d, u=%d, s=%d", self.documentFragmentStatus.bold, self.documentFragmentStatus.italic, self.documentFragmentStatus.underline, self.documentFragmentStatus.strikeThrough);
//  NSLog(@"o:b=%d, i=%d, u=%d, s=%d", self.boldSwitch.selected, self.italicSwitch.selected, self.underlineSwitch.selected, self.strikeThroughSwitch.selected);

//  self.boldSwitch.selected = self.documentFragmentStatus.bold;
//  self.italicSwitch.selected = self.documentFragmentStatus.italic;
//  self.underlineSwitch.selected = self.documentFragmentStatus.underline;
//  self.strikeThroughSwitch.selected = self.documentFragmentStatus.strikeThrough;

  self.undoBtn.enabled = self.documentFragmentStatus.undo;
  self.redoBtn.enabled = self.documentFragmentStatus.redo;
}

//TODO:如果scroll查看时，如果光标在keyboard下方，则会调回到可见区域，有待改进
- (void)refreshForScrollingToVisible {
//  NSString *dd = [self.contentWebView stringByEvaluatingJavaScriptFromString:@"getCaretPosition().toString()"];
//  NSLog(@"%@", dd);
  int offsetY = [[self.contentWebView stringByEvaluatingJavaScriptFromString:@"editor.getCaretPosition()"] intValue];
//  NSLog(@"out=%d, pre=%d", offsetY, self.documentFragmentStatus.caretOffsetY);
  
  static const UInt8 kOffsetEdge = 30;
  offsetY += kOffsetEdge;
  if (offsetY > self.inputAccessoryView.frame.origin.y &&
      self.documentFragmentStatus.caretOffsetY != offsetY)
  {
    CGPoint preOffset = self.contentWebView.scrollView.contentOffset;
    CGSize preContentSize = self.contentWebView.scrollView.contentSize;
    CGPoint p = CGPointMake(0, preOffset.y + offsetY - self.inputAccessoryView.frame.origin.y);
    static const UInt16 kKeyboardHeight = 450;
    if (p.y >= (preContentSize.height - kKeyboardHeight)) {
      preContentSize.height += preContentSize.height / 3;
      self.contentWebView.scrollView.contentSize = preContentSize;
    }
//    NSLog(@"%@, contentSize=%@, scrollframe=%@, webFrame=%@", NSStringFromCGPoint(p),
//          NSStringFromCGSize(self.contentWebView.scrollView.contentSize),
//          NSStringFromCGRect(self.contentWebView.scrollView.frame),
//          NSStringFromCGRect(self.contentWebView.frame));
    [self.contentWebView.scrollView setContentOffset:p];
    self.documentFragmentStatus.caretOffsetY = self.inputAccessoryView.frame.origin.y - kOffsetEdge;
  }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - audio/image show delegate
- (void)showAudioMaskView {
  if (!self.audioViewController) {
    _audioViewController = [[CCAudioViewController alloc] initWithNibName:@"CCAudioViewController" bundle:nil];
    _audioViewController.delegate = self;
    [self addChildViewController:self.audioViewController];
    [self.audioViewController didMoveToParentViewController:self];
    
    if (!self.maskView) {
      _maskView = [[CCMaskView alloc] initWithFrame:self.view.bounds];
      _maskView.delegate = self;
      _maskView.shouldDimBackground = YES;
      [self.view addSubview:_maskView];
    }
  }
  
  [self.contentWebView performSelector:@selector(endEditing:) withObject:@(YES) afterDelay:0];
  [self.maskView setCenterView:self.audioViewController.view];
  [self.maskView show:.3]; 
}

- (void)showImageMaskViewFromPoint:(CGPoint )aPoint {
  //防止双击弹窗期间，可能会再次弹出键盘
  [self.contentWebView performSelector:@selector(endEditing:) withObject:@(YES) afterDelay:0.15];
  NSString *javascript = DOM_ELEMENT_FORMPOINT_ATTRIBUTE(aPoint.x, aPoint.y, @"src");
  NSString *imgSrc = [self.contentWebView stringByEvaluatingJavaScriptFromString:javascript];
  javascript = [NSString stringWithFormat:@"editor.clientRectOfElementFromPoint(%f, %f)", aPoint.x, aPoint.y];
  NSString *string = [self.contentWebView stringByEvaluatingJavaScriptFromString:javascript];
  NSArray *clientRect = [string componentsSeparatedByString:@","];
  if (!self.maskView) {
    _maskView = [[CCMaskView alloc] initWithFrame:self.view.bounds];
    _maskView.delegate = self;
    _maskView.shouldDimBackground = YES;
    [self.view addSubview:_maskView];
  }
  
  UIImage *img = [UIImage imageWithContentsOfFile:imgSrc];
  if (!self.displayImageView) {
    _displayImageView = [[CCDisplayImageView alloc] initWithImage:img
                                                    maxImageWidth:self.view.bounds.size.width * 4 / 5
                                                   maxImageHeight:self.view.bounds.size.height * 4 / 5];
    _displayImageView.delegate = self;
    [self.maskView setCenterView:self.displayImageView];
  }
  else {
    self.displayImageView.maxImageWidth = self.view.bounds.size.width * 4 / 5;
    self.displayImageView.maxImageHeight = self.view.bounds.size.height * 4 / 5;
    [self.displayImageView setDisplayImage:img];
    [self.maskView setCenterView:self.displayImageView];
  }
  
  float kDuration = .2f;
  CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
  CGPoint point = CGPointZero;
  point.x = [clientRect[kClientRectLeft] floatValue] + [clientRect[kClientRectWidth] floatValue] / 2;
  point.y = [clientRect[kClientRectTop] floatValue] + [clientRect[kClientRectHeight] floatValue] / 2;
  positionAnimation.fromValue = [NSValue valueWithCGPoint:point];
  point = self.displayImageView.center;
  positionAnimation.toValue = [NSValue valueWithCGPoint:point];
  positionAnimation.duration = kDuration;
 
  self.displayImageView.transform = CGAffineTransformIdentity; //IMPORTANT!!
  CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
  float scaleX = [clientRect[kClientRectWidth] floatValue] / self.displayImageView.frame.size.width;
  float scaleY = [clientRect[kClientRectHeight] floatValue] / self.displayImageView.frame.size.height;
  scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scaleX, scaleY, 1)];
  scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
  scaleAnimation.duration = kDuration;
  
  CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
  animationGroup.animations = @[positionAnimation, scaleAnimation];
  [self.displayImageView.layer addAnimation:animationGroup forKey:@"showDisplayImageView"];
 
  [self.maskView show:kDuration];
}

- (void)displayImageViewWillClose:(CCDisplayImageView *)displayImageView {
  [self.maskView hide];
  [self.contentWebView endEditing:NO];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - mask view delegate
- (void)maskViewWillDismiss:(CCMaskView *)maskView {
  if ([self.maskView.centerView isKindOfClass:[CCDisplayImageView class]]) {
    [self.contentWebView endEditing:NO];
  }
  else {
    [self.audioViewController stopPlayQueue];
  }
}

- (BOOL)maskViewShouldDismiss:(CCMaskView *)maskView {
  if ([self.maskView.centerView isKindOfClass:[CCDisplayImageView class]]) {
    return YES;
  }
  if ([self.audioViewController playing]) {
    return YES;
  }
  return NO;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - ****inputAccessoryView**** -
- (void)initAccessoryView {
  self.inputAccessoryView.layer.masksToBounds = NO;
  self.inputAccessoryView.layer.shadowOffset = CGSizeMake(0, 0);
  self.inputAccessoryView.layer.shadowColor = [UIColor blackColor].CGColor;
  self.inputAccessoryView.layer.shadowOpacity = .8;
  self.inputAccessoryView.layer.shadowRadius = 2.0f;
  [self.view addSubview:self.inputAccessoryView];
  self.inputAccessoryView.hidden = YES;
  UIImage *barImage = [[UIImage imageNamed:@"customKeyboardBar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
  self.inputAccessoryView.backgroundColor = [UIColor colorWithPatternImage:barImage];

  [self.fontBtn addTarget:self action:@selector(chooseFont) forControlEvents:UIControlEventTouchUpInside];
  [self.fontSizeUpBtn addTarget:self action:@selector(fontSizeUp) forControlEvents:UIControlEventTouchUpInside];
  [self.fontSizeDownBtn addTarget:self action:@selector(fontSizeDown) forControlEvents:UIControlEventTouchUpInside];
  [self.fontColorBtn addTarget:self action:@selector(chooseFontColor) forControlEvents:UIControlEventTouchUpInside];
  [self.fontColorBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  [self.fontColorBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
  
  //Bold, Italic, Underline, underline
  const int kFontSize = 17;
  UIFont *font = [UIFont systemFontOfSize:kFontSize];
  NSDictionary *normalFontAttributes = @{(id)kCTFontAttributeName :
                                         (id)CTFontCreateWithName((CFStringRef)font.fontName, kFontSize, NULL)};
  NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"B" attributes:normalFontAttributes];
  
  UIFont *selectedFont = [UIFont boldSystemFontOfSize:kFontSize];
  NSMutableDictionary *selectedFontAttributes = [[NSMutableDictionary alloc] initWithDictionary:@{(id)kCTFontAttributeName :
                                                                                                  (id)CTFontCreateWithName((CFStringRef)selectedFont.fontName, kFontSize, NULL)}];
  NSAttributedString *selectTitle = [[NSAttributedString alloc] initWithString:@"B" attributes:selectedFontAttributes];
  [self.boldSwitch setTitle:nil selectedTitle:nil
                 frontImage:[UIImage imageNamed:@"boldMark"]
            backgroundImage:[UIImage imageNamed:@"commonBtnBackground"]
    selectedBackgroundImage:[UIImage imageNamed:@"commonBtnHighlightedBackground"]];
  [self.boldSwitch addTarget:self action:@selector(boldAction) forControlEvents:UIControlEventTouchUpInside];
  [title release];
  [selectTitle release];
  [selectedFontAttributes release];
  
  selectedFont = [UIFont italicSystemFontOfSize:kFontSize];
  selectedFontAttributes = [[NSMutableDictionary alloc] initWithDictionary:@{(id)kCTFontAttributeName :
                                                                             (id)CTFontCreateWithName((CFStringRef)selectedFont.fontName, kFontSize, NULL)}];
  title = [[NSAttributedString alloc] initWithString:@"I" attributes:normalFontAttributes];
  selectTitle = [[NSAttributedString alloc] initWithString:@"I" attributes:selectedFontAttributes];
  [self.italicSwitch setTitle:nil selectedTitle:nil
                   frontImage:[UIImage imageNamed:@"italicMark"]
              backgroundImage:[UIImage imageNamed:@"commonBtnBackground"]
      selectedBackgroundImage:[UIImage imageNamed:@"commonBtnHighlightedBackground"]];
  [self.italicSwitch addTarget:self action:@selector(italicAction) forControlEvents:UIControlEventTouchUpInside];
  [title release];
  [selectTitle release];
  [selectedFontAttributes release];
  
  selectedFontAttributes = [normalFontAttributes mutableCopy];
  [selectedFontAttributes addEntriesFromDictionary:@{(id)kCTUnderlineStyleAttributeName : @(kCTUnderlineStyleSingle)}];
  title = [[NSAttributedString alloc] initWithString:@"U" attributes:normalFontAttributes];
  selectTitle = [[NSAttributedString alloc] initWithString:@"U" attributes:selectedFontAttributes];
  [self.underlineSwitch setTitle:nil selectedTitle:nil
                      frontImage:[UIImage imageNamed:@"underlineMark"]
                 backgroundImage:[UIImage imageNamed:@"commonBtnBackground"]
         selectedBackgroundImage:[UIImage imageNamed:@"commonBtnHighlightedBackground"]];
  [self.underlineSwitch addTarget:self action:@selector(underlineAction) forControlEvents:UIControlEventTouchUpInside];
  [title release];
  [selectTitle release];
  [selectedFontAttributes release];
  
  [self.strikeThroughSwitch setTitle:nil selectedTitle:nil
                          frontImage:[UIImage imageNamed:@"strikeThroughMark"]
                     backgroundImage:[UIImage imageNamed:@"commonBtnBackground"]
             selectedBackgroundImage:[UIImage imageNamed:@"commonBtnHighlightedBackground"]];
  [self.strikeThroughSwitch addTarget:self action:@selector(strikeThroughAction) forControlEvents:UIControlEventTouchUpInside];
  
  [self.highlightSwitch setTitle:nil selectedTitle:nil
                      frontImage:[UIImage imageNamed:@"highlightMark"]
                 backgroundImage:[UIImage imageNamed:@"commonBtnBackground"]
         selectedBackgroundImage:[UIImage imageNamed:@"commonBtnHighlightedBackground"]];
  [self.highlightSwitch addTarget:self action:@selector(highlightAction) forControlEvents:UIControlEventTouchUpInside];
  
  [self.undoBtn addTarget:self action:@selector(undoAction) forControlEvents:UIControlEventTouchUpInside];
  self.undoBtn.enabled = NO;
  [self.redoBtn addTarget:self action:@selector(redoAction) forControlEvents:UIControlEventTouchUpInside];
  self.redoBtn.enabled = NO;
  [self.photoBtn addTarget:self action:@selector(choosePhoto) forControlEvents:UIControlEventTouchUpInside];
  [self.audioBtn addTarget:self action:@selector(recordAudio) forControlEvents:UIControlEventTouchUpInside];
}

- (void)chooseFont {
  if (!_fontPopController) {
    CCRTEFontSelectionViewController *fontSelectionVC = [CCRTEFontSelectionViewController new];
    fontSelectionVC.customizedFontArray = @[@"Kai Regular", @"宋体"];  //font Name not file name
    fontSelectionVC.delegate = self;
    _fontPopController = [[UIPopoverController alloc] initWithContentViewController:fontSelectionVC];
    _fontPopController.popoverContentSize = CGSizeMake(200, 400);
    [fontSelectionVC release];
  }
  
  [self.fontPopController presentPopoverFromRect:self.fontBtn.frame
                                          inView:self.inputAccessoryView
                        permittedArrowDirections:UIPopoverArrowDirectionDown
                                        animated:YES];
}

#pragma mark CCRTEFontSelectionViewControllerDelegate
- (void)didSelectFont:(UIFont *)font {
  if (![self.documentFragmentStatus.fontName isEqual:font.fontName]) {
    self.documentFragmentStatus.fontName = font.fontName;
    [self.contentWebView stringByEvaluatingJavaScriptFromString:DOCUMENT_EXECCMD_CMD_STRING_VALUE(@"fontName", font.fontName)];
  }
  [self.fontPopController dismissPopoverAnimated:YES];
}

- (void)fontSizeUp {
  self.documentFragmentStatus.fontSize += 1;
  [self.contentWebView stringByEvaluatingJavaScriptFromString:DOCUMENT_EXECCMD_CMD_NONSTRING_VALUE(@"fontSize", self.documentFragmentStatus.fontSize)];
}

- (void)fontSizeDown {
  self.documentFragmentStatus.fontSize -= 1;
  [self.contentWebView stringByEvaluatingJavaScriptFromString:DOCUMENT_EXECCMD_CMD_NONSTRING_VALUE(@"fontSize", self.documentFragmentStatus.fontSize)];
}

- (void)chooseFontColor {
  if (!_fontColorPopController) {
    CCRTEColorSelectionViewController *colorSelectionVC = [CCRTEColorSelectionViewController new];
    colorSelectionVC.delegate = self;
    _fontColorPopController = [[UIPopoverController alloc] initWithContentViewController:colorSelectionVC];
    _fontColorPopController.popoverContentSize = CGSizeMake(200, 400);
    [colorSelectionVC release];
  }
  
  [self.fontColorPopController presentPopoverFromRect:self.fontColorBtn.frame
                                               inView:self.inputAccessoryView
                             permittedArrowDirections:UIPopoverArrowDirectionDown
                                             animated:YES];
}

#pragma mark CCRTEColorSelectionViewControllerDelegate
- (void)didSelectColor:(UIColor *)color {
  if (![self.documentFragmentStatus.fontColor isEqual:color]) {
    self.documentFragmentStatus.fontColor = color;
    [self.contentWebView stringByEvaluatingJavaScriptFromString:DOCUMENT_EXECCMD_CMD_STRING_VALUE(@"foreColor", self.documentFragmentStatus.fontColorString)];
  }
  [self.fontColorPopController dismissPopoverAnimated:YES];
}

- (void)boldAction {
  [self.contentWebView stringByEvaluatingJavaScriptFromString:DOCUMENT_EXECCMD_CMD_NONSTRING_VALUE(@"bold",
                                                                                                   !self.documentFragmentStatus.bold)];
}

- (void)italicAction {
  [self.contentWebView stringByEvaluatingJavaScriptFromString:DOCUMENT_EXECCMD_CMD_NONSTRING_VALUE(@"italic",
                                                                                                   !self.documentFragmentStatus.italic)];
}

- (void)underlineAction {
  [self.contentWebView stringByEvaluatingJavaScriptFromString:DOCUMENT_EXECCMD_CMD_NONSTRING_VALUE(@"underline",
                                                                                                   !self.documentFragmentStatus.underline)];
}

- (void)strikeThroughAction {
  [self.contentWebView stringByEvaluatingJavaScriptFromString:DOCUMENT_EXECCMD_CMD_NONSTRING_VALUE(@"strikeThrough",
                                                                                                   !self.documentFragmentStatus.strikeThrough)];
}

- (void)highlightAction {
  if (self.documentFragmentStatus.highlight) {
    //TODO:sure? self.view.backgroundColor
    NSString *backColor = [CCRTEDocumentFragmentStatus rgbColorStringOfColor:self.view.backgroundColor];
    [self.contentWebView stringByEvaluatingJavaScriptFromString:DOCUMENT_EXECCMD_CMD_STRING_VALUE(@"backColor", backColor)];
  }
  else {
    [self.contentWebView stringByEvaluatingJavaScriptFromString:DOCUMENT_EXECCMD_CMD_STRING_VALUE(@"backColor",
                                                                                                  self.documentFragmentStatus.highlightColorString)];
  }
}

- (void)undoAction {
  [self.contentWebView stringByEvaluatingJavaScriptFromString:DOCUMENT_EXECCMD_CMD(@"undo")];
}

- (void)redoAction {
  [self.contentWebView stringByEvaluatingJavaScriptFromString:DOCUMENT_EXECCMD_CMD(@"redo")];
}

- (void)choosePhoto {
  if (!_photoActionSheet) {
    _photoActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    delegate:self
                                           cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:@"拍照", @"从相册中选择", nil];

  }
  [_photoActionSheet showFromRect:self.photoBtn.frame inView:self.inputAccessoryView animated:YES];
}

- (void)recordAudio {
  [self showAudioMaskView];
  NSString *fileName = [NSString stringWithFormat:@"audio%d", [self.content.audioPaths count]];
  [self.audioViewController record:fileName];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - audio view controller delegate
- (void)audioViewControllerDidStopRecord:(NSString *)audioFilePath {
  [self.maskView hide];
  NSString *js = [NSString stringWithFormat:@"editor.insertSingleAudioFile(%d)", [self.content.audioPaths count]];
  [self.contentWebView stringByEvaluatingJavaScriptFromString:js];
  [self.content.audioPaths addObject:audioFilePath];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - action sheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (0 == buttonIndex) {   //拍照
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
      UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
      imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
      imagePicker.delegate = self;
      [self presentModalViewController:imagePicker animated:YES];
      [imagePicker release];
    }
  }
  else if (1 == buttonIndex) {                    //从相册中选择
    if (!_photoPopController) {
      if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        
        _photoPopController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [imagePicker release];
      }
    }
    
    [_photoPopController presentPopoverFromRect:self.photoBtn.frame
                                         inView:self.inputAccessoryView
                       permittedArrowDirections:UIPopoverArrowDirectionDown
                                       animated:YES];

  }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - image picker
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  if (UIImagePickerControllerSourceTypePhotoLibrary == picker.sourceType) {
    NSURL *referenceUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
      NSString *imagePath = nil;
      imagePath = [self.content.picturePaths objectForKey:[referenceUrl relativeString]];
      if (imagePath) {
        NSString *js = [NSString stringWithFormat:@"editor.insertSingleImage('%@')",
                                                  referenceUrl];
        [self.contentWebView stringByEvaluatingJavaScriptFromString:js];
      }
      else {
        [self savePhotoForKey:[referenceUrl relativeString] withInfo:info];
      }
    }
    
    [_photoPopController dismissPopoverAnimated:YES];
  }
  else {    
    [self savePhotoForKey:nil withInfo:info];
    [self dismissModalViewControllerAnimated:YES];
  }
}

- (void)savePhotoForKey:(NSString *)key withInfo:(NSDictionary *)info{
  NSString *photoName = [NSString stringWithFormat:@"photo%@.png", [NSDate date]];
  NSString *photoKey = (key) ? key : photoName;
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:photoName];
  
  UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
  NSData *data = UIImagePNGRepresentation(image);
  [data writeToFile:imagePath atomically:YES];
  
  NSString *js = [NSString stringWithFormat:@"editor.insertSingleImage('%@', '%@', %f, %f)",
                  photoKey, imagePath, image.size.width, image.size.height];
  [self.contentWebView stringByEvaluatingJavaScriptFromString:js];
  [self.content.picturePaths addEntriesFromDictionary:@{photoKey : imagePath}];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
  [self performSelector:@selector(removeSystemInputAccessoryBar) withObject:nil afterDelay:0];
  
  static int kFixBarOffset = 11;
  NSDictionary *userInfo = [notification userInfo];
  NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
  CGRect rect = [aValue CGRectValue];
  rect = [self.view convertRect:rect fromView:nil];
  rect.size.height = self.inputAccessoryView.frame.size.height;
  rect.origin.y -= kFixBarOffset;
  rect.size.height = self.inputAccessoryView.frame.size.height;
  
  CGRect endRect = rect;
  CGPoint fromPoint = CGPointMake(self.view.frame.size.width / 2,
                                  self.view.frame.size.height + rect.size.height / 2);
  CGPoint toPoint = CGPointMake(self.view.frame.size.width / 2,
                                rect.origin.y + kFixBarOffset - rect.size.height / 2);

  if (self.inputAccessoryView.hidden) {
    CAAnimationGroup *animationGroup = [self showInputAccessoryBarFromPoint:fromPoint toPoint:toPoint];
    [self.inputAccessoryView.layer addAnimation:animationGroup forKey:@"show"];
    self.inputAccessoryView.hidden = NO;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(checkSelection)
                                                userInfo:nil
                                                 repeats:YES];
  }
  self.inputAccessoryView.frame = endRect;
}

- (void)removeSystemInputAccessoryBar {
  UIWindow *keyboardWindow = nil;
  for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
    if (![[testWindow class] isEqual:[UIWindow class]]) {
      keyboardWindow = testWindow;
      break;
    }
  }
  
  for (UIView *possibleFormView in [keyboardWindow subviews]) {
    // iOS 5 sticks the UIWebFormView inside a UIPeripheralHostView.
    if ([[possibleFormView description] rangeOfString:@"UIPeripheralHostView"].location != NSNotFound) {
      for (UIView *subviewWhichIsPossibleFormView in [possibleFormView subviews]) {
        if ([[subviewWhichIsPossibleFormView description] rangeOfString:@"UIWebFormAccessory"].location != NSNotFound) {
          [subviewWhichIsPossibleFormView removeFromSuperview];
        }
      }
    }
  }
}

- (void)keyboardWillHide:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
  CGRect endRect = [aValue CGRectValue];
  endRect = [self.view convertRect:endRect fromView:nil];
  endRect.origin.x = 0;
  endRect.origin.y = self.view.frame.size.height;
  endRect.size.height = self.inputAccessoryView.frame.size.height;
  
  if (!self.inputAccessoryView.hidden) {
    CAAnimationGroup *animationGroup = [self hideInputAccessoryBar];
    [self.inputAccessoryView.layer addAnimation:animationGroup forKey:@"hide"];
    [self.timer invalidate];
  }
  self.inputAccessoryView.frame = endRect;
  self.inputAccessoryView.hidden = YES;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - animation
- (CAAnimationGroup *)showInputAccessoryBarFromPoint:(CGPoint)beginPoint toPoint:(CGPoint)endPoint {
  CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position"];
  move.fromValue = [NSValue valueWithCGPoint:beginPoint];
  move.toValue = [NSValue valueWithCGPoint:endPoint];
  move.duration = .2f;
  
  CAKeyframeAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
  opacity.duration = .2f;
  opacity.values = @[@(0), @(1)];
  opacity.calculationMode = kCAAnimationLinear;

  CAAnimationGroup *group = [CAAnimationGroup animation];
  group.animations = @[move,
                       opacity];
  group.duration = .2f;
  group.fillMode = kCAFillModeForwards;

  return group;
}

- (CAAnimationGroup *)hideInputAccessoryBar {
  CAKeyframeAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
  opacity.duration = .3f;
  opacity.values = @[@(1), @(0)];
  opacity.calculationMode = kCAAnimationLinear;
  
  CAAnimationGroup *group = [CAAnimationGroup animation];
  group.animations = @[opacity];
  group.duration = .3f;
  group.fillMode = kCAFillModeForwards;
  
  return group;
}

@end
