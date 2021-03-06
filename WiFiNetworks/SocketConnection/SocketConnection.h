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

@import CocoaAsyncSocket;

@interface SocketConnection : NSObject <GCDAsyncUdpSocketDelegate>{
    
}

extern NSString *const kDeviceListUpdateNotification;
extern NSString *const kMessageSendNotification;
extern NSString *const kMessageRecevicedNotification;

@property(nonatomic, strong) NSMutableArray<DeviceInfo *> *deviceList;
@property(nonatomic, strong) GCDAsyncUdpSocket *udpSocket;

+(SocketConnection *)shared;
-(void)setupUdpClient;
-(void)reconnectSocket;
-(void)sendBroadcastPacket;
-(void)receivePacketFromDevice;
-(void)sendBroadcastPacket:(NSString *)cmd;

@end
