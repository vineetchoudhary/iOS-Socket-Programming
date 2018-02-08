//
//  AppDelegate.h
//  WiFiNetworks
//
//  Created by Vineet Choudhary on 06/02/18.
//  Copyright © 2018 Finoit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

