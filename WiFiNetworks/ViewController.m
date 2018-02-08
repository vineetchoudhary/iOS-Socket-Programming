//
//  ViewController.m
//  WiFiNetworks
//
//  Created by Vineet Choudhary on 06/02/18.
//  Copyright © 2018 Finoit. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController{
    NSMutableArray *wifiNetworks;
    HFSmartLink *smartLink;
    SocketConnection *socketConnection;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    wifiNetworks = [[NSMutableArray alloc] init];
    [self getConnectedWiFiNetworkInfo];
    [self loadWiFiNetwork];
    //[self setupSmartLink];
    socketConnection = [SocketConnection shared];
}

-(void)viewDidAppear:(BOOL)animated{
    [self addObservers];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self removeObservers];
}

#pragma mark - Observers
-(void)addObservers{
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [self getConnectedWiFiNetworkInfo];
    }];
}

-(void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - SmartLink
-(void)setupSmartLink{
    smartLink = [HFSmartLink shareInstence];
    smartLink.isConfigOneDevice = YES;
    smartLink.waitTimers = 30;
}

-(void)scanDevice{
    Reachability *reachability = [Reachability reachabilityForLocalWiFi];
    if ([reachability currentReachabilityStatus] != NotReachable) {
        NSLog(@"WIFI connection required!!!");
    }
}

#pragma mark - WiFi Information

-(void)loadWiFiNetwork{
//    [[NEHotspotHelper supportedNetworkInterfaces] enumerateObjectsUsingBlock:^(NEHotspotNetwork * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSLog(@"%@", obj.SSID);
//    }];
    NSLog(@"List Scan START");
    
    NSMutableDictionary* options = [[NSMutableDictionary alloc] init];
    [options setObject:@"vineet" forKey:kNEHotspotHelperOptionDisplayName];
    dispatch_queue_t queue = dispatch_queue_create("com.miro.wifilist", 0);
    
    BOOL isAvailable = [NEHotspotHelper registerWithOptions:options queue:queue handler: ^(NEHotspotHelperCommand * cmd) {
        if (cmd.commandType == kNEHotspotHelperCommandTypeEvaluate || cmd.commandType == kNEHotspotHelperCommandTypeFilterScanList ) {
            for (NEHotspotNetwork* network in cmd.networkList) {
                NSLog(@"%@", network.SSID);
            }
        } else {
            NSLog(@"there is no available wifi");
        }
    }];
    
    if (isAvailable) {
        NSLog(@"true");
    } else {
        NSLog(@"false");
    }
    
    NSLog(@"List scan END");
}

-(void)getConnectedWiFiNetworkInfo{
    __block NSString *ssid;
    __block NSString *bssid;
    __block NSString *ssidData;
    NSArray *interfaces = (NSArray *)CFBridgingRelease(CNCopySupportedInterfaces());
    [interfaces enumerateObjectsUsingBlock:^(id  _Nonnull interface, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *interfaceInfo = CFBridgingRelease(CNCopyCurrentNetworkInfo((CFStringRef)interface));
        if (interfaceInfo) {
            NSLog(@"%@", interfaceInfo);
            ssid = [interfaceInfo valueForKey:(NSString *)kCNNetworkInfoKeySSID];
            bssid = [interfaceInfo valueForKey:(NSString *)kCNNetworkInfoKeyBSSID];
            NSData *data = [interfaceInfo valueForKey:(NSString *)kCNNetworkInfoKeySSIDData];
            ssidData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }];
    [ssidTextField setText:ssid];
    [connectedNetworkSSIDLabel setText:ssid];
    [connectedNetworkBSSIDLabel setText:bssid];
    [connectedNetworkSSIDDataLabel setText:ssidData];
}

#pragma mark - Actions
- (IBAction)changeNetworkButtonTapped:(UIButton *)sender {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{UIApplicationOpenURLOptionUniversalLinksOnly:@0} completionHandler:^(BOOL success) {
                NSLog(@"Redirected to settings %@", [NSNumber numberWithBool:success]);
            }];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (IBAction)connectButtonTapped:(UIButton *)sender {
    [activityIndicator startAnimating];
    [smartLink startWithSSID:ssidTextField.text Key:passwordTextField.text withV3x:YES processblock:^(NSInteger process) {
        
    } successBlock:^(HFSmartLinkDeviceInfo *dev) {
        NSLog(@"Device IP Address - %@\nMAC Address - %@", dev.ip, dev.mac);
        [activityIndicator stopAnimating];
    } failBlock:^(NSString *failmsg) {
        NSLog(@"Failed to connect - %@", failmsg);
        [activityIndicator stopAnimating];
    } endBlock:^(NSDictionary *deviceDic) {
        NSLog(@"Device Data - %@", deviceDic);
        [activityIndicator stopAnimating];
    }];
}

#pragma mark - UITableViewDelegate and Datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return wifiNetworks.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] init];
}
@end
