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


NSString* URL = @"http://10.3.13.204/";
double_t WAIT_TIME = 0.5;
double_t RETRY_AMMOUNT = 5;

@interface ViewController ()
//This has been typedef'd in NetworkManager.h
@property (nonatomic, copy) CompletionBlock completionBlock;
@property (nonatomic, strong) NetworkManager* netManager;
@property (nonatomic, strong) NSURL* ipAddress;
@property (nonatomic, assign) NSInteger retryCounter;

@property (nonatomic, strong) NSArray* ecgData;
@property (nonatomic, strong) NSArray* pulseData;
@property (nonatomic, strong) NSArray* spoData;

// GraphDataModels for each graph
@property (nonatomic,strong)GraphDataModel* bpmGraphData;
@property (nonatomic,strong)GraphDataModel* pulseGraphData;
@property (nonatomic,strong)GraphDataModel* spoGraphData;

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
@property (strong, nonatomic) IBOutlet UILabel *pulseLabel;
@property (strong, nonatomic) IBOutlet UILabel *pulseNumLabel;
@property (strong, nonatomic) IBOutlet UILabel *spoLabel;
@property (strong, nonatomic) IBOutlet UILabel *spoNumLabel;
@property (strong, nonatomic) IBOutlet UILabel *tempLabel;
@property (strong, nonatomic) IBOutlet UILabel *tempNumLabel;


@property (strong, nonatomic) IBOutlet UIButton *wifiButton;

@property(strong, nonatomic) UIFont* hiddenFont;
@property(strong, nonatomic) UIFont* showFont;
@property(strong, nonatomic) UIFont* labelRegular;
@property(strong, nonatomic) UIFont* numLabelRegular;

//Alarm
@property (strong,atomic) NSNumber* tempAlarmUpperThresh;
@property (strong,atomic) NSNumber* tempAlarmLowerThresh;
@property (strong,atomic) NSNumber* pulseAlarmUpper;
@property (strong,atomic) NSNumber* pulseAlarmLower;

@property (assign) int counter;

- (IBAction)testButton:(id)sender;


@end

@implementation ViewController

//Completion block for the Network Manager.
- (void) initalizeCompletionBlock{
    self.completionBlock = ^void(NSData* data, NSError* error){
        if(!error){
            NSLog(@"Connection Successful.");
            //Set wifi icon to green indicating connection was made.
            [self.wifiButton setBackgroundImage:[UIImage imageNamed:@"green_wifi"]
                                       forState:UIControlStateNormal];
            self.retryCounter = 0;
            [self storeDataAsJSON:data with:error];
            
            self.counter++;
            
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
            else{
                //Coonection failed.
                [self.wifiButton setBackgroundImage:[UIImage imageNamed:@"red_wifi"]
                                           forState:UIControlStateNormal];
            }
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
    [self loadInECGData];
    [self loadinPulseData];
    [self loadinSPOData];
    self.tempAlarmUpperThresh = [NSNumber numberWithInt:100];
    self.pulseAlarmUpper = [NSNumber numberWithInt:300];
    
    [self.wifiButton setBackgroundImage:[UIImage imageNamed:@"yellow_wifi.png"]
                               forState:UIControlStateNormal];
    
    //UI Code
   
    self.ParentView.autoresizesSubviews = YES;
    self.rowOne.autoresizesSubviews = NO;
    self.rowOne.clipsToBounds = YES;
    
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
    
    
    //Initialize the Graph Data Module
    self.bpmGraphData = [[GraphDataModel alloc] init];
    self.pulseGraphData = [[GraphDataModel alloc] init];
    self.spoGraphData = [[GraphDataModel alloc] init];
    
    
    // Set labels to static default values
    self.tempNumLabel.text = @"98";
    self.pulseNumLabel.text = @"90";
    self.bpmNumLabel.text = @"90";
    self.spoNumLabel.text = @"97%";
    
    
    
    //Add graphs to the view
    
    // Variables across all graphs
    double animationGraphEntranceTime = 2.5;
    bool enableBezierCurve = YES;
    
    // BPM
    self.bpmGraph = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(0, 0, 800, 175)];
    
    self.bpmGraph.colorTop = [UIColor blackColor];
    self.bpmGraph.colorBottom = [UIColor blackColor];
    self.bpmGraph.backgroundColor = [UIColor blackColor];
    self.bpmGraph.colorLine = [UIColor greenColor];
    
    self.bpmGraph.dataSource = self;
    self.bpmGraph.delegate = self;
    self.bpmGraph.enableBezierCurve = enableBezierCurve;
    self.bpmGraph.animationGraphEntranceTime = animationGraphEntranceTime;
    self.bpmGraph.animationGraphStyle = BEMLineAnimationDraw;
    
    
    [self.rowOne addSubview:self.bpmGraph];
    
    // PULSE
    self.pulseGraph = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(0, 0, 800, 175)];
    
    self.pulseGraph.colorTop = [UIColor blackColor];
    self.pulseGraph.colorBottom = [UIColor blackColor];
    self.pulseGraph.backgroundColor = [UIColor blackColor];
    self.pulseGraph.colorLine = [UIColor yellowColor];

    self.pulseGraph.dataSource = self;
    self.pulseGraph.delegate = self;
    self.pulseGraph.enableBezierCurve = enableBezierCurve;
    self.pulseGraph.animationGraphEntranceTime = animationGraphEntranceTime;
    self.pulseGraph.animationGraphStyle = BEMLineAnimationDraw;
    
    [self.rowTwo addSubview:self.pulseGraph];
    
    
    // SPO
    self.spoGraph = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(0, 0, 800, 175)];
    
    self.spoGraph.colorTop = [UIColor blackColor];
    self.spoGraph.colorBottom = [UIColor blackColor];
    self.spoGraph.backgroundColor = [UIColor blackColor];
    self.spoGraph.colorLine = [UIColor colorWithRed:68/255.0 green:178/255.0 blue:240/255.0 alpha:1.0];

    self.spoGraph.dataSource = self;
    self.spoGraph.delegate = self;
    self.spoGraph.enableBezierCurve = enableBezierCurve;
    self.spoGraph.animationGraphEntranceTime = animationGraphEntranceTime;
    self.spoGraph.animationGraphStyle = BEMLineAnimationDraw;
    
    [self.rowThree addSubview:self.spoGraph];
    
    [self reloadGraph:0 with:[self.bpmGraphData len]];
}

- (void)playGraphs: (UIButton*)sender {
    [self reloadGraph:0 with:[self.bpmGraphData len]];
}

- (void)reloadGraph: (int) start with: (int) fin {
    // Set all data for Graph Data Models
    for (int i=start; i<fin%[self.ecgData count]; i++) {
        [self.bpmGraphData addValue:[[self.ecgData objectAtIndex:i] doubleValue] ];
    }
    for (int i=start; i<fin%[self.pulseData count]; i++) {
        [self.pulseGraphData addValue:[[self.pulseData objectAtIndex:i] doubleValue] ];
    }
    for (int i=start; i<fin%[self.spoData count]; i++) {
        [self.spoGraphData addValue:[[self.spoData objectAtIndex:i] doubleValue] ];
    }
        
    // Reload Graph
    [self.bpmGraph reloadGraph];
    [self.pulseGraph reloadGraph];
    [self.spoGraph reloadGraph];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Given a row, 1 through 4, toggles the view and subviews.
// and resizes the adjacent views.
- (void) toggleRowView: (UIView*)row
                  with:(UILabel*)label
                   and:(UILabel*)numLabel{
    if(!row.hidden){
                [UIView animateWithDuration:1 animations:^{
            //Constraint overrides previous constraints, thus collapsing the view.
            [row addConstraint:[NSLayoutConstraint
                                        constraintWithItem:row
                                        attribute:NSLayoutAttributeHeight
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                        attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1
                                        constant:0]];

            //Takes care of properly shrinking UI labels inside the collapsing view.
            numLabel.transform = CGAffineTransformMakeScale(1, 0.00001);
            label.transform = CGAffineTransformMakeScale(1, 0.00001);
            [self.ParentView layoutSubviews];
            [row layoutIfNeeded];
            

        }
                         completion:^(BOOL finished){
                             row.hidden = YES;
                         }];
    }
    else{
        [UIView animateWithDuration:1 animations:^{
            row.hidden = NO;
            //Removes 0 height constraint.
            NSArray *tempConstraints = [row constraints];
            [row removeConstraint:[tempConstraints lastObject]];

            //Restores UI labels.
            numLabel.transform = CGAffineTransformMakeScale(1, 1);
            label.transform = CGAffineTransformMakeScale(1, 1);
            [self.ParentView layoutSubviews];
            [row layoutIfNeeded];

            
        }
                         completion:^(BOOL finished){
                         }];
        
    }
}
//Not Used.
//Increases a row and its subviews and resizes all other views
//on screen.
- (void) rowIncreaseSize: (UIView*)row
                    with:(UILabel*)label
                     and:(UILabel*)numLabel{
    if(!row.hidden){
        [UIView animateWithDuration:1 animations:^{
            
            [row addConstraint:[NSLayoutConstraint
                                constraintWithItem:row
                                attribute:NSLayoutAttributeHeight
                                relatedBy:NSLayoutRelationEqual
                                toItem:nil
                                attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1
                                constant:200]];
            numLabel.transform = CGAffineTransformMakeScale(1.5, 1.5);
            label.transform = CGAffineTransformMakeScale(1.5, 1.5);
            self.pulseNumLabel.transform = CGAffineTransformMakeScale(.5, .5);
            self.spoLabel.transform = CGAffineTransformMakeScale(.5, .5);
            self.spoNumLabel.transform = CGAffineTransformMakeScale(.5, .5);
        
            [self.ParentView layoutSubviews];
            [row layoutIfNeeded];
            
            
        }
                         completion:^(BOOL finished){
                            // row.hidden = YES;
                         }];
    }
    else{
        [UIView animateWithDuration:1 animations:^{
            row.hidden = NO;
            NSArray *tempConstraints = [row constraints];
            [row removeConstraint:[tempConstraints lastObject]];
            
            numLabel.transform = CGAffineTransformMakeScale(1, 1);
            label.transform = CGAffineTransformMakeScale(1, 1);
            [self.ParentView layoutSubviews];
            [row layoutIfNeeded];
            
            
        }
                         completion:^(BOOL finished){
                         }];
        
    }
}



-(void) toggleRowOne{
    [self toggleRowView:self.rowOne
                   with:self.bpmLabel
                    and:self.bpmNumLabel];
}

-(void) toggleRowTwo{
    [self toggleRowView:self.rowTwo
                   with:self.pulseLabel
                    and:self.pulseNumLabel];
}


- (IBAction)testButton:(id)sender {
    [self rowIncreaseSize:self.rowOne with:self.bpmLabel and:self.bpmNumLabel];
   // [self toggleRowOne];
}


- (IBAction)butTwo:(id)sender {
    [self toggleRowTwo];
}

- (IBAction)wifiPress:(id)sender {
    [self.netManager establishConnection:self.completionBlock];
}


/* Fake Data Methods */

-(void) loadInECGData{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"ecg" ofType:@"txt"];
    NSString *fileContents = [NSString stringWithContentsOfFile:path
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
    fileContents = [fileContents stringByReplacingOccurrencesOfString:@"\t"
                                                           withString:@""];
    self.ecgData = [fileContents componentsSeparatedByString:@"\n"];
}

-(void) loadinPulseData{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"pulse" ofType:@"txt"];
    NSString *fileContents = [NSString stringWithContentsOfFile:path
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
    fileContents = [fileContents stringByReplacingOccurrencesOfString:@"\t"
                                                           withString:@""];
    self.pulseData = [fileContents componentsSeparatedByString:@"\n"];
}

-(void) loadinSPOData{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"spo2" ofType:@"txt"];
    NSString *fileContents = [NSString stringWithContentsOfFile:path
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
    fileContents = [fileContents stringByReplacingOccurrencesOfString:@"\t"
                                                           withString:@""];
    self.spoData = [fileContents componentsSeparatedByString:@"\n"];
}
//Transfer data between two veiws.
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"settings"]){
        SettingsViewController* settings = (SettingsViewController*) segue.destinationViewController;
        settings.delegate = self;
        settings.tempAlarmLowerThresh = self.tempAlarmLowerThresh;
        settings.tempAlarmUpperThresh = self.tempAlarmUpperThresh;
        settings.pulseAlarmLower = self.pulseAlarmLower;
        settings.pulseAlarmUpper = self.pulseAlarmUpper;
        [self.navigationController pushViewController:settings
                                             animated:YES];
    }
}

- (void)addItemViewController:(SettingsViewController *)controller
        didFinishEnteringItem:(NSNumber *)tempAlarm
                          and:(NSNumber*) pulseAlarm{
    self.tempAlarmUpperThresh = tempAlarm;
    self.pulseAlarmUpper = pulseAlarm;
}


/* Graph methods */

// Graphing functions for the ECG Graph

#pragma mark - Data Source

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return [self.bpmGraphData len];
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    if ([graph isEqual:self.bpmGraph]) {
        return [self.bpmGraphData dmObjectAtIndex:(int)index];
    }
    else if ([graph isEqual:self.pulseGraph]) {
        return [self.pulseGraphData dmObjectAtIndex:(int)index];
    }
    else if ([graph isEqual:self.spoGraph]) {
        return [self.spoGraphData dmObjectAtIndex:(int)index];
    }
    else {
        return (double)0.0;
    }
}

#pragma mark - Delegate

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return 1;
}

- (NSString*)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    NSString* label = [[NSString alloc] init];
    label = @"%@", [self.bpmGraphData dmObjectAtIndex:index];
    return label;
}

@end
