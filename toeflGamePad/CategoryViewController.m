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
}

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControll;
@synthesize myToeflMode = _myToeflGamePadMode;

- (void)updateCategoryProgressinView
{
    NSArray * attributeids = [[DictHelper instanceCategoryDict] allKeys];
    for (NSNumber *attribute_id in attributeids)
    {
        NSInteger id = 2000 + [attribute_id integerValue];
        
        UIView * btn = [self.scrollView viewWithTag:id];
        if (btn == nil || btn.tag == 1999)
        {
            continue;
        }
        else
        {
            Category * category = [[DictHelper instanceCategoryDict]objectForKey:attribute_id];
            //[1] is UIProgressView
            UIProgressView * progress  = (UIProgressView *)[btn subviews][1];
            //if (category.progress > 0.01)
            //{
                //NSLog(@"%@",category.categoryName);
                //NSLog(@"%f",category.progress);
            //}
            progress.progress = category.progress;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"testing in viewWillAppear");
    [super viewWillAppear:animated];
    [self updateCategoryProgressinView];
}

- (void)viewDidLoad
{
    NSLog(@"testing in viewDidLoad");
    [super viewDidLoad];
    
    self.scrollView.contentSize = CGSizeMake(1000, self.scrollView.bounds.size.height);
    
    if (dicthelper == nil)
    {
        dicthelper = [[DictHelper alloc]init];
    }
    
    hasReviewedNumber = [DictHelper fetchAllCategory];
    if (self.myToeflMode == toeflTestMode)
    {
        if (hasReviewedNumber == 0)
        {
#pragma mark todo
            /*
            UIAlertView * noTestCategoryAlertView = [[UIAlertView alloc]
                                                     initWithTitle:@"No Test Items"
                                                     message:@"You should review items in review mode!"
                                                     delegate:self
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:@"Ok", nil];
            [noTestCategoryAlertView setTag:1];
            [noTestCategoryAlertView show];
            */
        }
    }
    categoryNumber = [[DictHelper instanceCategoryDict] count];
    if (self.myToeflMode == toeflTestMode)
    {
        [self tileCategoryButton4TestMode];
    }
    else if (self.myToeflMode == toeflReviewMode)
    {
        [self tileCategoryButton4ReviewMode];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)//finish all
    {
        [self backtoStartView];
    }
}

- (void)addRandomButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0*itemWidth + marginHorz, 0*itemHeight + marginVert, buttonWidth, buttonHeight);
    [button setTitle:[NSString stringWithFormat:@"随便玩玩"] forState:UIControlStateNormal];
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
- (void)tileCategoryButton4TestMode
{
    int index = 0;
    int row = 1;
    int column = 0;
    NSArray * attributeids = [[DictHelper instanceCategoryDict] allKeys];
    [self addRandomButton];
    
    for (NSNumber *attribute_id in attributeids)
    {
        Category * category = [[DictHelper instanceCategoryDict] objectForKey:attribute_id];
        if (category.progress < hasReviewed)
        {
            continue;
        }
        
        //NSLog(@"category.categoryName : %@",category.categoryName);
        //NSLog(@"category.progress : %f",category.progress);
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(column*itemWidth + marginHorz, row*itemHeight + marginVert, buttonWidth, buttonHeight);
        [button setTitle:[NSString stringWithFormat:@"%@", category.categoryName] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
        UIProgressView * progress = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        progress.frame = CGRectMake(0*itemWidth + 15, 0*itemHeight + 60, 50, 1);
        progress.progress = category.progress;
        //NSLog(@"category.progress : %f",category.progress);
        [button addSubview:progress];
        
        
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
    NSLog(@"hasReviewedNumber : %d",hasReviewedNumber);
    int numPages = ceilf(hasReviewedNumber / 18.0f);
    self.scrollView.contentSize = CGSizeMake(numPages*480.0f, self.scrollView.bounds.size.height);
    self.pageControl.numberOfPages = numPages;
    self.pageControl.currentPage = 0;
}

- (void)tileCategoryButton4ReviewMode
{
    int index = 0;
    int row = 0;
    int column = 0;
    NSArray * attributeids = [[DictHelper instanceCategoryDict] allKeys];
    
    for (NSNumber *attribute_id in attributeids)
    {
        Category * category = [[DictHelper instanceCategoryDict] objectForKey:attribute_id];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(column*itemWidth + marginHorz, row*itemHeight + marginVert, buttonWidth, buttonHeight);
        [button setTitle:[NSString stringWithFormat:@"%@", category.categoryName] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        if (category.progress >= hasReviewed)
        {
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else
        {
            [button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        }
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
     
        UIProgressView * progress = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        progress.frame = CGRectMake(0*itemWidth + 15, 0*itemHeight + 60, 50, 1);
        progress.progress = category.progress;
        //NSLog(@"category.progress : %f",category.progress);
        [button addSubview:progress];
        
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
    
    int numPages = ceilf(categoryNumber / 18.0f);
    self.scrollView.contentSize = CGSizeMake(numPages*480.0f, self.scrollView.bounds.size.height);
    self.pageControl.numberOfPages = numPages;
    self.pageControl.currentPage = 0;
}

- (void)buttonPressed:(UIButton *)sender
{
    int categoryid = sender.tag-2000;
    NSNumber *aWrappedId = [NSNumber numberWithInteger:categoryid];
    if ( self.myToeflMode == toeflTestMode)
    {
        GamePadViewController * gamePadViewController = [[GamePadViewController alloc]initWithNibName:@"GamePadViewController" bundle:nil];
        gamePadViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        gamePadViewController.wordGroup = aWrappedId;
        [self presentViewController:gamePadViewController animated:YES completion:nil];
    }
    else if (self.myToeflMode == toeflReviewMode)
    {
        WordListViewController * wordListViewController = [[WordListViewController alloc]initWithNibName:@"WordListViewController" bundle:nil];
        wordListViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        wordListViewController.wordGroup = aWrappedId;
        [self presentViewController:wordListViewController animated:YES completion:nil];
        
        [DictHelper updateHasReviewed:categoryid];
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
