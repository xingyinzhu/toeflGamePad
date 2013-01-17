//
//  Category.h
//  toeflGamePad
//
//  Created by Xingyin Zhu on 13-1-6.
//  Copyright (c) 2013年 Xingyin Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Category : NSObject

@property (nonatomic, copy)NSString * categoryName;
@property (nonatomic, assign)float progress;

typedef enum
{
    hasNotReviewed = -1,
    hasReviewed = 0
}CategoryDisplayMode;

- (NSComparisonResult) compareProgress: (Category *)other;

- (void)updateMemCategoryProgressbyWordProgress : (int)totalCurrentProgress withLength : (int)length;

- (BOOL)updateCategoryProgressByOneScore : (int)score withLength : (int)length;

@end
