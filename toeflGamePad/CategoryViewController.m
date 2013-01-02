//
//  CategoryViewController.m
//  toeflGamePad
//
//  Created by Xingyin Zhu on 12-12-20.
//  Copyright (c) 2012年 Xingyin Zhu. All rights reserved.
//

#import "CategoryViewController.h"
#import "GamePadViewController.h"
#import "DictHelper.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>

@interface CategoryViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

- (IBAction)pageChanged:(UIPageControl *)sender;

@end

const CGFloat itemWidth = 80.0f;
const CGFloat itemHeight = 66.0f;
const CGFloat buttonWidth = 80.0f;
const CGFloat buttonHeight = 66.0f;
const CGFloat marginHorz = (itemWidth - buttonWidth)/2.0f;
const CGFloat marginVert = (itemHeight - buttonHeight)/2.0f;

@implementation CategoryViewController
{
    
    NSInteger categoryNumber;
    DictHelper *dicthelper;
    
}

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControll;

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
    
    [dicthelper fetchAllCategory];
    
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
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(column*itemWidth + marginHorz, row*itemHeight + marginVert, buttonWidth, buttonHeight);
        [button setTitle:[NSString stringWithFormat:@"%@", [dicthelper.categoryDict objectForKey:attribute_id]] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
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
        if (row == 4)
        {
            row = 0;
            column ++;
        }
    }
    
    int numPages = ceilf(categoryNumber / 24.0f);
    self.scrollView.contentSize = CGSizeMake(numPages*480.0f, self.scrollView.bounds.size.height);
    
    self.pageControl.numberOfPages = numPages;
    self.pageControl.currentPage = 0;
    
}

- (void)buttonPressed:(UIButton *)sender
{
    //GamePadViewController *gamePadViewController = [[GamePadViewController alloc]initWithNibName:@"GamePadViewController" bundle:nil];
    //[self presentViewController:gamePadViewController animated:YES completion:nil];
    
    NSNumber *aWrappedId = [NSNumber numberWithInteger:sender.tag-2000];
    //NSString *groups = [dicthelper.categoryDict objectForKey:aWrappedId];
    
    GamePadViewController *gamePadViewController = [[GamePadViewController alloc]initWithNibName:@"GamePadViewController" bundle:nil];  
    gamePadViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    gamePadViewController.wordGroup = aWrappedId;
    [self presentViewController:gamePadViewController animated:YES completion:nil];

    //NSLog(@"%d : %@",sender.tag-2000,groups);
    
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



@end
