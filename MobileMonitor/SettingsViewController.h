//
//  SettingsViewController.h
//  MobileMonitor
//
//  Created by Diego Carranza on 12/1/14.
//  Copyright (c) 2014 tufts.edu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingsViewController;
@protocol SettingsViewControllerDelegate <NSObject>
- (void)addItemViewController:(SettingsViewController *)controller
        didFinishEnteringItem:(NSNumber *)tempAlarm
                          and:(NSNumber*) pulseAlarm;
@end

@interface SettingsViewController : UIViewController

@property (strong,atomic) NSNumber* tempAlarmUpperThresh;
@property (strong,atomic) NSNumber* tempAlarmLowerThresh;
@property (strong,atomic) NSNumber* pulseAlarmUpper;
@property (strong,atomic) NSNumber* pulseAlarmLower;

@property (nonatomic, weak) id <SettingsViewControllerDelegate> delegate;


@end
