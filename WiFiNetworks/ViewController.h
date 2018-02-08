//
//  ViewController.h
//  WiFiNetworks
//
//  Created by Vineet Choudhary on 06/02/18.
//  Copyright © 2018 Finoit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NetworkExtension/NetworkExtension.h>
#import <SystemConfiguration/CaptiveNetwork.h>

#import "HFSmartLink.h"
#import "Reachability.h"
#import "SocketConnection.h"
#import "HFSmartLinkDeviceInfo.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    __weak IBOutlet UILabel *connectedNetworkSSIDLabel;
    __weak IBOutlet UILabel *connectedNetworkBSSIDLabel;
    __weak IBOutlet UILabel *connectedNetworkSSIDDataLabel;
    __weak IBOutlet UITextField *ssidTextField;
    __weak IBOutlet UITextField *passwordTextField;
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
}

- (IBAction)connectButtonTapped:(UIButton *)sender;
- (IBAction)changeNetworkButtonTapped:(UIButton *)sender;

@end

