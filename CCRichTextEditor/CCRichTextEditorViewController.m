//
//  ViewController.m
//  CCRichTextEditor
//
//  Created by chenche on 13-3-1.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import "CCRichTextEditorViewController.h"
#import "CCRTEAccessorySwitch.h"
#import "CCRTEFontSelectionViewController.h"
#import "CCRTEColorSelectionViewController.h"
#import <CoreText/CoreText.h>

@interface CCRichTextEditorViewController () <UITextFieldDelegate>
@property (retain, nonatomic) IBOutlet UIWebView *contentWebView;
@property (retain, nonatomic) IBOutlet UIView *inputAccessoryView;

@property (retain, nonatomic) IBOutlet UIButton *fontBtn;
@property (retain, nonatomic) IBOutlet UIButton *fontColorBtn;
@property (retain, nonatomic) IBOutlet CCRTEAccessorySwitch *boldSwitch;
@property (retain, nonatomic) IBOutlet CCRTEAccessorySwitch *italicSwitch;
@property (retain, nonatomic) IBOutlet CCRTEAccessorySwitch *underlineSwitch;
@property (retain, nonatomic) UIPopoverController *fontPopController;
@property (retain, nonatomic) UIPopoverController *fontColorPopController;
@property (retain, nonatomic) IBOutlet UIButton *photoBtn;
@property (retain, nonatomic) UIActionSheet *photoActionSheet;
@end

@implementation CCRichTextEditorViewController

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_fontBtn removeTarget:self action:@selector(chooseFont) forControlEvents:UIControlEventTouchUpInside];
  [_fontColorBtn removeTarget:self action:@selector(chooseFontColor) forControlEvents:UIControlEventTouchUpInside];
  [_photoBtn removeTarget:self action:@selector(choosePhoto) forControlEvents:UIControlEventTouchUpInside];
  [_contentWebView release];
  [_fontBtn release];
  [_fontColorBtn release];
  [_boldSwitch release];
  [_italicSwitch release];
  [_underlineSwitch release];
  [_fontPopController release];
  [_fontColorPopController release];
  [_photoBtn release];
  [_photoActionSheet release];
  [super dealloc];
}

- (void)viewDidUnload {
  [self setContentWebView:nil];
  [self setFontBtn:nil];
  [self setFontColorBtn:nil];
  [self setBoldSwitch:nil];
  [self setItalicSwitch:nil];
  [self setUnderlineSwitch:nil];
  self.fontPopController = nil;
  self.fontColorPopController = nil;
  [self setPhotoBtn:nil];
  self.photoActionSheet = nil;
  [super viewDidUnload];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [_contentWebView setBackgroundColor:[UIColor clearColor]];
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return YES;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - inputAccessoryView
- (void)initAccessoryView {
  [self.view addSubview:self.inputAccessoryView];
  self.inputAccessoryView.hidden = YES;
  UIImage *barImage = [[UIImage imageNamed:@"customKeyboardBar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
  self.inputAccessoryView.backgroundColor = [UIColor colorWithPatternImage:barImage];

  [self.fontBtn addTarget:self action:@selector(chooseFont) forControlEvents:UIControlEventTouchUpInside];
  [self.fontColorBtn addTarget:self action:@selector(chooseFontColor) forControlEvents:UIControlEventTouchUpInside];
  
  //Bold, Italic, Underline
  const int kFontSize = 17;
  UIFont *font = [UIFont systemFontOfSize:kFontSize];
  NSDictionary *normalFontAttributes = @{(id)kCTFontAttributeName :
                                         (id)CTFontCreateWithName((CFStringRef)font.fontName, kFontSize, NULL)};
  NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"B" attributes:normalFontAttributes];
  
  UIFont *selectedFont = [UIFont boldSystemFontOfSize:kFontSize];
  NSMutableDictionary *selectedFontAttributes = [[NSMutableDictionary alloc] initWithDictionary:@{(id)kCTFontAttributeName :
                                                                                                  (id)CTFontCreateWithName((CFStringRef)selectedFont.fontName, kFontSize, NULL)}];
  NSAttributedString *selectTitle = [[NSAttributedString alloc] initWithString:@"B" attributes:selectedFontAttributes];
  [self.boldSwitch setTitle:title selectedTitle:selectTitle backgroundImage:nil selectedImage:nil];
  [title release];
  [selectTitle release];
  [selectedFontAttributes release];
  
  selectedFont = [UIFont italicSystemFontOfSize:kFontSize];
  selectedFontAttributes = [[NSMutableDictionary alloc] initWithDictionary:@{(id)kCTFontAttributeName :
                                                                             (id)CTFontCreateWithName((CFStringRef)selectedFont.fontName, kFontSize, NULL)}];
  title = [[NSAttributedString alloc] initWithString:@"I" attributes:normalFontAttributes];
  selectTitle = [[NSAttributedString alloc] initWithString:@"I" attributes:selectedFontAttributes];
  [self.italicSwitch setTitle:title selectedTitle:selectTitle backgroundImage:nil selectedImage:nil];
  [title release];
  [selectTitle release];
  [selectedFontAttributes release];
  
  selectedFontAttributes = [normalFontAttributes mutableCopy];
  [selectedFontAttributes addEntriesFromDictionary:@{(id)kCTUnderlineStyleAttributeName : @(kCTUnderlineStyleSingle)}];
  title = [[NSAttributedString alloc] initWithString:@"U" attributes:normalFontAttributes];
  selectTitle = [[NSAttributedString alloc] initWithString:@"U" attributes:selectedFontAttributes];
  [self.underlineSwitch setTitle:title selectedTitle:selectTitle backgroundImage:nil selectedImage:nil];
  [title release];
  [selectTitle release];
  [selectedFontAttributes release];
  
  [self.photoBtn addTarget:self action:@selector(choosePhoto) forControlEvents:UIControlEventTouchUpInside];
}

- (void)chooseFont {
  if (!_fontPopController) {
    CCRTEFontSelectionViewController *fontSelectionVC = [CCRTEFontSelectionViewController new];
    fontSelectionVC.customizedFontArray = @[@"Kai Regular", @"宋体"];  //font Name not file name
//    fontSelectionVC.delegate = self;
    _fontPopController = [[UIPopoverController alloc] initWithContentViewController:fontSelectionVC];
    _fontPopController.popoverContentSize = CGSizeMake(200, 400);
  }
  
  [self.fontPopController presentPopoverFromRect:self.fontBtn.frame
                                          inView:self.inputAccessoryView
                        permittedArrowDirections:UIPopoverArrowDirectionDown
                                        animated:YES];
}

- (void)chooseFontColor {
  if (!_fontColorPopController) {
    CCRTEColorSelectionViewController *colorSelectionVC = [CCRTEColorSelectionViewController new];
    //    fontSelectionVC.delegate = self;
    _fontColorPopController = [[UIPopoverController alloc] initWithContentViewController:colorSelectionVC];
    _fontColorPopController.popoverContentSize = CGSizeMake(200, 400);
  }
  
  [self.fontColorPopController presentPopoverFromRect:self.fontColorBtn.frame
                                          inView:self.inputAccessoryView
                        permittedArrowDirections:UIPopoverArrowDirectionDown
                                        animated:YES];
}

- (void)choosePhoto {
  if (!_photoActionSheet) {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select a font color" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Blue", @"Yellow", @"Green", @"Red", @"Orange", nil];

  }
  [_photoActionSheet showFromRect:self.photoBtn.frame inView:self.inputAccessoryView animated:YES];
}
////////////////////////////////////////////////////////////////////////////////
#pragma mark - keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
  [self performSelector:@selector(removeSystemInputAccessoryBar) withObject:nil afterDelay:0];
  
  static int kFixBarOffset = 5;
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
  }
  self.inputAccessoryView.frame = endRect;
  self.inputAccessoryView.hidden = NO;
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
