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
    toeflReviewMode,
    toeflTestMode
}toeflMode;

@property (nonatomic, assign) toeflMode myToeflMode;
@property (nonatomic, weak) NSString * device_name;

- (IBAction)backtoStartView;

@end
