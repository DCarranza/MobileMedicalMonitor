//
//  ViewController.m
//  MobileMonitor
//
//  Created by Diego Carranza on 11/13/14.
//  Copyright (c) 2014 tufts.edu. All rights reserved.
//

#import "ViewController.h"
#import "NetworkManager.h"
#import "DataModel.h"
#import "GraphDataModel.h"
#import <AVFoundation/AVFoundation.h>


NSString* URL = @"http://10.3.13.180/";
double_t WAIT_TIME = 1.0;
double_t RETRY_AMMOUNT = 5;

@interface ViewController ()

@property (nonatomic, strong) GraphDataModel *ecgGraphData;


//This has been typedef'd in NetworkManager.h
@property (nonatomic, copy) CompletionBlock completionBlock;
@property (nonatomic, strong) NetworkManager* netManager;
@property (nonatomic, strong) NSURL* ipAddress;
@property (nonatomic, assign) NSInteger retryCounter;


//UI SHIT
@property (strong, nonatomic) IBOutlet UIView *ParentView;
@property (strong, nonatomic) IBOutlet UIView *rowOne;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rowOneHeightConst;
@property (strong, nonatomic) IBOutlet UIView *rowOnePadding;
@property (strong, nonatomic) IBOutlet UIView *rowTwo;
@property (strong, nonatomic) IBOutlet UIView *rowThree;
@property (strong, nonatomic) IBOutlet UIView *rowFour;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rowThreeEqualRowTwoConst;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *threeAndOne;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *threeAndFour;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *oneAndTwo;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *oneAndFour;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *twoAndFour;

- (IBAction)testButton:(id)sender;
- (IBAction)testButtonTwo:(id)sender;
- (IBAction)testButtonThree:(id)sender;

@end

@implementation ViewController


- (void) initalizeCompletionBlock{
    self.completionBlock = ^void(NSData* data, NSError* error){
        if(!error){
            NSLog(@"Connection Successful.");
            self.retryCounter = 0;
            [self storeDataAsJSON:data with:error];
            //This call takes care of the sleeping
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, WAIT_TIME * NSEC_PER_SEC),
                           dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                           ^(){
                               [self.netManager establishConnection:self.completionBlock];
                           });
        }
        else{
            self.retryCounter++;
            NSLog(@"There was an error: %ld.", (long)self.retryCounter);
            
            /*// Send an alert to the user
             UIAlertView* retryAlert = [[UIAlertView alloc] initWithTitle:@"Something went wrong..." message:@"Ensure the device and wireless network are on." delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:nil];
             [retryAlert show];
             */
            if(self.retryCounter < RETRY_AMMOUNT)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, WAIT_TIME * NSEC_PER_SEC),
                               dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                               ^(){
                                   [self.netManager establishConnection:self.completionBlock];
                               });
        }
    };
    
}

- (void) storeDataAsJSON:(NSData*) data with:(NSError*) error{
    NSDictionary* rawData = [NSJSONSerialization JSONObjectWithData:data
                                                            options:kNilOptions error:&error];
    NSLog(@"Unconverted %@", rawData);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ParentView.autoresizesSubviews = YES;
    
    [self initalizeCompletionBlock];
    self.retryCounter = 0;
    self.ipAddress =[NSURL URLWithString:URL];
    self.netManager = [[NetworkManager alloc] initWithIPAddress:self.ipAddress];
    
    //Run network code
    [self.netManager establishConnection:self.completionBlock];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    // Test code for DataModel
    // TODO: REMOVE THIS CODE
    self.ecgGraphData = [[GraphDataModel alloc] init];
    [self.ecgGraphData addTestData];
    
    for (int i=0; i<7; i++) {
        [self.ecgGraphData addValue:i];
    }
    
    for (int i=0; i<self.ecgGraphData.perLen; i++) {
        NSLog(@"%@", [self.ecgGraphData.persistent objectAtIndex:i]);
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) toggleRowOneView{
    if(!self.rowOne.hidden){
        NSLog(@"%u", [[self.rowOne constraints] count]);
        [UIView animateWithDuration:1 animations:^{
            [self.rowOne addConstraint: [NSLayoutConstraint
                                         constraintWithItem:self.rowOne
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                         multiplier:1.0 constant:0.0]];
            //[self.rowOne setFrame:newFrame];
            //[self.ParentView updateConstraints];
            [self.ParentView layoutSubviews];
        }
                         completion:^(BOOL finished){
                            self.rowOne.hidden = YES;
                            NSLog(@"%u",[[self.rowOne constraints] count]);
                         }];
        
    }
    else{
        [UIView animateWithDuration:1.0 animations: ^{
            self.rowOne.hidden = NO;
            NSArray *tempConstraints  = [self.rowOne constraints];
            [self.rowOne removeConstraints:tempConstraints];
            [self.ParentView layoutSubviews];
        }
                         completion:^(BOOL finished){
                         }];
    }
}

- (void) toggleRowTwoView{
    if(!self.rowTwo.hidden){
        [UIView animateWithDuration:1 animations:^{
            [self.rowTwo addConstraint:[NSLayoutConstraint
                                        constraintWithItem:self.rowTwo
                                        attribute:NSLayoutAttributeHeight
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                        attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1.0
                                        constant:0]];
            [self.ParentView layoutSubviews];
        }
                         completion:^(BOOL finished){
                             self.rowTwo.hidden = YES;
                         }];
    }
    else{
        [UIView animateWithDuration:1 animations:^{
            self.rowTwo.hidden = NO;
            NSArray *tempConstraints = [self.rowTwo constraints];
            [self.rowTwo removeConstraints:tempConstraints];
            [self.ParentView layoutSubviews];
        }
                         completion:^(BOOL finished){
                         }];
    
    }
}

- (void) toggleRowView: (UIView*)row {
    if(!row.hidden){
        [UIView animateWithDuration:1 animations:^{
          /*[self.ParentView
           removeConstraint:self.rowThreeEqualRowTwoConst];
            [self.ParentView removeConstraint:self.threeAndFour];
            [self.ParentView removeConstraint:self.threeAndOne];
            [self.ParentView updateConstraints];
            [self.ParentView layoutSubviews];*/
           // self.twoAndFour.priority = 1000;
            //self.oneAndFour.priority = 1000;
            //self.oneAndTwo.priority = 1000;
            
            [row addConstraint:[NSLayoutConstraint
                                        constraintWithItem:row
                                        attribute:NSLayoutAttributeHeight
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                        attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1
                                        constant:0]];
            [self.ParentView layoutSubviews];
        }
                         completion:^(BOOL finished){
                             row.hidden = YES;
                         }];
    }
    else{
        [UIView animateWithDuration:1 animations:^{
            row.hidden = NO;
            NSArray *tempConstraints = [row constraints];
            [row removeConstraints:tempConstraints];
            [self.ParentView layoutSubviews];
        }
                         completion:^(BOOL finished){
                         }];
        
    }
}

- (IBAction)testButton:(id)sender {
    [self toggleRowView:self.rowOne];
}

- (IBAction)testButtonTwo:(id)sender {
    [self toggleRowView:self.rowTwo];
}

- (IBAction)testButtonThree:(id)sender {
    [self toggleRowView:self.rowFour];
    [self toggleRowView:self.rowThree];
    
    
    
    //Graph Code
}

@end
