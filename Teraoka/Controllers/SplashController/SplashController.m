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
#import "SettingsController.h"
#import "EnterPassAccessSettingController.h"
#import <View+MASAdditions.h>
#import "ShareManager.h"
#import <ProgressHUD.h>
#import "NSString+KeyLanguage.h"
#import "StartOrderController.h"
#import "Reachability.h"

@interface SplashController () <WRRequestDelegate, NSStreamDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *startOrderBtn;
@property (weak, nonatomic) IBOutlet UIButton *settingBtn;

@end

@implementation SplashController {
    NSString *fileName;
    BOOL isDownloadFile;
    BOOL saveDataSuccess;
    BOOL didClickStartButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *json = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_SAVED_SETTING];
    SettingModel *setting = [[SettingModel alloc] initWithString:json error:nil];
    
    if (!setting) setting = [[SettingModel alloc] init];
    
    if (setting.serverIP.length == 0) {
        setting.serverIP = HOST_NAME;
    }
    
    [ShareManager shared].setting = setting;
}
    
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    saveDataSuccess = NO;
    didClickStartButton = NO;
    
    isDownloadFile = NO;
    
    [self removeDataForEntity:MENU_CATEGORY_TABLE_NAME];
    [self removeDataForEntity:MENU_CONTENTS_TABLE_NAME];
    [self removeDataForEntity:PLU_TABLE_NAME];
    [self removeDataForEntity:OPTION_GROUP_HEADER_TABLE_NAME];
    [self removeDataForEntity:OPTION_GROUP_TABLE_NAME];
    [self removeDataForEntity:COMMENT_GROUP_HEADER_TABLE_NAME];
    [self removeDataForEntity:COMMENT_GROUP_TABLE_NAME];
    [self removeDataForEntity:COMMENT_TABLE_NAME];
    [self removeDataForEntity:COMMENT_SET_TABLE_NAME];
    [self removeDataForEntity:SERVING_SET_TABLE_NAME];
    [self removeDataForEntity:SERVING_GROUP_HEADER_TABLE_NAME];
    [self removeDataForEntity:SERVING_GROUP_TABLE_NAME];
    [self removeDataForEntity:SERVING_TIMING_TABLE_NAME];
    [self removeDataForEntity:OPTION_SET_TABLE_NAME];
    [self removeDataForEntity:TABLE_NO_TABLE_NAME];
    
    [self doGetContents];
}

- (void)loadLocalizable {
    [super loadLocalizable];
    
    self.lbTitle.text = @"SC01_001".localizedString;
    [self.startOrderBtn setTitle:@"SC01_002".localizedString forState:UIControlStateNormal];
    [self.settingBtn setTitle:@"SC01_003".localizedString forState:UIControlStateNormal];
}

- (IBAction)startOrderAction:(id)sender {
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    
    if (![reach isReachable]) {
        [Util showAlert:@"Unable to proceed, you do not have any network." vc:self];
        return;
    }
    
    didClickStartButton = YES;
    if ([ShareManager shared].setting.tableNo > 0) {
        [self showCategoriesScreen];
        return;
    }
    
    StartOrderController *vc = [[StartOrderController alloc] initWithNibName:@"StartOrderController" bundle:nil];
    [self presentViewController:vc animated:NO completion:nil];
}

- (IBAction)settingAction:(id)sender {
//    EnterPassAccessSettingController *settingVc = [[EnterPassAccessSettingController alloc] initWithNibName:@"EnterPassAccessSettingController" bundle:nil];
//    settingVc.delegate = self;
//    [self addChildViewController:settingVc];
//    [self.view addSubview:settingVc.view];
//    [settingVc didMoveToParentViewController:self];
//
//    [settingVc.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.top.equalTo(settingVc.view.superview);
//        make.width.equalTo(settingVc.view.superview.mas_width);
//        make.height.equalTo(settingVc.view.superview.mas_height);
//    }];
    
    SettingsController *vc = [[SettingsController alloc] initWithNibName:@"SettingsController" bundle:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Custom method

- (void)doGetContents {
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    
    if (![reach isReachable]) {
        return;
    }
    
//    [self saveDataToDb];
    
    [ProgressHUD show:nil Interaction:NO];
    [self listDirectoryContents];
}

- (void)listDirectoryContents {
    WRRequestListDirectory * listDir = [[WRRequestListDirectory alloc] init];
    listDir.delegate = self;
    
    listDir.path = @"../opt/datamanager/thot";
    
    listDir.hostname = [ShareManager shared].setting.serverIP;
    listDir.username = USERNAME;
    listDir.password = PASSWORD;
    
    [listDir start];
}

- (void)downloadZipFile {
    WRRequestDownload * downloadFile = [[WRRequestDownload alloc] init];
    downloadFile.delegate = self;
    
    downloadFile.path = [NSString stringWithFormat:@"../opt/datamanager/thot/%@", fileName];
    
    downloadFile.hostname = [ShareManager shared].setting.serverIP;
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
    } else {
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
        [self saveDataToDb];
    } else {
//        [Answers logCustomEventWithName:@"unzip file false" customAttributes:nil];
    }
}

- (NSString *)getContentFile:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", fileName]];
//    NSString* filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
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
    [ProgressHUD dismiss];
    [Util showAlert:@"Unable to proceed, you have attempted to connect to an invalid server IP. Please try again with another IP." vc:self];
}

#pragma mark - save data to db

- (void)saveDataToDbFrom:(NSString *)fileName toTable:(NSString *)tableName {
    NSLog(@"Documents Directory: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    NSManagedObjectContext *context = [self managedObjectContext];
    //save category to db
    NSString* content = [self getContentFile:fileName];
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
    //    [Answers logCustomEventWithName:[NSString stringWithFormat:@"category %d", (int)lines.count] customAttributes:nil];
    NSArray *fieldsName = [NSArray new];
    for (int i=0;i<lines.count;i++)
    {
        NSString *line = [lines objectAtIndex:i];
        if (line.length == 0) break;
        
        NSArray *fields = [line componentsSeparatedByString:@","];
        if (i == 0) {
            fieldsName = [line componentsSeparatedByString:@","];
        } else {
            // Create a new managed object
            NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:context];
            
            for (int fieldIndex=0;fieldIndex<fieldsName.count;fieldIndex++) {
                NSString *fieldName = [fieldsName objectAtIndex:fieldIndex];
                [newDevice setValue:[[fields objectAtIndex:fieldIndex] stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:fieldName];
            }
            
            NSError *error = nil;
            // Save the object to persistent store
            if (![context save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
        }
    }
}

- (void)saveDataToDb {
    [self saveDataToDbFrom:KEY_CATEGORY_TABLE_FILE_NAME toTable:MENU_CATEGORY_TABLE_NAME];
    [self saveDataToDbFrom:KEY_MENU_CONTENT_TABLE_FILE_NAME toTable:MENU_CONTENTS_TABLE_NAME];
    [self saveDataToDbFrom:KEY_PRODUCT_TABLE_FILE_NAME toTable:PLU_TABLE_NAME];
    [self saveDataToDbFrom:KEY_OPTION_GROUP_HEADER_TABLE_FILE_NAME toTable:OPTION_GROUP_HEADER_TABLE_NAME];
    [self saveDataToDbFrom:KEY_OPTION_GROUP_TABLE_FILE_NAME toTable:OPTION_GROUP_TABLE_NAME];
    [self saveDataToDbFrom:KEY_COMMENT_GROUP_HEADER_TABLE_FILE_NAME toTable:COMMENT_GROUP_HEADER_TABLE_NAME];
    [self saveDataToDbFrom:KEY_COMMENT_GROUP_TABLE_FILE_NAME toTable:COMMENT_GROUP_TABLE_NAME];
    [self saveDataToDbFrom:KEY_COMMENT_TABLE_FILE_NAME toTable:COMMENT_TABLE_NAME];
    [self saveDataToDbFrom:KEY_COMMENT_SET_TABLE_FILE_NAME toTable:COMMENT_SET_TABLE_NAME];
    [self saveDataToDbFrom:KEY_SERVING_SET_TABLE_FILE_NAME toTable:SERVING_SET_TABLE_NAME];
    [self saveDataToDbFrom:KEY_SERVING_GROUP_HEADER_TABLE_FILE_NAME toTable:SERVING_GROUP_HEADER_TABLE_NAME];
    [self saveDataToDbFrom:KEY_SERVING_GROUP_TABLE_FILE_NAME toTable:SERVING_GROUP_TABLE_NAME];
    [self saveDataToDbFrom:KEY_SERVING_TIMING_TABLE_FILE_NAME toTable:SERVING_TIMING_TABLE_NAME];
    [self saveDataToDbFrom:KEY_OPTION_SET_TABLE_FILE_NAME toTable:OPTION_SET_TABLE_NAME];
    [self saveDataToDbFrom:KEY_TABLE_NO_TABLE_FILE_NAME toTable:TABLE_NO_TABLE_NAME];
    [ProgressHUD dismiss];
    
    saveDataSuccess = YES;
    
    if (didClickStartButton) {
        [self showCategoriesScreen];
    }
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
    if (!saveDataSuccess) {
        [self doGetContents];
        return;
    }
    
    CategoriesController *rootVC = [[CategoriesController alloc] initWithNibName:@"CategoriesController" bundle:nil];
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    [navc setNavigationBarHidden:YES];
    appDelegate.window.rootViewController = navc;
}

//MARK: EnterPassAccessDelegate

//- (void)didEnterPassSuccess {
//    SettingsController *vc = [[SettingsController alloc] initWithNibName:@"SettingsController" bundle:nil];
//    [self presentViewController:vc animated:YES completion:nil];
//}

@end
