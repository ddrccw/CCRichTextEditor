//
//  CCFontSelectionViewController.m
//  CCRichTextEditor
//
//  Created by ddrccw on 13-3-4.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import "CCRTEFontSelectionViewController.h"

@interface CCRTEFontSelectionViewController ()
<UITableViewDelegate, UITableViewDataSource>
@property (retain, nonatomic) UITableView *fontTableView;
@property (retain, nonatomic) NSMutableArray *fontArray;
@end

@implementation CCRTEFontSelectionViewController

- (void)dealloc {
  [_fontTableView release];
  [super dealloc];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
      // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  _fontTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  _fontTableView.autoresizingMask = UIViewAutoResizingFlexibleAll;
  _fontTableView.dataSource = self;
  _fontTableView.delegate = self;
  [self.view addSubview:_fontTableView];
  
  if (!self.fontArray) {
    self.fontArray = [NSMutableArray array];
  }
  
  NSArray *fontFamilyArray = [UIFont familyNames];
  [fontFamilyArray enumerateObjectsUsingBlock:^(NSString *familyName, NSUInteger idx, BOOL *stop){
//    NSLog(@"%@", familyName);
    [self.fontArray addObjectsFromArray:[UIFont fontNamesForFamilyName:familyName]];
  }];

  NSPredicate *predict = [NSPredicate predicateWithFormat:@"!(self CONTAINS[c] 'bold' || self CONTAINS[c] 'italic')"];
  _fontArray = [[self.fontArray filteredArrayUsingPredicate:predict] mutableCopy];
}

- (void)setCustomizedFontArray:(NSArray *)customizedFontArray {
  if (_customizedFontArray != customizedFontArray) {
    [_customizedFontArray release];
    _customizedFontArray = [customizedFontArray retain];
    if (!_fontArray) {
      _fontArray = [[NSMutableArray alloc] initWithCapacity:[_customizedFontArray count]];
    }
    
    [_fontArray addObjectsFromArray:_customizedFontArray];
  }
}
////////////////////////////////////////////////////////////////////////////////
#pragma mark - table view data source and delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.fontArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *Identifier = @"FontCellIdentifier";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
  if (!cell) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                   reuseIdentifier:Identifier] autorelease];
  }
  
  NSString *fontName = [self.fontArray objectAtIndex:indexPath.row];
  cell.textLabel.text = fontName;
  cell.textLabel.font = [UIFont fontWithName:fontName size:17];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *fontName = [self.fontArray objectAtIndex:indexPath.row];
  if ([self.delegate respondsToSelector:@selector(didSelectFont:)]) {
    [self.delegate didSelectFont:[UIFont fontWithName:fontName size:[UIFont systemFontSize]]];
  }
}
@end
