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
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserverForName:kDeviceListUpdateNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        commandOutputTextView.text = [NSString stringWithFormat:@"UDP Server Device - %@\n%@", note.object, commandOutputTextView.text];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:kNormalMessageRecevicedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        commandOutputTextView.text = [NSString stringWithFormat:@"UDP Server Normal Msg - %@\n%@", note.object, commandOutputTextView.text];
    }];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)sendButtonTapped:(UIButton *)sender {
    if (commandInputTextField.text.length > 0) {
        [socketConnection sendBroadcastPacket:commandInputTextField.text];
    } else {
        NSLog(@"Input command first...");
    }
}
@end
