//
//  ViewController.m
//  MobileMonitor
//
//  Created by Diego Carranza on 11/13/14.
//  Copyright (c) 2014 tufts.edu. All rights reserved.
//

#import "ViewController.h"
#import "NetworkManager.h"
#import "GraphDataModel.h"
#import <AVFoundation/AVFoundation.h>


NSString* URL = @"http://10.3.13.180/";
double_t WAIT_TIME = 1.0;
double_t RETRY_AMMOUNT = 5;

@interface ViewController ()
//This has been typedef'd in NetworkManager.h
@property (nonatomic, copy) CompletionBlock completionBlock;
@property (nonatomic, strong) NetworkManager* netManager;
@property (nonatomic, strong) NSURL* ipAddress;
@property (nonatomic, assign) NSInteger retryCounter;

// GraphDataModels for each graph
@property (nonatomic,strong)GraphDataModel* ecgGraphData;
@property (nonatomic,strong)GraphDataModel* pulseGraphData;

//UI
@property (strong, nonatomic) IBOutlet UIView *ParentView;
@property (strong, nonatomic) IBOutlet UIView *rowOne;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rowOneHeightConst;
@property (strong, nonatomic) IBOutlet UIView *rowOnePadding;
@property (strong, nonatomic) IBOutlet UIView *rowTwo;
@property (strong, nonatomic) IBOutlet UIView *rowThree;
@property (strong, nonatomic) IBOutlet UIView *rowFour;


@property (strong, nonatomic) IBOutlet UILabel *bpmLabel;
@property (strong, nonatomic) IBOutlet UILabel *bpmNumLabel;



- (IBAction)testButton:(id)sender;


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
    
    //UI Code
    //WORK IN PROGRESS
    self.ParentView.autoresizesSubviews = YES;
    self.rowOne.autoresizesSubviews = YES;
    self.bpmNumLabel.adjustsFontSizeToFitWidth = YES;
    self.bpmNumLabel.minimumScaleFactor = .5f;
    self.bpmLabel.adjustsFontSizeToFitWidth = YES;
    self.bpmLabel.minimumScaleFactor = .5f;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bpmLabel.preferredMaxLayoutWidth = self.bpmLabel.bounds.size.width;
        self.bpmNumLabel.preferredMaxLayoutWidth = self.bpmNumLabel.bounds.size.width;
    });
    
    [self initalizeCompletionBlock];
    self.retryCounter = 0;
    self.ipAddress =[NSURL URLWithString:URL];
    self.netManager = [[NetworkManager alloc] initWithIPAddress:self.ipAddress];
    
    
    //Run network code
    [self.netManager establishConnection:self.completionBlock];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    //Initialize the Graph Module
    self.ecgGraphData = [[GraphDataModel alloc] init];
    self.pulseGraphData = [[GraphDataModel alloc] init];
    
    // Add test data to both, for testing purposes
    [self.ecgGraphData addTestData];
    [self.pulseGraphData addTestData];
    
    //Add graphs to the view
    BEMSimpleLineGraphView *bpmGraph = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    bpmGraph.dataSource = self;
    bpmGraph.delegate = self;
    [self.rowOne addSubview:bpmGraph];
    
    BEMSimpleLineGraphView *pulseGraph = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    pulseGraph.dataSource = self;
    pulseGraph.delegate = self;
    [self.rowTwo addSubview:pulseGraph];
    
    BEMSimpleLineGraphView *spoGraph = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    spoGraph.dataSource = self;
    spoGraph.delegate = self;
    [self.rowThree addSubview:spoGraph];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) toggleRowView: (UIView*)row {
    if(!row.hidden){
        [UIView animateWithDuration:1 animations:^{
            
            [row addConstraint:[NSLayoutConstraint
                                        constraintWithItem:row
                                        attribute:NSLayoutAttributeHeight
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                        attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1
                                        constant:0]];
            [self.ParentView layoutSubviews];
            [self.rowOne layoutIfNeeded];

        }
                         completion:^(BOOL finished){
                             row.hidden = YES;
                         }];
    }
    else{
        [UIView animateWithDuration:1 animations:^{
            row.hidden = NO;
            NSArray *tempConstraints = [row constraints];
            NSLog(@"%@", tempConstraints);
            [row removeConstraint:[tempConstraints lastObject]];
           // [self.bpmNumLabel sizeToFit];
           // [self.bpmLabel sizeToFit];
            [self.ParentView layoutSubviews];
        }
                         completion:^(BOOL finished){
                         }];
        
    }
}
- (IBAction)testButton:(id)sender {
    [self toggleRowView:self.rowOne];
}


- (IBAction)butTwo:(id)sender {
    [self toggleRowView:self.rowTwo];
}

- (IBAction)testButtonThree:(id)sender {
    [self toggleRowView:self.rowFour];
    [self toggleRowView:self.rowThree];
}

/* Graph methods */

// Graphing functions for the ECG Graph

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    NSLog(@"point: %f", [self.ecgGraphData dmObjectAtIndex:index]);
    return [self.ecgGraphData dmObjectAtIndex:index];
}

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    NSLog(@"%d", [[self.ecgGraphData persistentLen_NS] intValue]);
    return [[self.ecgGraphData persistentLen_NS] intValue];
}

@end
