//
//  DictHelper.h
//  toeflGamePad
//
//  Created by Xingyin Zhu on 12-12-27.
//  Copyright (c) 2012年 Xingyin Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DictHelper : NSObject

@property (nonatomic, readonly, strong) NSMutableArray *dictArray;
@property (nonatomic, readonly, strong) NSMutableArray *categoryName;

+ (void)StartInitDict;
+ (void)LoadDict;
+ (BOOL)DictIsExist : (NSFileManager *)filemanager;

- (void)loadAllCategorys;

- (void)getWordLists : (NSString *)category type:(NSInteger)typeIndex;

+ (NSString *)getFirstWord;

- (NSMutableArray *)getAllCategory;

@end
