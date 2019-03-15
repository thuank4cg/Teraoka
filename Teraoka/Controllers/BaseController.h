//
//  BaseController.h
//  Teraoka
//
//  Created by Thuan on 10/17/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParamsHelper.h"

@interface BaseController : UIViewController

- (IBAction)onBack:(id)sender;
- (void)sendPOSRequest:(CommandName)_commandName;
- (void)getExistingOrder;
- (void)loadLocalizable;
- (NSManagedObjectContext *)managedObjectContext;
- (void)handleDataSendSeated:(NSData *)data;
- (void)handleDataGetBillDetails:(NSData *)data;
- (void)handleDataGetBillHeader:(NSData *)data;

@end
