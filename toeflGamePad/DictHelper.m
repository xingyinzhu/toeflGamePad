//
//  DictHelper.m
//  toeflGamePad
//
//  Created by Xingyin Zhu on 12-12-27.
//  Copyright (c) 2012年 Xingyin Zhu. All rights reserved.
//

#import "DictHelper.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "Word.h"
#import "Category.h"
#import "NSMutableArray+Shuffling.h"

@interface DictHelper()

@property (nonatomic, readwrite, strong) NSMutableArray * dictArray;
@property (nonatomic, readwrite, strong) NSMutableArray * backupDictArray;

@end

static NSString * dictPath;
static FMDatabase *dictDataBase;
static NSMutableDictionary *allDict;
static NSMutableDictionary *categoryDict;

@implementation DictHelper

@synthesize dictArray = _dictArray;
@synthesize backupDictArray = _backupDictArray;

+(NSMutableDictionary *)instanceCategoryDict
{
    return categoryDict;
}

+ (void)StartInitDict
{
    if (dictPath == nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsPath = [paths objectAtIndex:0];
        NSString *realPath = [docsPath stringByAppendingPathComponent:@"dict.db"];
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"dict" ofType:@"db"];

        dictPath = realPath;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSLog(@"%@",realPath);
        if (![DictHelper DictIsExist:fileManager])
        {
            NSError *error;
            NSLog(@"copying ...");
            if (![fileManager copyItemAtPath:sourcePath toPath:dictPath error:&error])
            {
                NSLog(@"%@", [error localizedDescription]);
            }
        }
    }
    
}

+ (void)LoadDict
{
    if (dictDataBase == nil)
    {
        if (dictPath != nil)
        {
            dictDataBase = [FMDatabase databaseWithPath:dictPath];
        }
    }
}

+ (void)OpenDict
{
    if (![dictDataBase open])
    {
        NSLog(@"Open dict failed!");
        return;
    }
}

+ (void)loadAllWordObejctIntoDict
{
    
    [self OpenDict];
    
    if (allDict == nil)
    {
        allDict = [[NSMutableDictionary alloc]init];
        
        NSString * sql = @"select w.word, w.englishmark, w.americamark, w.meanings,w.hint, p.value from words w, progress p where p.word = w.word";
        FMResultSet *result = [dictDataBase executeQuery:sql];
        int cnt = 0;
        while ([result next])
        {
            Word * tmpWord = [[Word alloc]init];
            tmpWord.word = [result stringForColumn:@"word"];
            tmpWord.englishmark = [result stringForColumn:@"englishmark"];
            tmpWord.americamark = [result stringForColumn:@"americamark"];
            tmpWord.meanings = [result stringForColumn:@"meanings"];
            tmpWord.progress = [result intForColumn:@"value"];
            tmpWord.hint = [result stringForColumn:@"hint"];
            [allDict setObject:tmpWord forKey:tmpWord.word];
            cnt ++;
        }
        NSLog(@"all word number : %d",cnt);
    }
    
    [dictDataBase close];
}

+ (NSInteger)fetchAllCategory
{
    [self OpenDict];
    
    NSLog(@"in fetchAllCategory");
    
    if (categoryDict == nil)
    {
        categoryDict = [[NSMutableDictionary alloc]init];
        
        NSString * sql = @"select * from attribute_id";
        FMResultSet *result = [dictDataBase executeQuery:sql];
        
        while ([result next])
        {
            NSInteger attribute_id = [result intForColumn:@"attributeid"];
            NSNumber *aWrappedId = [NSNumber numberWithInteger:attribute_id];
            
            NSString * selectSql = [NSString stringWithFormat:@"select count(*) from attribute where groups = %d",attribute_id];
            NSUInteger count = [dictDataBase intForQuery:selectSql];
            
            NSString * attribute_name = [result stringForColumn:@"attributename"];
            NSInteger progress = [result intForColumn:@"progress"];
          
            Category * category = [[Category alloc]init];
            [category updateMemCategoryProgressbyWordProgress:progress withLength:count];
            category.categoryName = attribute_name;
            [categoryDict setObject:category forKey:aWrappedId];
        }
    }
    
    NSUInteger hasReviewedNumber = [dictDataBase intForQuery:@"select count(*) from attribute_id where progress = 0"];
    [dictDataBase close];
    return hasReviewedNumber;
}

//invoke after function : updateProgress
+ (void)updateCategoryProgress: (NSInteger)categoryid withCategoryProgress : (NSInteger)progress
{
    [self OpenDict];
    BOOL success;
    NSString * updateSql;
    updateSql = [NSString stringWithFormat:@"update attribute_id set progress = %d where attributeid = %d",progress,categoryid];
    
    NSLog(@"%@",updateSql);
    success =  [dictDataBase executeUpdate:updateSql];

    if (success)
    {
        NSLog(@"updateCategoryProgress categoryid : %d successfully",categoryid);
    }
    else
    {
        NSLog(@"FAIL");
    }
    [dictDataBase close];
}


+ (void)updateHasReviewed: (NSInteger)type
{
    [self OpenDict];
    
    NSString * selectSql;
    NSString * updateSql;
    NSInteger value; 
    selectSql = [NSString stringWithFormat:@"select progress from attribute_id where attributeid = %d",type];
    FMResultSet * progressResult = [dictDataBase executeQuery:selectSql];
    while ([progressResult next])
    {
        value = [progressResult intForColumn:@"progress"];
        break;
    }
    
    if (value == hasNotReviewed)
    {
        BOOL success;
        updateSql = [NSString stringWithFormat:@"update attribute_id set progress = %d where attributeid = %d",hasReviewed,type];
        success =  [dictDataBase executeUpdate:updateSql];
        
        NSNumber *aWrappedId = [NSNumber numberWithInteger:type];
        Category * category = [categoryDict objectForKey:aWrappedId];
        category.progress = hasReviewed;
        NSLog(@"%@",updateSql);
        if (success)
        {
            NSLog(@"updateHasReviewed %d successfully!",type);
        }
        else
        {
            NSLog(@"FAIL");
        }
    }
    [dictDataBase close];
}

+ (BOOL)DictIsExist:(NSFileManager *)filemanager
{
    return [filemanager fileExistsAtPath:dictPath];
}

+ (NSString *)getFirstWord
{
    [self OpenDict];
    
    NSString * sql = @"select * from words";
    FMResultSet *result = [dictDataBase executeQuery:sql];
    while ([result next])
    {
        NSString *a = [result stringForColumn:@"englishmark"];
        [dictDataBase close];
        return a;
    }
    [dictDataBase close];
    return nil;
}

- (void)getWordsByType: (NSInteger)type
{
    [DictHelper OpenDict];
    NSString * sql = @"select word from attribute";
    NSString * where;
    if (type == 0)
    {
        where = @"";
    }
    else
    {
        where = [NSString stringWithFormat:@" where type = %d",type];
    }
    
    NSString * execSql = [sql stringByAppendingString:where];
    NSLog(@"%@",execSql);
    FMResultSet *result = [dictDataBase executeQuery:execSql];
    
    if (self.dictArray == nil)
    {
        self.dictArray = [[NSMutableArray alloc]init];
    }
    else
    {
        [self.dictArray removeAllObjects];
    }

    while ([result next])
    {
        NSString * word = [result stringForColumn:@"word"];
        Word * tmpWord = [allDict objectForKey:word];
        
        if (tmpWord == nil)
        {
            NSLog(@"%@",word);
        }
        [self.dictArray addObject:tmpWord];
    }
    [self.dictArray sortUsingSelector:@selector(compareName:)];
    [dictDataBase close];
}

- (void)getWordsByPartOfWords: (NSString *)partOfWord
{
    if ([partOfWord length] == 0)
    {
        self.dictArray = [self.backupDictArray mutableCopy];
        return;
    }
    
    if (self.dictArray == nil)
    {
        self.dictArray = [[NSMutableArray alloc]init];
    }
    else
    {
        [self.dictArray removeAllObjects];
    }
    
    for (Word * tmpWord in self.backupDictArray)
    {
        if ([tmpWord.word hasPrefix:partOfWord])
        {
            [self.dictArray addObject:tmpWord];
        }
    }
        
    [self.dictArray sortUsingSelector:@selector(compareName:)];
}

//for WordListViewController
- (void)getWordsByGroupEx: (NSInteger)group
{
    [DictHelper OpenDict];
    NSString * selectSql = [NSString stringWithFormat:@"select w.word from words w, attribute a where a.word = w.word and a.groups = %d", group];
    FMResultSet *result = [dictDataBase executeQuery:selectSql];
    
    if (self.dictArray == nil)
    {
        self.dictArray = [[NSMutableArray alloc]init];
    }
    else
    {
        [self.dictArray removeAllObjects];
    }
    
    while ([result next])
    {
        NSString * word = [result stringForColumn:@"word"];
        Word * tmpWord = [allDict objectForKey:word];
        
        if (tmpWord == nil)
        {
            NSLog(@"%@",word);
        }
        
        [self.dictArray addObject:tmpWord];
    }
    //[self.dictArray sortUsingSelector:@selector(compareName:)];
    [self.dictArray sortUsingSelector:@selector(compareProgress:)];
    self.backupDictArray = [self.dictArray mutableCopy];
    
    [dictDataBase close];
}


//for GamePadViewController
+ (BOOL)wordIsFinished: (NSString *)word
{
    [self OpenDict];
    //Word * tmpWord = [allDict objectForKey:word];
    NSString * selectSql = [NSString stringWithFormat:@"select value, goal from progress where word = '%@'", word];
    FMResultSet * progressResult = [dictDataBase executeQuery:selectSql];
    NSInteger value;
    NSInteger goal;

    while ([progressResult next])
    {
        value = [progressResult intForColumn:@"value"];
        goal = [progressResult intForColumn:@"goal"];
        break;
    }
    
    [dictDataBase close];
    if (value >= goal)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (NSMutableArray *)getWordsByGroup: (NSInteger)group
{
    [self OpenDict];
    NSMutableArray * groupWord = [[NSMutableArray alloc]init];
    
    NSString * selectSql = [NSString stringWithFormat:@"select w.word from words w, attribute a where a.word = w.word and a.groups = %d", group];
    FMResultSet *result = [dictDataBase executeQuery:selectSql];
        
    while ([result next])
    {
        
        NSString * word = [result stringForColumn:@"word"];
        
        if ([self wordIsFinished:word])
        {   
            continue;
        }
        else
        {
            Word * tmpWord = [allDict objectForKey:word];
            [groupWord addObject:tmpWord];
        }
    }
    [dictDataBase close];
    
    return groupWord;
}

+ (NSMutableArray *)getRandomWords
{
    [self OpenDict];
    int totalRandomNumber = 20;
    NSMutableArray * randomWords = [[NSMutableArray alloc]initWithCapacity:totalRandomNumber];
    NSMutableArray *  candidate = [[NSMutableArray alloc]init];
    NSString * selectSql = @"select w.word from words w, attribute a where a.word = w.word and type = 2";
    FMResultSet *result = [dictDataBase executeQuery:selectSql];
    while ([result next])
    {
        NSString * word = [result stringForColumn:@"word"];
        
        if ([self wordIsFinished:word])
        {
            continue;
        }
        else
        {
            Word * tmpWord = [allDict objectForKey:word];
            [candidate addObject:tmpWord];
        }
    }
    
    [dictDataBase close];
    
    if ([candidate count] <= totalRandomNumber)
    {
        return candidate;
    }
    else
    {
        [candidate shuffle];
        for (int i = 0;i < totalRandomNumber;i++)
        {
            [randomWords addObject:[candidate objectAtIndex:i]];
        }
        return randomWords;
    }
}

+ (void)updateProgress: (NSMutableArray *)progress withWordArray: (NSMutableArray *)wordArray withCategoryId : (NSInteger)categoryid
{
    [self OpenDict];
    
    int length = [wordArray count];
    NSString * updateSql;
    NSString * selectSql;
    BOOL success;
    int totalCurrentProgress = 0;
    
    for (int i = 0; i < length ; i++)
    {
        success = NO;
        Word * tmp = [wordArray objectAtIndex:i];
        selectSql = [NSString stringWithFormat:@"select value from progress where word = '%@'",tmp.word];
        FMResultSet * progressResult = [dictDataBase executeQuery:selectSql];
        NSInteger value; 
        while ([progressResult next])
        {
            value = [progressResult intForColumn:@"value"];
            break;
        }
        tmp.progress = value + [progress[i] integerValue];
        
        updateSql = [NSString stringWithFormat:@"update progress set value = %d where word = '%@'",tmp.progress,tmp.word];
        NSLog(@"%@",updateSql);
        success =  [dictDataBase executeUpdate:updateSql];
        
        Word * tmpWord = [allDict objectForKey:tmp.word];
        tmpWord.progress = tmp.progress;
        
        NSLog(@"update mem progress : %d",tmpWord.progress);
        
        totalCurrentProgress += tmp.progress;
        
        if (success)
        {
            //[dictDataBase commit];
        }
        else
        {
            NSLog(@"FAIL");
        }
    }
    
    //update category progress
    NSNumber *categoryId = [NSNumber numberWithInteger:categoryid];
    NSLog(@"categoryid : %@",categoryId);
    if (categoryid != -1)
    {
        Category *category = [categoryDict objectForKey:categoryId];
    
        NSLog(@"category.categoryName : %@",category.categoryName);
        [category updateMemCategoryProgressbyWordProgress:totalCurrentProgress withLength:length];
        [self updateCategoryProgress:categoryid withCategoryProgress:totalCurrentProgress];
        NSLog(@"totalCurrentProgress : %d",totalCurrentProgress);
    }
    else //random wordlist
    {
#pragma mark todo
    }
    [dictDataBase close];
}

@end
