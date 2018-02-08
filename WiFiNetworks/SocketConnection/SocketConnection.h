//
//  SocketConnection.h
//  WiFiNetworks
//
//  Created by Vineet Choudhary on 07/02/18.
//  Copyright © 2018 Finoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <netdb.h>
#import <sys/types.h>
#import <arpa/inet.h>
#import <sys/socket.h>
#import <netinet/in.h>

#import "DeviceInfo.h"

@interface SocketConnection : NSObject{
    
}

extern NSString *const kDeviceListUpdateNotification;
extern NSString *const kNormalMessageRecevicedNotification;

@property(nonatomic, strong) NSMutableArray<DeviceInfo *> *deviceList;

+(SocketConnection *)shared;
-(void)setupUdpClient;
-(void)sendBroadcastPacket;
-(void)receivePacketFromDevice;
-(void)sendBroadcastPacket:(NSString *)cmd;

@end
