//
//  CategoryViewController.m
//  toeflGamePad
//
//  Created by Xingyin Zhu on 12-12-20.
//  Copyright (c) 2012年 Xingyin Zhu. All rights reserved.
//

#import "CategoryViewController.h"
#import "GamePadViewController.h"
#import "WordListViewController.h"
#import "DictHelper.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>
#import "Category.h"

@interface CategoryViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

- (IBAction)pageChanged:(UIPageControl *)sender;

@end

const CGFloat itemWidth = 80.0f;
const CGFloat itemHeight = 73.0f;
const CGFloat buttonWidth = 80.0f;
const CGFloat buttonHeight = 73.0f;
const CGFloat marginHorz = (itemWidth - buttonWidth)/2.0f;
const CGFloat marginVert = (itemHeight - buttonHeight)/2.0f;

@implementation CategoryViewController
{
    
    NSInteger categoryNumber;
    NSInteger hasReviewedNumber;
    DictHelper *dicthelper;
    WordListViewController *wordListViewController;
    GamePadViewController *gamePadViewController;
    
}

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControll;
@synthesize myToeflGamePadMode = _myToeflGamePadMode;

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
    
    self.scrollView.contentSize = CGSizeMake(1000, self.scrollView.bounds.size.height);
    
    if (dicthelper == nil)
    {
        dicthelper = [[DictHelper alloc]init];
    }
    
    hasReviewedNumber = [dicthelper fetchAllCategory];
    if (self.myToeflGamePadMode == toeflGameTestMode)
    {
        if (hasReviewedNumber == 0)
        {
            
        }
    }
    categoryNumber = [dicthelper.categoryDict count];
    
    [self tileCategoryButton];
}

- (void)addRandomButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0*itemWidth + marginHorz, 0*itemHeight + marginVert, buttonWidth, buttonHeight);
    //UIImage *image = [UIImage imageNamed:@"random"];
    //image = [image resizedImageWithBounds:CGSizeMake(48, 48)];
    //[button setBackgroundImage:image forState:UIControlStateNormal];
    [button setTitle:[NSString stringWithFormat:@"随机"] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    button.tag = 1999;
    [button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:button];
}

/*
- (void)customizeButtonStyle: (UIButton *)button withColumn:(NSUInteger)column withRow:(NSUInteger)row 
{
    

}
*/

- (void)tileCategoryButton
{
    int index = 0;
    int row = 1;
    int column = 0;
    
    NSArray * attributeids = [dicthelper.categoryDict allKeys];
    
    [self addRandomButton];
    
    for (NSNumber *attribute_id in attributeids)
    {
        Category * category = [dicthelper.categoryDict objectForKey:attribute_id];
        if (self.myToeflGamePadMode == toeflGameTestMode && category.progress == hasNotReviewed)
        {
            continue;
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(column*itemWidth + marginHorz, row*itemHeight + marginVert, buttonWidth, buttonHeight);
        [button setTitle:[NSString stringWithFormat:@"%@", category.categoryName] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        if ((self.myToeflGamePadMode == toeflGameReviewMode && category.progress >= hasReviewed) || self.myToeflGamePadMode == toeflGameTestMode)
        {
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else
        {
            [button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        }
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        /*
        CALayer * btnLayer = [button layer];
        [btnLayer setBorderWidth:0.5f];
        [btnLayer setBorderColor:[[UIColor yellowColor] CGColor]];
        */
        
        
        NSInteger attributeInt = [attribute_id integerValue];
        button.tag = 2000 + attributeInt;
        
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        
        index ++;
        row++;
        if (row == 3)
        {
            row = 0;
            column ++;
        }
    }
    int numPages;
    if (self.myToeflGamePadMode == toeflGameReviewMode)
    {
        numPages = ceilf(categoryNumber / 18.0f);
    }
    else
    {
        numPages = ceilf(hasReviewedNumber / 18.0f);
    }
    
    self.scrollView.contentSize = CGSizeMake(numPages*480.0f, self.scrollView.bounds.size.height);
    
    self.pageControl.numberOfPages = numPages;
    self.pageControl.currentPage = 0;
    
}

- (void)buttonPressed:(UIButton *)sender
{
    int categoryid = sender.tag-2000;
    NSNumber *aWrappedId = [NSNumber numberWithInteger:categoryid];
    if ( self.myToeflGamePadMode == toeflGameTestMode)
    {
        if (gamePadViewController == nil)
        {
            gamePadViewController = [[GamePadViewController alloc]initWithNibName:@"GamePadViewController" bundle:nil];
        }
        gamePadViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        gamePadViewController.wordGroup = aWrappedId;
        [self presentViewController:gamePadViewController animated:YES completion:nil];
    }
    else if (self.myToeflGamePadMode == toeflGameReviewMode)
    {
        if (wordListViewController == nil)
        {
            wordListViewController = [[WordListViewController alloc]initWithNibName:@"WordListViewController" bundle:nil];
        }
        wordListViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        wordListViewController.wordGroup = aWrappedId;
        [self presentViewController:wordListViewController animated:YES completion:nil];

        [dicthelper updateHasReviewed:categoryid];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)theScrollView
{
    CGFloat width = self.scrollView.bounds.size.width;
    int currentPage = (self.scrollView.contentOffset.x + width/2.0f) / width;
    self.pageControl.currentPage = currentPage;
}


- (IBAction)pageChanged:(UIPageControl *)sender
{
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width * sender.currentPage, 0);
    } completion:nil];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

-(BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (IBAction)backtoStartView
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
