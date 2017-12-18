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

#define KEY_FILE_NAME @"HOTMasterDataFull_02.12_171214_143505_01.29.zip"

@interface SplashController () <WRRequestDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@end

@implementation SplashController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_indicatorView startAnimating];
//    double delayInSeconds = 2.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [self saveCategoryToDb];
//    });
    [self downloadZipFile];
}
#pragma mark - Custom method
- (void)listDirectoryContents {
    WRRequestListDirectory * listDir = [[WRRequestListDirectory alloc] init];
    listDir.delegate = self;
    
    listDir.path = @"/datamanager/thot";
    
    listDir.hostname = @"192.168.1.100";
    listDir.username = USERNAME;
    listDir.password = PASSWORD;
    
    [listDir start];
}
- (void)downloadZipFile {
    WRRequestDownload * downloadFile = [[WRRequestDownload alloc] init];
    downloadFile.delegate = self;
    
    downloadFile.path = [NSString stringWithFormat:@"/datamanager/thot/%@", KEY_FILE_NAME];
    
    downloadFile.hostname = @"192.168.1.100";
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
                      stringByAppendingPathComponent:KEY_FILE_NAME];
    NSLog(@"path: %@", path);
    NSString *dataStr = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    [dataStr writeToFile:path atomically:YES
                   encoding:NSUTF8StringEncoding error:nil];
}
#pragma mark - WRRequestDelegate
- (void)requestCompleted:(WRRequest *)request {
    //called after 'request' is completed successfully
//    NSLog(@"%@ completed!", request);
    
    //we cast the request to list request
//    WRRequestListDirectory * listDir = (WRRequestListDirectory *)request;
    
    //we print each of the files name
//    for (NSDictionary * file in listDir.filesInfo) {
//        NSString *name = [file objectForKey:(id)kCFFTPResourceName];
//        NSLog(@"%@", name);
//    }
    WRRequestDownload * downloadF = (WRRequestDownload *)request;
    NSData *data = downloadF.receivedData;
    [self saveFile:data];
}
- (void)requestFailed:(WRRequest *)request {
    NSLog(@"%@", request.error.message);
}

#pragma mark - save data to db
- (void)saveCategoryToDb {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:KEY_SAVED_DATA]) {
        [self showCategoriesScreen];
        return;
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_SAVED_DATA];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Documents Directory: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    NSManagedObjectContext *context = [self managedObjectContext];
    //save category to db
    NSString* path = [[NSBundle mainBundle] pathForResource:KEY_CATEGORY_TABLE_FILE_NAME ofType:KEY_SURFFIX_FILE];
    NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
    
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
    NSString* path = [[NSBundle mainBundle] pathForResource:KEY_MENU_CONTENT_TABLE_FILE_NAME ofType:KEY_SURFFIX_FILE];
    NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
    
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
    NSString* path = [[NSBundle mainBundle] pathForResource:KEY_PRODUCT_TABLE_FILE_NAME ofType:KEY_SURFFIX_FILE];
    NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
    
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

- (void)showCategoriesScreen {
    CategoriesController *rootVC = [[CategoriesController alloc] initWithNibName:@"CategoriesController" bundle:nil];
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    [navc setNavigationBarHidden:YES];
    appDelegate.window.rootViewController = navc;
}

@end
