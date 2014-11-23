//
//  GraphDataModel.m
//  MobileMonitor
//
//  Created by Diego Carranza on 11/22/14.
//  Copyright (c) 2014 tufts.edu. All rights reserved.
//

#import "GraphDataModel.h"

@implementation GraphDataModel

- (id) init {
    self = [super init];
    
    // Allocate/init reference indices
    self.curr = 0;
    self.len = 10000;
    
    // Allocate data storage
    self.dataModel = [[NSMutableArray init] alloc];
    self.persistent = [[NSArray init] alloc];
    
    // Init all data storage values to 0 (flat line at start)
    for (int i = 0; i < self.len; i++) {
        [self.dataModel addObject:[NSNumber numberWithInt:0]];
    };
    
    return self;
}

- (void) addValue:(int) newValue{
    self.dataModel[self.curr] = [NSNumber numberWithInt:newValue];
    self.curr += 1;
    
    if (self.curr > self.len) {
        self.curr = 0;
    }
}

- (NSArray*) getGraphDataModel {
    return [[NSArray alloc] initWithArray:self.dataModel];
}

- (void) addTestData {
    for (int i=0; i<self.len; i++) {
        self.dataModel[i] = [NSNumber numberWithInt:i];
    }
}


@end
