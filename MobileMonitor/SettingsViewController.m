//
//  SettingsViewController.m
//  MobileMonitor
//
//  Created by Diego Carranza on 12/1/14.
//  Copyright (c) 2014 tufts.edu. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (strong, nonatomic) IBOutlet UITextField *pulseT;
@property (strong, nonatomic) IBOutlet UITextField *tempT;
@property (strong, nonatomic) IBOutlet UIButton *exitButton;

@end

@implementation SettingsViewController
- (IBAction)pulseText:(id)sender {
    self.pulseAlarmUpper = [NSNumber numberWithInt:[self.pulseT.text intValue]];
}
- (IBAction)tempText:(id)sender {
    self.tempAlarmUpperThresh = [NSNumber numberWithInt:[self.tempT.text intValue]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.pulseT setDelegate:self];
    [self.tempT setDelegate:self];
    self.pulseT.text = [self.pulseAlarmUpper stringValue];
    self.tempT.text = [self.tempAlarmUpperThresh stringValue];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)exit:(id)sender {
    [self.delegate addItemViewController:self didFinishEnteringItem:self.tempAlarmUpperThresh
                                     and:self.pulseAlarmUpper];
    [self dismissViewControllerAnimated:YES completion:nil];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
