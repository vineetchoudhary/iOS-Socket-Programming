//
//  DeviceInfo.h
//  WiFiNetworks
//
//  Created by Vineet Choudhary on 07/02/18.
//  Copyright © 2018 Finoit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceInfo : NSObject

@property(nonatomic, strong) NSString *ip;
@property(nonatomic, strong) NSString *mac;
@property(nonatomic, strong) NSString *modelId;
@property(nonatomic, strong) NSString *message;
@property(nonatomic, assign) NSInteger sd_udp;

@end
