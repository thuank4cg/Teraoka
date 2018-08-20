//
//  SplashController.m
//  Teraoka
//
//  Created by Thuan on 12/14/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "SplashController.h"
#import "APPConstants.h"
#import "CategoriesController.h"
#import "WhiteRaccoon.h"
#import <SSZipArchive/SSZipArchive.h>
#import "TextfieldCustom.h"
#import "ButtonCustom.h"
#import "ParamsHelper.h"
#import "ShareManager.h"
#import "Util.h"
#import <Crashlytics/Answers.h>


@interface SplashController () <WRRequestDelegate, NSStreamDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet TextfieldCustom *tfValue;
@property (weak, nonatomic) IBOutlet ButtonCustom *btnProceed;

@end

@implementation SplashController {
    NSString *fileName;
    BOOL isDownloadFile;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_indicatorView setHidden:YES];
    
    [self removeDataForEntity:@"Category"];
    [self removeDataForEntity:@"MenuContent"];
    [self removeDataForEntity:@"Product"];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self saveCategoryToDb];
    });
    
    isDownloadFile = NO;
    [ShareManager shared].hostName = HOST_NAME;
}

- (IBAction)proceed:(id)sender {
    if (_tfValue.text.length > 0) [ShareManager shared].hostName = _tfValue.text;
    [_btnProceed setUserInteractionEnabled:NO];
    [_indicatorView setHidden:NO];
    [_indicatorView startAnimating];
    [self listDirectoryContents];
}

#pragma mark - Custom method
- (void)listDirectoryContents {
    WRRequestListDirectory * listDir = [[WRRequestListDirectory alloc] init];
    listDir.delegate = self;
    
    listDir.path = @"../opt/datamanager/thot";
    
    listDir.hostname = [ShareManager shared].hostName;
    listDir.username = USERNAME;
    listDir.password = PASSWORD;
    
    [listDir start];
}

- (void)downloadZipFile {
    WRRequestDownload * downloadFile = [[WRRequestDownload alloc] init];
    downloadFile.delegate = self;
    
    downloadFile.path = [NSString stringWithFormat:@"../opt/datamanager/thot/%@", fileName];
    
    downloadFile.hostname = [ShareManager shared].hostName;
    downloadFile.username = USERNAME;
    downloadFile.password = PASSWORD;
    
    //we start the request
    [downloadFile start];
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

- (void)saveFile:(NSData *)receivedData {
    NSString *path = [[self applicationDocumentsDirectory].path
                      stringByAppendingPathComponent:fileName];
    NSLog(@"path: %@", path);
    BOOL success =  [receivedData writeToFile:path atomically:YES];
    if (success) {
//        [Answers logCustomEventWithName:@"save file success" customAttributes:nil];
        [self unzipFile];
    }else {
//        [Answers logCustomEventWithName:@"save file false" customAttributes:nil];
    }
}

- (void)unzipFile {
    NSString *zipPath = [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:fileName];
//    zipPath = [[NSBundle mainBundle] pathForResource:@"HOTMasterDataFull_02.12_180110_090203_01.10" ofType:@"zip"];
    NSString *unzipPath = [self applicationDocumentsDirectory].path;
    BOOL success =  [SSZipArchive unzipFileAtPath:zipPath toDestination:unzipPath];
    NSLog(@"unzipPath: %@", unzipPath);
    if (success) {
//        [Answers logCustomEventWithName:@"unzip file success" customAttributes:nil];
        [self saveCategoryToDb];
    }else {
//        [Answers logCustomEventWithName:@"unzip file false" customAttributes:nil];
    }
}

- (NSString *)getContentFile:(NSString *)fileName {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", fileName]];
    NSString* filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    return content;
}

#pragma mark - WRRequestDelegate
- (void)requestCompleted:(WRRequest *)request {
    //called after 'request' is completed successfully
//    NSLog(@"%@ completed!", request);
    
//    for (NSDictionary * file in listDir.filesInfo) {
//        NSDate *modDate = [file objectForKey:(id)kCFFTPResourceModDate];
//    }
    if (isDownloadFile) {
        WRRequestDownload * downloadF = (WRRequestDownload *)request;
        NSData *data = downloadF.receivedData;
        [self saveFile:data];
        return;
    }
    WRRequestListDirectory * listDir = (WRRequestListDirectory *)request;
    NSDate *compareDate = nil;
    NSDictionary *targetDict = nil;
    for (NSDictionary *file in listDir.filesInfo) {
        NSString *fName = [file objectForKey:(id)kCFFTPResourceName];
        if ([fName rangeOfString:@".zip"].location != NSNotFound) {
            NSDate *modDate = [file objectForKey:(id)kCFFTPResourceModDate];
            if (!compareDate) {
                compareDate = modDate;
                targetDict = file;
            }else {
                if ([modDate compare:compareDate] == NSOrderedDescending) {
                    compareDate = modDate;
                    targetDict = file;
                }
            }
        }
    }
    if (targetDict) {
        fileName = [targetDict objectForKey:(id)kCFFTPResourceName];
        isDownloadFile = YES;
        [self downloadZipFile];
        
//        [Answers logCustomEventWithName:fileName customAttributes:nil];
    }
}

- (void)requestFailed:(WRRequest *)request {
    NSLog(@"%@", request.error.message);
    [_indicatorView stopAnimating];
    [_indicatorView setHidden:YES];
    if (!isDownloadFile) [_btnProceed setUserInteractionEnabled:YES];
}

#pragma mark - save data to db
- (void)saveCategoryToDb {
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:KEY_SAVED_DATA]) {
//        [self showCategoriesScreen];
//        return;
//    }
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_SAVED_DATA];
//    [[NSUserDefaults standardUserDefaults] synchronize];

    NSLog(@"Documents Directory: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    NSManagedObjectContext *context = [self managedObjectContext];
    //save category to db
    NSString* content = [self getContentFile:KEY_CATEGORY_TABLE_FILE_NAME];
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
//    [Answers logCustomEventWithName:[NSString stringWithFormat:@"category %d", (int)lines.count] customAttributes:nil];
    int indexOfCateId = 0;
    int indexOfCateName = 0;
    for (int i=0;i<lines.count;i++)
    {
        NSString *line = [lines objectAtIndex:i];
        NSArray *fields = [line componentsSeparatedByString:@","];
        if (i == 0) {
            indexOfCateId = (int)[fields indexOfObject:KEY_CATEGORY_ID];
            indexOfCateName = (int)[fields indexOfObject:KEY_CATEGORY_NAME];
        }else {
            if (fields.count > indexOfCateName) {
                // Create a new managed object
                NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
                [newDevice setValue:[[fields objectAtIndex:indexOfCateId] stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:@"id"];
                [newDevice setValue:[[fields objectAtIndex:indexOfCateName] stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:@"name"];
                
                NSError *error = nil;
                // Save the object to persistent store
                if (![context save:&error]) {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
            }
        }
    }
    [self saveMenuContentToDb];
}

- (void)saveMenuContentToDb {
    NSManagedObjectContext *context = [self managedObjectContext];
    //save category to db
    NSString* content = [self getContentFile:KEY_MENU_CONTENT_TABLE_FILE_NAME];
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
//    [Answers logCustomEventWithName:[NSString stringWithFormat:@"menu %d", (int)lines.count] customAttributes:nil];
    int indexOfCateId = 0;
    int indexOfProductId = 0;
    for (int i=0;i<lines.count;i++)
    {
        NSString *line = [lines objectAtIndex:i];
        NSArray *fields = [line componentsSeparatedByString:@","];
        if (i == 0) {
            indexOfCateId = (int)[fields indexOfObject:KEY_CATEGORY_ID];
            indexOfProductId = (int)[fields indexOfObject:KEY_PRODUCT_ID];
        }else {
            if (fields.count > indexOfProductId) {
                // Create a new managed object
                NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"MenuContent" inManagedObjectContext:context];
                [newDevice setValue:[[fields objectAtIndex:indexOfCateId] stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:@"category_id"];
            [newDevice setValue:[[fields objectAtIndex:indexOfProductId] stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:@"product_id"];
                
                NSError *error = nil;
                // Save the object to persistent store
                if (![context save:&error]) {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
            }
        }
    }
    [self saveProductToDb];
}

- (void)saveProductToDb {
    NSManagedObjectContext *context = [self managedObjectContext];
    //save product to db
    NSString* content = [self getContentFile:KEY_PRODUCT_TABLE_FILE_NAME];
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
//    [Answers logCustomEventWithName:[NSString stringWithFormat:@"product %d", (int)lines.count] customAttributes:nil];
    int indexOfId = 0;
    int indexOfPrice = 0;
    int indexOfName = 0;
    for (int i=0;i<lines.count;i++)
    {
        NSString *line = [lines objectAtIndex:i];
        NSArray *fields = [line componentsSeparatedByString:@","];
        if (i == 0) {
            indexOfId = (int)[fields indexOfObject:KEY_PRODUCT_ID];
            indexOfPrice = (int)[fields indexOfObject:KEY_PRODUCT_PRICE];
            indexOfName = (int)[fields indexOfObject:KEY_PRODUCT_NAME];
        }else {
            if (fields.count > indexOfPrice) {
                // Create a new managed object
                NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:context];
                [newDevice setValue:[[fields objectAtIndex:indexOfId] stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:@"id"];
                [newDevice setValue:[[fields objectAtIndex:indexOfName] stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:@"name"];
                [newDevice setValue:[[fields objectAtIndex:indexOfPrice] stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:@"price"];
                
                NSError *error = nil;
                // Save the object to persistent store
                if (![context save:&error]) {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
            }
        }
    }
    [_indicatorView stopAnimating];
    [_indicatorView setHidden:YES];
    [self showCategoriesScreen];
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)removeDataForEntity:(NSString *)entity {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity];
    NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];

    NSManagedObjectContext *myManagedObjectContext = appDelegate.managedObjectContext;
    NSPersistentStoreCoordinator *myPersistentStoreCoordinator = appDelegate.persistentStoreCoordinator;

    @try {
        [myPersistentStoreCoordinator executeRequest:deleteRequest withContext:myManagedObjectContext error:nil];
    }@catch (NSException *exception) {
        NSLog(@"Exception:%@",exception);
    }
}

- (void)showCategoriesScreen {
    CategoriesController *rootVC = [[CategoriesController alloc] initWithNibName:@"CategoriesController" bundle:nil];
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    [navc setNavigationBarHidden:YES];
    appDelegate.window.rootViewController = navc;
}

@end
