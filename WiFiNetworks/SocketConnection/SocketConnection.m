//
//  SocketConnection.m
//  WiFiNetworks
//
//  Created by Vineet Choudhary on 07/02/18.
//  Copyright © 2018 Finoit. All rights reserved.
//

#import "SocketConnection.h"

#define HF11A_SOCKET_HOST @"192.168.22.97"
#define HF11A_SOCKET_PORT 48899
#define UseCocoaAsyncSocket 1

NSString * const kDeviceListUpdateNotification = @"DeviceListUpdateNotification";
NSString * const kMessageSendNotification = @"MessageSendNotification";
NSString * const kMessageRecevicedNotification = @"NormalMessageRecevicedNotification";

@implementation SocketConnection {
    //socket setting
    int server_port;
    int sd_udp,sd_tcp,rc_udp,rc_tcp,length;
    struct sockaddr_in serveraddr,clientaddr;
    int serveraddrlen;
    int i;
    int switch_of_reg_server;
    int sd, rc,sd_b; //sd_b used for broad casting socket
    struct sockaddr_in broadcastAddr; // Make an endpoint
    int run_switch;
}

+(SocketConnection *)shared{
    static SocketConnection *socketConnection = nil;
    if (socketConnection == nil) {
        socketConnection = [[SocketConnection alloc] init];
        [socketConnection connectSocket];
    }
    return socketConnection;
}

-(void)connectSocket{
    if (UseCocoaAsyncSocket) {
        self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue() socketQueue:dispatch_get_main_queue()];
        NSError *error;
        
        if([self.udpSocket connectToHost:HF11A_SOCKET_HOST onPort:HF11A_SOCKET_PORT error:&error]){
            NSData *packet = [@"HF-A11ASSISTHREAD" dataUsingEncoding:NSUTF8StringEncoding];
            if (![self.udpSocket beginReceiving:&error]) {
                NSLog(@"GCDAsyncUdpSocket - Receive init Error - %@", error.localizedDescription);
            }
            [self.udpSocket sendData:packet withTimeout:30 tag:1];
        } else {
            NSLog(@"GCDAsyncUdpSocket - Connection Error - %@", error.localizedDescription);
        }
    } else {
        [self setupUdpClient];
        [self receivePacketFromDevice];
        [self sendBroadcastPacket:@"HF-A11ASSISTHREAD"];
    }
}

-(void)reconnectSocket{
    [self connectSocket];
}


#pragma mark - GCDAsyncUdpSocket -

#pragma mark Delegate


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    NSString *addressString = [[NSString alloc] initWithData:address encoding:NSUTF8StringEncoding];
    NSLog(@"GCDAsyncUdpSocket - Connected to address - %@", addressString);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError * _Nullable)error{
    NSLog(@"GCDAsyncUdpSocket - Error - %@", error.localizedDescription);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    NSLog(@"GCDAsyncUdpSocket - Send data with tag - %ld", tag);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError * _Nullable)error{
    NSLog(@"GCDAsyncUdpSocket - Didn't send data with tag - %ld and Error - %@", tag, error.localizedDescription);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(nullable id)filterContext{
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *addressString = [[NSString alloc] initWithData:address encoding:NSUTF8StringEncoding];
    NSLog(@"GCDAsyncUdpSocket - Received data - %@ from address - %@ and filter context - %@", dataString, addressString, filterContext);
    [[NSNotificationCenter defaultCenter] postNotificationName:kMessageRecevicedNotification object:dataString];
}


- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError  * _Nullable)error {
    NSLog(@"GCDAsyncUdpSocket - Socket did close - Error - %@", error.localizedDescription);
}














#pragma mark - Low level UDP connections -

-(void)setupUdpClient{
    //this function is to establish a client to send out broad cast to devices. App will call sendBroadcastPacket later to send broadcast packets using the socket created in this function.
    
    // Open a socket
    sd_b = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
    
    if (sd_b<=0) {
        NSLog(@"Error: Could not open socket");
    }
    
    // Set socket options
    int broadcastEnable=1;
    int ret=setsockopt(sd_b, SOL_SOCKET, SO_BROADCAST, &broadcastEnable, sizeof(broadcastEnable));
    if (ret) {
        NSLog(@"Error: Could not open set socket to broadcast mode. Broadcast network timeout.");
        close(sd_b);
        return;
    }
    
    //Configure the port and ip we want to send to, used for send udp
    memset(&broadcastAddr, 0, sizeof broadcastAddr);
    broadcastAddr.sin_family = AF_INET;
    inet_pton(AF_INET, "255.255.255.255", &broadcastAddr.sin_addr); // Set the broadcast IP address
    broadcastAddr.sin_port = htons(HF11A_SOCKET_PORT); // Set dst port
    
    // If we don't call bind() here, the system decides on the port for us, which is not we want.So below code is to set local port to 48899
    struct sockaddr_in sin;
    memset(&sin,0,sizeof(sin));
    sin.sin_family=AF_INET;
    sin.sin_port=htons(HF11A_SOCKET_PORT);
    sin.sin_addr.s_addr=INADDR_ANY;
    
    if (bind(sd_b,(struct sockaddr *)&sin,sizeof(struct sockaddr_in)) == -1) {
        NSLog(@"Bind port error in broadcast socket. Please try again.");
        return;
    }
}

-(void)sendBroadcastPacket {
    char buffer[255];
    bzero(buffer,255);
    // Open a socket
    int sd = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (sd<=0) {
        NSLog(@"Error: Could not open socket");
        return;
    }
    
    // Set socket options
    int broadcastEnable=1; // Enable broadcast
    int ret=setsockopt(sd, SOL_SOCKET, SO_BROADCAST, &broadcastEnable, sizeof(broadcastEnable));
    if (ret) {
        NSLog(@"Error: Could not open set socket to broadcast mode");
        close(sd);
        return;
    }
    
    // Since we don't call bind() here, the system decides on the port for us, which is what we want.
    // Configure the port and ip we want to send to
    struct sockaddr_in broadcastAddr; // Make an endpoint
    memset(&broadcastAddr, 0, sizeof broadcastAddr);
    
    broadcastAddr.sin_family = AF_INET;
    inet_pton(AF_INET, "255.255.255.255", &broadcastAddr.sin_addr); // Set the broadcast IP address
    broadcastAddr.sin_port = htons(HF11A_SOCKET_PORT); // Set dst port
    
    
    //below code is to set local port to 48899
    struct sockaddr_in sin;
    memset(&sin,0,sizeof(sin));
    sin.sin_family=AF_INET;
    sin.sin_port=htons(HF11A_SOCKET_PORT);
    sin.sin_addr.s_addr=INADDR_ANY;
    if (-1==bind(sd,(struct sockaddr *)&sin,sizeof(struct sockaddr_in))){
        return;
    }
    
    
    // Send the broadcast request, "HF-A11ASSISTHREAD"
    char *request = "HF-A11ASSISTHREAD";
    ret = (int)sendto(sd, request, strlen(request), 0, (struct sockaddr*)&broadcastAddr, sizeof broadcastAddr);
    if (ret<0) {
        NSLog(@"Error: Could not open send broadcast");
        close(sd);
        return;
    }
    
    // Get responses here using recvfrom if you want...
    rc_udp = (int)recvfrom(sd_udp, (void*)buffer, strlen(buffer), 0, (struct sockaddr *)&serveraddr, (socklen_t *) &serveraddrlen);
    
    if(rc_udp < 0) {
        perror("UDP Client - recvfrom() error");
        close(sd_udp);
    } else {
        NSLog(@"received: %s",buffer);
        // receive is ok
    }
    close(sd);
}

-(void)receivePacketFromDevice{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char buffer[10240];
        char *bufptr = buffer;
        int buflen = sizeof(buffer);
        struct sockaddr_in udp_client_addr;
        int udp_client_addr_len = sizeof(udp_client_addr);
        
        NSLog(@"UDP Server - ReceivePacketFromDevice - Listening...\n");
        NSLog(@"UDP Server - ReceivePacketFromDevice - Run Switch = %d",run_switch);
        
        while(1){
            bzero(buffer,10240);
            rc = (int)recvfrom(sd_b, bufptr, buflen, 0, (struct sockaddr *)&udp_client_addr, (socklen_t *)&udp_client_addr_len);
            if(rc < 0) {
                perror("UDP Server - ReceivePacketFromDevice - recvfrom() Error : ");
                return;
            } else {
                NSLog(@"UDP Server - ReceivePacketFromDevice - recvfrom() is OK.");
                
                //Parse recevied string, "ip,mac,model id"
                NSString* string = [NSString stringWithFormat:@"%s" , bufptr];
                NSLog(@"UDP Server - ReceivePacketFromDevice - Received %s",bufptr);
                
                //If string is not matching patern "*,*,*" then ignore below steps:
                NSString *regEx = @"^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(.?)){4},[0-9A-Z]{12},[0-9A-Z]*";
                NSRange myRange = [string rangeOfString:regEx options:NSRegularExpressionSearch];
                
                if (myRange.location == NSNotFound){
                    NSLog(@"UDP Server - ReceivePacketFromDevice - Normal msg: %@", string);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kMessageRecevicedNotification object:string];
                    });
                } else {
                    NSLog(@"UDP Server - ReceivePacketFromDevice - Device Info msg : %@",string);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString* string = [NSString stringWithFormat:@"%s" , bufptr];
                        NSArray *listItems = [string componentsSeparatedByString:@","];
                        
                        if (listItems.count == 3) {
                            NSLog(@"UDP Server - ReceivePacketFromDevice - Device Info 0 %@",[listItems objectAtIndex:0]);
                            NSLog(@"UDP Server - ReceivePacketFromDevice - Device Info 1 %@",[listItems objectAtIndex:1]);
                            NSLog(@"UDP Server - ReceivePacketFromDevice - Device Info  2 %@",[listItems objectAtIndex:2]);
                            
                            DeviceInfo* currentDevice = [[DeviceInfo alloc]init];
                            [currentDevice setMessage:string];
                            [currentDevice setIp:[listItems objectAtIndex:0]];
                            [currentDevice setMac:[listItems objectAtIndex:1]];
                            [currentDevice setModelId:[listItems objectAtIndex:2]];
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceListUpdateNotification object:[currentDevice message]];
                            [self.deviceList addObject:currentDevice];
                        } else {
                            NSLog(@"UDP Server - ReceivePacketFromDevice - Invalid Device Info");
                        }
                    });
                }
                
            }
        }
    });
}

-(void)sendBroadcastPacket:(NSString *)cmd{
    if (UseCocoaAsyncSocket) {
        NSData *packet = [cmd dataUsingEncoding:NSUTF8StringEncoding];
        [self.udpSocket sendData:packet withTimeout:30 tag:1];
        return;
    }
    char buffer[255];
    bzero(buffer,255);
    char request[100];
    bzero(request,100);
    strcpy (request ,[cmd UTF8String]);
    
    //for more accurate result remove typecast
    int ret = (int)sendto(sd_b, request, strlen(request), 0, (struct sockaddr*)&broadcastAddr, sizeof broadcastAddr);
    
    //    [NSThread sleepForTimeInterval:0.05];
    //    ret = sendto(sd_b, request, strlen(request), 0, (struct sockaddr*)&broadcastAddr, sizeof broadcastAddr);
    //    [NSThread sleepForTimeInterval:0.05];
    //    ret = sendto(sd_b, request, strlen(request), 0, (struct sockaddr*)&broadcastAddr, sizeof broadcastAddr);
    
    if (ret<0) {
        NSLog(@"Error:Send broadcast error. Network timeout,Could not send broadcast,please go to home page and start again.");
        close(sd_b);
        exit(-1);
        return;
    }
    //  close(sd_b);
    return;
}

@end

