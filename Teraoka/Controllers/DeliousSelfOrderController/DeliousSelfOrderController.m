//
//  DeliousSelfOrderController.m
//  Teraoka
//
//  Created by Thuan on 12/14/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "DeliousSelfOrderController.h"
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

@interface DeliousSelfOrderController () <WRRequestDelegate, NSStreamDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *startOrderBtn;
@property (weak, nonatomic) IBOutlet UIButton *settingBtn;

@end

@implementation DeliousSelfOrderController {
    NSString *fileName;
    BOOL isDownloadFile;
    BOOL saveDataSuccess;
    BOOL didClickStartButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [ShareManager shared].setting = [Util getSetting];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    saveDataSuccess = NO;
    didClickStartButton = NO;
    
    isDownloadFile = NO;
    
    [self doGetContents];
}

- (void)loadLocalizable {
    [super loadLocalizable];
    
    self.lbTitle.text = @"SC01_001".localizedString;
    [self.startOrderBtn setTitle:@"SC01_002".localizedString forState:UIControlStateNormal];
    [self.settingBtn setTitle:@"SC01_003".localizedString forState:UIControlStateNormal];
}

- (IBAction)startOrderAction:(id)sender {
    if ([ShareManager shared].setting.serverIP.length == 0) {
        [Util showAlert:@"Please enter IP to proceed" vc:self];
        return;
    }

    if (![Util isConnectionInternet]) {
        [Util showAlert:@"Unable to proceed, you do not have any network." vc:self];
        return;
    }
    
    saveDataSuccess = NO;
    isDownloadFile = NO;
    didClickStartButton = YES;
    [ShareManager shared].existingOrderArr = nil;
    
    [self doGetContents];
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

- (void)removeOldData {
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
    [self removeDataForEntity:MEAL_SET_TABLE_NAME];
    [self removeDataForEntity:SELECTION_GROUP_TABLE_NAME];
    [self removeDataForEntity:SELECTION_HEADER_TABLE_NAME];
    [self removeDataForEntity:TAX_TABLE_NAME];
}

- (void)doGetContents {
    if ([ShareManager shared].setting.serverIP.length == 0) return;
    
    [self removeOldData];
    
//    Reachability *reach = [Reachability reachabilityForInternetConnection];
//    
//    if (![reach isReachable]) {
//        return;
//    }
    
//    [self saveDataToDb];
//    [self unzipFile];
    
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

- (void)saveFile:(NSData *)receivedData {
    NSString *path = [DOCUMENT_DIRECTORY_ROOT stringByAppendingPathComponent:fileName];
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
    NSString *zipPath = [DOCUMENT_DIRECTORY_ROOT stringByAppendingPathComponent:fileName];
//    zipPath = [[NSBundle mainBundle] pathForResource:@"HOTMasterDataFull_02.12_181107_164412_01.07" ofType:@"zip"];
    NSString *unzipPath = DOCUMENT_DIRECTORY_ROOT;
    BOOL success =  [SSZipArchive unzipFileAtPath:zipPath toDestination:unzipPath];
    NSLog(@"unzipPath: %@", unzipPath);
    if (success) {
//        [Answers logCustomEventWithName:@"unzip file success" customAttributes:nil];
        [self saveDataToDb];
        [self unzipImage];
    } else {
//        [Answers logCustomEventWithName:@"unzip file false" customAttributes:nil];
    }
}

- (void)unzipImage {
    NSString *zipPath = [DOCUMENT_DIRECTORY_ROOT stringByAppendingPathComponent:@"image.zip"];
    NSString *unzipPath = DOCUMENT_DIRECTORY_ROOT;

    BOOL success =  [SSZipArchive unzipFileAtPath:zipPath toDestination:unzipPath];
    if (success) {
        NSLog(@"Unzip Image Successfully");
    } else {
        NSLog(@"Unzip Image Error");
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
        
        [[NSUserDefaults standardUserDefaults] setObject:fileName forKey:KEY_LATEST_FILE_NAME];

        NSDateFormatter *dat = [[NSDateFormatter alloc] init];
        dat.dateFormat = @"dd-MM-yyyy HH:mm";

        [[NSUserDefaults standardUserDefaults] setObject:[dat stringFromDate:[NSDate date]] forKey:KEY_LAST_SYNCED_TIME];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
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
    [self saveDataToDbFrom:KEY_MEAL_SET_TABLE_FILE_NAME toTable:MEAL_SET_TABLE_NAME];
    [self saveDataToDbFrom:KEY_SELECTION_GROUP_TABLE_FILE_NAME toTable:SELECTION_GROUP_TABLE_NAME];
    [self saveDataToDbFrom:KEY_SELECTION_HEADER_TABLE_FILE_NAME toTable:SELECTION_HEADER_TABLE_NAME];
    [self saveDataToDbFrom:KEY_TAX_TABLE_FILE_NAME toTable:TAX_TABLE_NAME];
    [ProgressHUD dismiss];
    
    saveDataSuccess = YES;
    
    if (didClickStartButton) {
        SettingModel *setting = [ShareManager shared].setting;
        if (setting.selectMode == Quick_Serve) {
            [self showCategoriesScreen];
        } else if (setting.tableNo > 0 && setting.tableSelection == Fix_ed) {
            [self sendPOSRequest:SendSeated];
        } else {
            [self showStartOrderPopup];
        }
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

- (void)showStartOrderPopup {
    StartOrderController *vc = [[StartOrderController alloc] initWithNibName:@"StartOrderController" bundle:nil];
    vc.delegate = self;
    
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(vc.view.superview);
        make.width.height.equalTo(vc.view.superview);
    }];
}

- (void)showCategoriesScreen {
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

- (void)handleDataSendSeated:(NSData *)data {
    int location = REPLY_HEADER + REPLY_COMMAND_SIZE + REPLY_COMMAND_ID + REPLY_REQUEST_ID + REPLY_STORE_STATUS + REPLY_LAST_EVENT_ID;
    
    NSData *replyStatus = [data subdataWithRange:NSMakeRange(location, 4)];
    NSString *httpResponse = [Util hexadecimalString:replyStatus];
    if ([httpResponse isEqualToString:STATUS_REPLY_OK]) {
        location = location + REPLY_STATUS + REPLY_DATA_SIZE;
        
        /**XBillIdData**/
        NSData *billIdData = [data subdataWithRange:NSMakeRange(location, data.length - location)];
        NSData *billNoData = [billIdData subdataWithRange:NSMakeRange(0, 4)];
        int billNo = [Util hexStringToInt:[Util hexadecimalString:billNoData]];
        NSLog(@"%d", billNo);
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", billNo] forKey:KEY_SAVED_BILL_NO];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self showCategoriesScreen];
    } else {
        NSData *errorData = [replyStatus subdataWithRange:NSMakeRange(0, 2)];
        NSString *errorID = [Util hexadecimalString:errorData];
        [Util showError:errorID vc:self];
    }
}

@end
