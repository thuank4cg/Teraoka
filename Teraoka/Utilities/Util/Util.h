//
//  Util.h
//  Teraoka
//
//  Created by Thuan on 11/9/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject
+ (NSString *)convertDataToString:(NSData *)myData;
+ (void)saveFileToDocumentDirectory:(NSString *)dataStr;
@end
