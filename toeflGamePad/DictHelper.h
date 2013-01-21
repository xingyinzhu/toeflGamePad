//
//  DictHelper.h
//  toeflGamePad
//
//  Created by Xingyin Zhu on 12-12-27.
//  Copyright (c) 2012年 Xingyin Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DictHelper : NSObject

@property (nonatomic, readonly, strong) NSMutableArray * dictArray;
@property (nonatomic, readonly, strong) NSMutableArray * backupDictArray;

//@property (nonatomic, readonly, strong) NSMutableArray * categoryName;

+(NSMutableDictionary *)instanceCategoryDict;
+ (void)StartInitDict;
+ (void)LoadDict;
+ (BOOL)DictIsExist : (NSFileManager *)filemanager;

+ (NSString *)getFirstWord;

+ (void) loadAllWordObejctIntoDict;

+ (NSInteger)fetchAllCategory;

+ (void)updateHasReviewed: (NSInteger)type;
- (void)getWordsByType: (NSInteger)type;

- (void)getWordsByPartOfWords: (NSString *)partOfWord;

- (void)getWordsByGroupEx: (NSInteger)group;
+ (NSMutableArray *)getWordsByGroup: (NSInteger)group;
+ (NSMutableArray *)getRandomWords;

+ (void)updateProgress: (NSMutableArray *)progress withWordArray: (NSMutableArray *)wordArray withCategoryId : (NSInteger)categoryid;

+ (void)restartCategory: (NSInteger)categoryid;

+ (void)closeDataBase;
@end
