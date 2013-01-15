//
//  Category.m
//  toeflGamePad
//
//  Created by Xingyin Zhu on 13-1-6.
//  Copyright (c) 2013年 Xingyin Zhu. All rights reserved.
//

#import "Category.h"

@implementation Category

@synthesize categoryName = _categoryName;
@synthesize progress = _progress;

- (NSComparisonResult) compareProgress: (Category *)other
{
    if (self.progress > other.progress)
    {
        return (NSComparisonResult)NSOrderedDescending;
    }
    else if (self.progress < other.progress)
    {
        return (NSComparisonResult)NSOrderedAscending;
    }
    else
        return (NSComparisonResult)NSOrderedSame;
}

- (void)updateMemCategoryProgressbyWordProgress : (int)totalCurrentProgress withLength : (int)length
{
    NSLog(@"totalCurrentProgress : %d",totalCurrentProgress);
    self.progress = totalCurrentProgress * 1.0 / (50 * length);
    NSLog(@"self.progress : %f",self.progress);
}


@end
