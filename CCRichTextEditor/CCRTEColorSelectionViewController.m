//
//  CCRTEColorSelectionViewController.m
//  CCRichTextEditor
//
//  Created by chenche on 13-3-5.
//  Copyright (c) 2013年 ddrccw. All rights reserved.
//

#import "CCRTEColorSelectionViewController.h"

@interface CCRTEColorSelectionViewController ()
<UITableViewDataSource, UITableViewDelegate>
@property (retain, nonatomic) UITableView *colorTableView;
@property (retain, nonatomic) NSArray *colorArray;
@end

@implementation CCRTEColorSelectionViewController

- (void)dealloc {
  [_colorArray release];
  [_colorTableView release];
  [super dealloc];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
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
  _colorTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
  _colorTableView.autoresizingMask = UIViewAutoResizingFlexibleAll;
  _colorTableView.dataSource = self;
  _colorTableView.delegate = self;
  [self.view addSubview:_colorTableView];
 
  self.colorArray = @[[UIColor blackColor], [UIColor redColor], [UIColor blueColor],
                      [UIColor greenColor], [UIColor yellowColor], [UIColor orangeColor],
                      [UIColor grayColor], [UIColor brownColor], [UIColor purpleColor], 
                      [UIColor magentaColor], [UIColor whiteColor]];
  
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - table view data source and delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.colorArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *Identifier = @"FontCellIdentifier";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
  if (!cell) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:Identifier] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  
  UIColor *color = [self.colorArray objectAtIndex:indexPath.row];
  cell.contentView.backgroundColor = color;
  return cell;
}


@end
