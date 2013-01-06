//
//  DictHelper.m
//  toeflGamePad
//
//  Created by Xingyin Zhu on 12-12-27.
//  Copyright (c) 2012年 Xingyin Zhu. All rights reserved.
//

#import "DictHelper.h"
#import "FMDatabase.h"
#import "Word.h"
#import "Category.h"

@interface DictHelper()

//@property (nonatomic, retain) NSString * dictPath;
@property (nonatomic, readwrite, strong) NSMutableArray * dictArray;
@property (nonatomic, readwrite, strong) NSMutableDictionary * categoryDict;
//@property (nonatomic, weak) FMDatabase *dictDataBase;

@end

static NSString * dictPath;
static FMDatabase *dictDataBase;
static NSMutableDictionary *allDict;
//static NSMutableDictionary *categoryDict;

@implementation DictHelper

@synthesize dictArray = _dictArray;
@synthesize categoryDict = _categoryDict;
//@synthesize dictDataBase = _dictDataBase;
//@synthesize dictPath = _dictPath;

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
        if (![dictDataBase open])
        {
            NSLog(@"Open dict failed!");
            return;
        }
        
    }
    
}

+ (void)loadAllWordObejctIntoDict
{
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
}

- (NSInteger)fetchAllCategory
{

    NSLog(@"in fetchAllCategory");
    
    NSInteger hasReviewedNumber = 0;
    
    if (self.categoryDict == nil)
    {
        self.categoryDict = [[NSMutableDictionary alloc]init];
        NSString * sql = @"select * from attribute_id";
        FMResultSet *result = [dictDataBase executeQuery:sql];
        
        while ([result next])
        {
            NSInteger attribute_id = [result intForColumn:@"attributeid"];
            NSNumber *aWrappedId = [NSNumber numberWithInteger:attribute_id];
            
            NSString * attribute_name = [result stringForColumn:@"attributename"];
            NSInteger progress = [result intForColumn:@"progress"];
            //NSNumber *aWrappedProgress = [NSNumber numberWithInteger:progress];
            if (progress != hasNotReviewed)
            {
                hasReviewedNumber ++;
            }
            
            
            Category * category = [[Category alloc]init];
            category.progress = progress;
            category.categoryName = attribute_name;
            
            [self.categoryDict setObject:category forKey:aWrappedId];
            NSLog(@"%d : %@",attribute_id,attribute_name);
        }
    }
    
    NSLog(@"self.categoryDict count : %d",[self.categoryDict count]);
    return hasReviewedNumber;
}


- (void)updateHasReviewed: (NSInteger)type
{
    
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
        Category * category = [self.categoryDict objectForKey:aWrappedId];
        category.progress = hasReviewed;
        NSLog(@"%@",updateSql);
        if (success)
        {
            //[dictDataBase commit];
        }
        else
        {
            NSLog(@"FAIL");
        }
    }
}

+ (BOOL)DictIsExist:(NSFileManager *)filemanager;

{
    return [filemanager fileExistsAtPath:dictPath];
}

+ (NSString *)getFirstWord
{
    NSString * sql = @"select * from words";
    FMResultSet *result = [dictDataBase executeQuery:sql];
    while ([result next])
    {
        NSString *a = [result stringForColumn:@"englishmark"];
        return a;
    }
    return nil;
}

- (void)getWordsByType: (NSInteger)type
{
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
    //int cnt = 0;
    while ([result next])
    {
        NSString * word = [result stringForColumn:@"word"];
        Word * tmpWord = [allDict objectForKey:word];
        
        if (tmpWord == nil)
        {
            NSLog(@"%@",word);
        }
        [self.dictArray addObject:tmpWord];
        //cnt ++;
    }
    //NSLog(@"%d",cnt);
    [self.dictArray sortUsingSelector:@selector(compareName:)];
}

- (void)getWordsByPartOfWords: (NSString *)partOfWord
{
    NSString * selectSql = [NSString stringWithFormat:@"select word from words where word like '%@%%'",partOfWord];
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
    
    [self.dictArray sortUsingSelector:@selector(compareName:)];
}

//for WordListViewController
- (void)getWordsByGroupEx: (NSInteger)group
{
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
    [self.dictArray sortUsingSelector:@selector(compareName:)];
}


//for GamePadViewController
- (NSMutableArray *)getWordsByGroup: (NSInteger)group
{
    NSMutableArray * groupWord = [[NSMutableArray alloc]init];
    
    NSString * selectSql = [NSString stringWithFormat:@"select w.word from words w, attribute a where a.word = w.word and a.groups = %d", group];
    FMResultSet *result = [dictDataBase executeQuery:selectSql];
        
    while ([result next])
    {
        
        NSString * word = [result stringForColumn:@"word"];
        Word * tmpWord = [allDict objectForKey:word];
        
        selectSql = [NSString stringWithFormat:@"select value, goal from progress where word = '%@'", word];
        FMResultSet * progressResult = [dictDataBase executeQuery:selectSql];
        NSInteger value;
        NSInteger goal;
        while ([progressResult next])
        {
            value = [progressResult intForColumn:@"value"];
            goal = [progressResult intForColumn:@"goal"];
            break;
        }
        
        if (value >= goal)
        {
            continue;
        }
        else
        {
            [groupWord addObject:tmpWord];
        }
    }
    return groupWord;
}

- (void)updateProgress: (NSMutableArray *)progress withWordArray: (NSMutableArray *)wordArray
{
    int length = [wordArray count];
    NSString * updateSql;
    NSString * selectSql;
    BOOL success;
    for (int i = 0;i < length ; i++)
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
        
        //tmpWord = [allDict objectForKey:tmp.word];
        NSLog(@"update mem progress : %d",tmpWord.progress);
        
        if (success)
        {
            //[dictDataBase commit];
        }
        else
        {
            NSLog(@"FAIL");
        }
    }
}

@end
