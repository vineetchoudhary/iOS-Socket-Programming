//
//  TerminalViewController.h
//  WiFiNetworks
//
//  Created by Vineet Choudhary on 08/02/18.
//  Copyright © 2018 Finoit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketConnection.h"

@interface TerminalViewController : UIViewController{
    
    __weak IBOutlet UITextField *commandInputTextField;
    __weak IBOutlet UIButton *sendButton;
    __weak IBOutlet UITextView *commandOutputTextView;
}
- (IBAction)sendButtonTapped:(UIButton *)sender;

@end
