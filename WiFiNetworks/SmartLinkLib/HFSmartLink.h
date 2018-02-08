//
//  HFSmartLink.h
//  SmartlinkLib
//
//  Created by Vineet Choudhary on 06/02/2018.
//  Copyright (c) 2018 Vineet Choudhary. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HFSmartLinkDeviceInfo.h"

typedef void(^SmartLinkProcessBlock)(NSInteger process);
/**
 *  After the success of the set Block
 *
 *  @param dev  device information
 */
typedef void(^SmartLinkSuccessBlock)(HFSmartLinkDeviceInfo *dev);
/**
 *  Set the failed message
 *
 *  @param failmsg Failure information
 */
typedef void(^SmartLinkFailBlock)(NSString * failmsg);
/**
 *  User manually stopped block
 *
 *  @param stopMsg Stopped message
 *  @param isOk    Whether to stop succeeding
 */
typedef void(^SmartLinkStopBlock)(NSString *stopMsg,BOOL isOk);
/**
 *  Shut down the service Block
 *
 *  @param closeMsg Close the message
 *  @param isOK     Whether to close the success
 */
typedef void(^SmartLinkCloseBlock)(NSString * closeMsg,BOOL isOK);
/**
 *  Discover the device block
 *
 *  @param deviceDic Discover the device
 */
typedef void(^SmartLinkEndblock)(NSDictionary * deviceDic);

@interface HFSmartLink : NSObject
/**
 *  Whether to configure a single device, or multiple devices by default false
 */
@property (nonatomic) BOOL isConfigOneDevice;
/**
 *  After the configuration information is sent, wait for the device to be searched second (default 15)
 */
@property (nonatomic) NSInteger waitTimers;

/**
 *  Obtain smartlink Single case
 *
 *  @return return smartlink Single case
 */
+(instancetype)shareInstence;
/**
 *  Start to configure block (Can not be nil)
 *
 *  @param key    Router password
 *  @param pblock schedule block
 *  @param sblock success block
 *  @param fblock failure block
 *  @param eblock End block
 */
//-(void)startWithKey:(NSString*)key processblock:(SmartLinkProcessBlock)pblock successBlock:(SmartLinkSuccessBlock)sblock failBlock:(SmartLinkFailBlock)fblock endBlock:(SmartLinkEndblock)eblock;

-(void)startWithSSID:(NSString*)ssid Key:(NSString*)key withV3x:(BOOL)v3x processblock:(SmartLinkProcessBlock)pblock successBlock:(SmartLinkSuccessBlock)sblock failBlock:(SmartLinkFailBlock)fblock endBlock:(SmartLinkEndblock)eblock;
// for smartlink V7.0
//-(void)startWithContent:(char *)content lenght:(int)len key:(NSString *)key withV3x:(BOOL)v3x processblock:(SmartLinkProcessBlock)pblock successBlock:(SmartLinkSuccessBlock)sblock failBlock:(SmartLinkFailBlock)fblock endBlock:(SmartLinkEndblock)eblock;
/**
 *  Stop the configuration
 *
 *  @param block Stop configuration block
 */
-(void)stopWithBlock:(SmartLinkStopBlock)block;
/**
 *  Close the whole Smartlink service，When calling again, you must initialize it from scratch.
 *
 *  @param block Close the service block
 */
-(void)closeWithBlock:(SmartLinkCloseBlock)block;
@end
