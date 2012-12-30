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
@property (nonatomic, readwrite, strong) NSMutableArray *dictArray;
//@property (nonatomic, weak) FMDatabase *dictDataBase;

@end

static NSString * dictPath;
static FMDatabase *dictDataBase;

@implementation DictHelper

@synthesize dictArray = _dictArray;
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

+ (BOOL)DictIsExist:(NSFileManager *)filemanager;

{
    return [filemanager fileExistsAtPath:dictPath];

}

- (NSString *)getFirstWord
{
    NSString * sql = @"select * from words";
    FMResultSet *result = [dictDataBase executeQuery:sql];
    //NSLog(@"before");
    while ([result next])
    {
        NSString *a = [result stringForColumn:@"englishmark"];
        //NSLog(@"%@",a);
        return a;
    }
    //NSLog(@"after");
    return nil;
}



@end
