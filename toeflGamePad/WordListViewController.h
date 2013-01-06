//
//  WordListViewController.h
//  toeflGamePad
//
//  Created by Xingyin Zhu on 12-12-23.
//  Copyright (c) 2012年 Xingyin Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WordListViewController : UIViewController<UITableViewDataSource,
                                        UITableViewDelegate,UISearchBarDelegate>

@property (nonatomic, strong) NSNumber * wordGroup;

- (IBAction)backToCategoryView;
@end
