//
//  Util.m
//  Teraoka
//
//  Created by Thuan on 11/9/17.
//  Copyright © 2017 ss. All rights reserved.
//

#import "Util.h"

@implementation Util
+ (NSString *)convertDataToString:(NSData *)myData {
    NSString *dataStr = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    return dataStr;
}
+ (void)saveFileToDocumentDirectory:(NSString *)dataStr {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"myData.zip"];
    [dataStr writeToFile:appFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
+ (NSString *)hexadecimalString:(NSData *)receivedData
{
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    
    const unsigned char *dataBuffer = (const unsigned char *)[receivedData bytes];
    
    if (!dataBuffer)
    {
        return [NSString string];
    }
    
    NSUInteger          dataLength  = [receivedData length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
    {
        [hexString appendFormat:@"%02x", (unsigned int)dataBuffer[i]];
    }
    
    return [NSString stringWithString:hexString];
}
@end
