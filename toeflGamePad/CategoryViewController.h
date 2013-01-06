//
//  CategoryViewController.h
//  toeflGamePad
//
//  Created by Xingyin Zhu on 12-12-20.
//  Copyright (c) 2012年 Xingyin Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DictHelper;

@interface CategoryViewController : UIViewController

typedef enum
{
    toeflGameReviewMode,
    toeflGameTestMode
}toeflGamePadMode;

@property (nonatomic, assign) toeflGamePadMode myToeflGamePadMode;


- (IBAction)backtoStartView;

@end
