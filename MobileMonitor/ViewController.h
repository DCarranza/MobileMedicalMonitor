//
//  ViewController.h
//  MobileMonitor
//
//  Created by Diego Carranza on 11/13/14.
//  Copyright (c) 2014 tufts.edu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMSimpleLineGraphView.h"
#import "SettingsViewController.h"


@interface ViewController : UIViewController <SettingsViewControllerDelegate, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>

@property (strong, nonatomic) IBOutlet BEMSimpleLineGraphView *bpmGraph;
@property (strong, nonatomic) IBOutlet BEMSimpleLineGraphView *pulseGraph;
@property (strong, nonatomic) IBOutlet BEMSimpleLineGraphView *spoGraph;

@end

