//
//  SplashController.m
//  Teraoka
//
//  Created by Thuan on 12/7/18.
//  Copyright © 2018 ss. All rights reserved.
//

#import "SplashController.h"
#import "APPConstants.h"
#import "Util.h"
#import "DeliousSelfOrderController.h"
#import "EnterLicenseController.h"

@interface SplashController ()

@end

@implementation SplashController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *content;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:KEY_CURRENT_CONTENT_LANGUAGE]) {
        content = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_CURRENT_CONTENT_LANGUAGE];
    } else {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"english" ofType:@"csv"];
        content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    }
    
    [Util setLanguage:content];
    
    UIViewController *rootVC;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:KEY_LICENSE_VALID]) {
        rootVC = [[DeliousSelfOrderController alloc] initWithNibName:@"DeliousSelfOrderController" bundle:nil];
    } else {
        rootVC = [[EnterLicenseController alloc] initWithNibName:@"EnterLicenseController" bundle:nil];
    }
    
    if (rootVC) {
        appDelegate.window.rootViewController = rootVC;
        [appDelegate.window makeKeyAndVisible];
    }
}

@end
