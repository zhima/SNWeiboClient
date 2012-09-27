//
//  SNWeiboCoreDataManager.m
//  SinaWeiboClient
//
//  Created by Lion User on 12/09/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SNWeiboCoreDataManager.h"
#import "ImageCDItem.h"
#import "StatusCDModel+Utils.h"
#import "UserCDModel+Utils.h"

@interface SNWeiboCoreDataManager ()


@property (nonatomic,strong) UIManagedDocument *document;
@property (nonatomic,strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic,strong) NSPersistentStore *persistentStore;
@property (nonatomic,strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation SNWeiboCoreDataManager

@synthesize managedContext = _managedContext;
@synthesize document = _document;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStore = _persistentStore;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

-(id)init
{
    self=[super init];
    if (self) {
        //self.document=[[UIManagedDocument alloc] initWithFileURL:[self getDocumentURL]];
        self.managedContext=[[NSManagedObjectContext alloc] init];
        [self.managedContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return self;
}

-(NSManagedObjectModel *)managedObjectModel
{
    NSLog(@"SNWeiboCoreDataManager:managedObjectModel:call");
    _managedObjectModel=[NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    NSURL *storeURL=[NSURL fileURLWithPath:[self persistentStorePath]];
    _persistentStoreCoordinator=[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    NSError *error=nil;
    [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    return _persistentStoreCoordinator;
}

-(NSString *)persistentStorePath
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths lastObject];
    
    NSString *persistentStorePath=[documentsDirectory stringByAppendingPathComponent:@"SNWeibo_Database1.sqlite"];
    return persistentStorePath;
    
}

//-(void)useDocument
//{
//    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]]) {
//        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
//            if (success) {
//                NSLog(@"document created succeed");
//                self.managedContext=self.document.managedObjectContext;
//            }else {
//                NSLog(@"document created failed");
//            }
//        }];
//    }else if (self.document.documentState == UIDocumentStateClosed) {
//        [self.document openWithCompletionHandler:^(BOOL success) {
//            if (success) {
//                NSLog(@"document opened succeed");
//                self.managedContext=self.document.managedObjectContext;
//            }else {
//                NSLog(@"document opened failed");
//            }
//            
//        }];
//    }else if (self.document.documentState == UIDocumentStateNormal) {
//        self.managedContext=self.document.managedObjectContext;
//    }
//}

//-(void)setDocument:(UIManagedDocument *)document
//{
//    if (document!=_document) {
//        _document=document;
//        [self useDocument];
//        
//    }
//}


+(SNWeiboCoreDataManager *)getInstance
{
    static SNWeiboCoreDataManager *instance=nil;
    if (instance==nil) {
        instance=[[self alloc]  init];
    }
    return instance;
}

//-(NSURL *)getDocumentURL
//{
//    NSURL *fileURL=[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//    fileURL=[fileURL URLByAppendingPathComponent:@"SinaWeibo Database.sqlite"];
//    return fileURL;
//}

-(NSData *)readImageFromCD:(NSString *)key
{
    NSData *imageData=nil;
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"ImageCDItem"];
    request.predicate=[NSPredicate predicateWithFormat:@"key==%@",key];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    
    NSError *error;
    NSArray *results=[self.managedContext executeFetchRequest:request error:&error];
    
    if (!results) {
        NSLog(@"read Image from Core Data Failed");
    }else {
        imageData=[[results lastObject] imageData];
    }
    return imageData;
}


-(void)insertImageToCD:(NSData *)imageData withKey:(NSString *)key
{
    if ([self readImageFromCD:key]) {
        return;
    }
    ImageCDItem *imageItem=[NSEntityDescription insertNewObjectForEntityForName:@"ImageCDItem" inManagedObjectContext:self.managedContext];
    imageItem.imageData=imageData;
    imageItem.key=key;
    imageItem.date=[NSDate date];
    
    NSError *error;
    if (![self.managedContext save:&error]) {
        NSLog(@"insert imageData to Core Data Failed:%@",error.localizedDescription);
    }
    
}

-(void)insertStatusToCD:(Status *)status withIndex:(NSInteger)index isHomeLine:(BOOL)isHomeLine
{
    StatusCDModel *statusModel=[NSEntityDescription insertNewObjectForEntityForName:@"StatusCDModel" inManagedObjectContext:self.managedContext];
    [statusModel updateStatusCDModelWithStatus:status withIndex:index isHomeLine:isHomeLine];
    if (status.retweetedStatus) {
        statusModel.retweetedStatus=[NSEntityDescription insertNewObjectForEntityForName:@"StatusCDModel" inManagedObjectContext:self.managedContext];
        [statusModel.retweetedStatus updateStatusCDModelWithStatus:status.retweetedStatus withIndex:-1 isHomeLine:NO];
    }
    
    
    NSError *error;
    if (![self.managedContext save:&error]) {
        NSLog(@"insert Status to Core Data Failed:%@",error.localizedDescription);
    }
}


-(NSMutableArray *)readStatusFromCDisHomeLine:(BOOL)isHomeLine
{
    NSFetchRequest *request=[NSFetchRequest fetchRequestWithEntityName:@"StatusCDModel"];
    request.predicate=[NSPredicate predicateWithFormat:@"isHomeLine = %d",isHomeLine];
    NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
    request.sortDescriptors=[NSArray arrayWithObject:sort];
    
    
    NSError *error=nil;
    NSArray *results=[self.managedContext executeFetchRequest:request error:&error];
    
    if (!results || error) {
        NSLog(@"read status from Core Data failed:%@",error.localizedDescription);
        return nil;
    }
    NSLog(@"Status Count Read From Core Data:%d",[results count]);
    NSMutableArray *statusData=[NSMutableArray array];
    for (StatusCDModel *model in results) {
        Status *status=[[Status alloc] init];
        [status updateStatusWithStatusCDModel:model];
        [statusData addObject:status];
    }
    return statusData;
}

-(void)clearStatusInCDisHomeLine:(BOOL)isHomeLine
{
    NSFetchRequest *request=[NSFetchRequest fetchRequestWithEntityName:@"StatusCDModel"];
    request.predicate=[NSPredicate predicateWithFormat:@"isHomeLine = %d",isHomeLine];
    NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
    request.sortDescriptors=[NSArray arrayWithObject:sort];
    
    
    NSError *error=nil;
    NSArray *results=[self.managedContext executeFetchRequest:request error:&error];
    
    if (!results || error) {
        NSLog(@"Deletion:read status from Core Data failed:%@",error.localizedDescription);
        
    }
    
    for (StatusCDModel *status in results) {
        [self.managedContext deleteObject:status];
    }
    
    NSError *saveError=nil;
    
    if (![self.managedContext save:&saveError]) {
        NSLog(@"Delete Status in Core Data Failed:%@",error.localizedDescription);
    }

}


@end
