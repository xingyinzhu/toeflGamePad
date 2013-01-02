//
//  WordListViewController.m
//  toeflGamePad
//
//  Created by Xingyin Zhu on 12-12-23.
//  Copyright (c) 2012年 Xingyin Zhu. All rights reserved.
//

#import "WordListViewController.h"
#import "CategoryViewController.h"
#import "WordCell.h"
#import "Word.h"
#import "DictHelper.h"
#import "DetailViewController.h"


static NSString * const WordCellIdentifier = @"WordCell";

@interface WordListViewController ()

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)segmentChanged:(UISegmentedControl *)sender;

@end

@implementation WordListViewController
{
    CategoryViewController *categoryViewController;
    DictHelper *dicthelper;
    //NSMutableArray *wordList;
    //prevent a memory leak
    __weak DetailViewController *detailViewController;
}

@synthesize searchBar = _searchBar;
@synthesize tableView = _tableView;
@synthesize segmentedControl = _segmentedControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)customizeFont
{
    UIFont *font = [UIFont fontWithName:@"Knewave" size:12.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:UITextAttributeFont];
    [self.segmentedControl setTitleTextAttributes:attributes
                                         forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:@"WordCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:@"WordCell"];
    self.tableView.rowHeight = 40;
    
    if (dicthelper == nil)
    {
        dicthelper = [[DictHelper alloc]init];
    }
    
    [dicthelper getWordsByType:0];
    NSLog(@"in word list : %d",[dicthelper.dictArray count]);
    
    [self customizeFont];
    
    [self.tableView reloadData];
}

- (void)showWordListViewWithDuration:(NSTimeInterval)duration
{
    if (categoryViewController == nil)
    {
        categoryViewController = [[CategoryViewController alloc]
                                  initWithNibName:@"CategoryViewController" bundle:nil];
        
        categoryViewController.view.frame = self.view.bounds;
        categoryViewController.view.alpha = 0.0f;
        //categoryViewController.dicthelper = dicthelper;
        
        [self.view addSubview:categoryViewController.view];
        [self addChildViewController:categoryViewController];
        
        [UIView animateWithDuration:duration animations:
         ^{
             categoryViewController.view.alpha = 1.0f;
         } completion:^(BOOL finished)
         {
             [categoryViewController didMoveToParentViewController:self];
         }];
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];

    }
}

- (void)hideWordListViewWithDuration:(NSTimeInterval)duration
{
    if (categoryViewController != nil)
    {
        [categoryViewController willMoveToParentViewController:nil];
        
        [UIView animateWithDuration:duration animations:
         ^{
             categoryViewController.view.alpha = 0.0f;
         }
                         completion:^(BOOL finished)
         {
             [categoryViewController.view removeFromSuperview];
             [categoryViewController removeFromParentViewController];
             categoryViewController = nil;
         }];
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    }
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.searchBar resignFirstResponder];
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        [self hideWordListViewWithDuration:duration];
    }
    else
    {
        [self showWordListViewWithDuration:duration];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (dicthelper.dictArray == nil)
    {
        return 0;
    }
    else
    {
        return [dicthelper.dictArray count];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cell.backgroundColor = [UIColor colorWithRed:228.0f / 255.0f green:215.0f / 255.0f blue:84.0f / 255.0f alpha:1.0f];
}
    
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WordCell *cell = (WordCell *)[tableView dequeueReusableCellWithIdentifier:WordCellIdentifier];
    Word *word = dicthelper.dictArray[indexPath.row];
    [cell configureForWord:word.word];
    [cell configureForProgress:word.progress];
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    if ([dicthelper.dictArray count] == 0)
    {
        return nil;
    }
    else
    {
        return indexPath;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DetailViewController *controller = [[DetailViewController alloc]initWithNibName:@"DetailViewController" bundle:nil];
    
    Word *word = [dicthelper.dictArray objectAtIndex:indexPath.row];
    controller.word = word;
    
    [controller presentInParentViewController:self];
    detailViewController = controller;
}

-(void)handleSearchForTerm:(NSString *)searchTerm
{
    [dicthelper getWordsByPartOfWords:searchTerm];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self handleSearchForTerm:searchBar.text];
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] == 0)
    {
        [dicthelper getWordsByType:self.segmentedControl.selectedSegmentIndex];
        [self.tableView reloadData];
    }
    else
    {
        [self handleSearchForTerm:searchText];
        [self.tableView reloadData];
    }
    
}

#pragma mark segmentedControl
- (IBAction)segmentChanged:(UISegmentedControl *)sender
{
    if (dicthelper != nil)
    {
        [dicthelper getWordsByType:self.segmentedControl.selectedSegmentIndex];
    }
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    [self.tableView reloadData];
}

@end
