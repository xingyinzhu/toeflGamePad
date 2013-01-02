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
        
        NSString * sql = @"select w.word, w.englishmark, w.americamark, w.meanings, p.value from words w, progress p where p.word = w.word";
        FMResultSet *result = [dictDataBase executeQuery:sql];
        
        while ([result next])
        {
            Word * tmpWord = [[Word alloc]init];
            tmpWord.word = [result stringForColumn:@"word"];
            tmpWord.englishmark = [result stringForColumn:@"englishmark"];
            tmpWord.americamark = [result stringForColumn:@"americamark"];
            tmpWord.meanings = [result stringForColumn:@"meanings"];
            tmpWord.progress = [result intForColumn:@"value"];
            
            [allDict setObject:tmpWord forKey:tmpWord.word];
        }
    }
}

- (void)fetchAllCategory
{

    NSLog(@"in fetchAllCategory");
    
    if (self.categoryDict == nil)
    {
        self.categoryDict = [[NSMutableDictionary alloc]init];
        NSString * sql = @"select * from attribute_id";
        FMResultSet *result = [dictDataBase executeQuery:sql];
        
        while ([result next])
        {
            NSInteger attribute_id = [result intForColumn:@"attributeid"];
            NSString * attribute_name = [result stringForColumn:@"attributename"];
            
            NSNumber *aWrappedId = [NSNumber numberWithInteger:attribute_id];

            [self.categoryDict setObject:attribute_name forKey:aWrappedId];
            NSLog(@"%d : %@",attribute_id,attribute_name);
            
        }
        
    }
    
    NSLog(@"%d",[self.categoryDict count]);

    
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
    FMResultSet *result = [dictDataBase executeQuery:execSql];
    self.dictArray = [[NSMutableArray alloc]init];

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

- (void)getWordsByPartOfWords: (NSString *)partOfWord
{
    NSString * selectSql = [NSString stringWithFormat:@"select word from words where word like '%@%%'",partOfWord];
    FMResultSet *result = [dictDataBase executeQuery:selectSql];
    self.dictArray = [[NSMutableArray alloc]init];
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


- (NSMutableArray *)getWordsByGroup: (NSInteger)group
{
    NSMutableArray * groupWord = [[NSMutableArray alloc]init];
    
    NSString * selectSql = [NSString stringWithFormat:@"select w.word, w.englishmark, w.americamark, w.meanings from words w, attribute a where a.word = w.word and a.groups = %d", group];
    FMResultSet *result = [dictDataBase executeQuery:selectSql];
        
    while ([result next])
    {
        Word * tmpWord = [[Word alloc]init];
        tmpWord.word = [result stringForColumn:@"word"];
        tmpWord.englishmark = [result stringForColumn:@"englishmark"];
        tmpWord.americamark = [result stringForColumn:@"americamark"];
        tmpWord.meanings = [result stringForColumn:@"meanings"];
        
        
        selectSql = [NSString stringWithFormat:@"select value, goal from progress where word = '%@'", tmpWord.word];
        FMResultSet * progressResult = [dictDataBase executeQuery:selectSql];
        NSInteger value;
        NSInteger goal;
        while ([progressResult next])
        {
            value = [progressResult intForColumn:@"value"];
            goal = [progressResult intForColumn:@"goal"];
            break;
        }
        
        //NSLog(@"%d %d", value,goal);
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
        
        tmpWord = [allDict objectForKey:tmp.word];
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
