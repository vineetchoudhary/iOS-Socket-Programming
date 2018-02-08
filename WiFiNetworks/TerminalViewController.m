//
//  TerminalViewController.m
//  WiFiNetworks
//
//  Created by Vineet Choudhary on 08/02/18.
//  Copyright © 2018 Finoit. All rights reserved.
//

#import "TerminalViewController.h"

@implementation TerminalViewController{
    SocketConnection *socketConnection;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"Terminal";
    socketConnection = [SocketConnection shared];
    if (!socketConnection.udpSocket.isConnected) {
        [socketConnection reconnectSocket];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserverForName:kDeviceListUpdateNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        commandOutputTextView.text = [NSString stringWithFormat:@"UDP Server Device - %@%@", note.object, commandOutputTextView.text];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:kMessageRecevicedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if ([note.object length] > 1) {
            commandOutputTextView.text = [NSString stringWithFormat:@"Recevie - %@%@", note.object, commandOutputTextView.text];
        }
    }];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)sendButtonTapped:(UIButton *)sender {
    if (commandInputTextField.text.length > 0) {
        commandOutputTextView.text = [NSString stringWithFormat:@"Send - %@\n%@", commandInputTextField.text, commandOutputTextView.text];
        [socketConnection sendBroadcastPacket:commandInputTextField.text];
        [commandInputTextField setText:@""];
    } else {
        NSLog(@"Input command first...");
    }
}
@end
