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
    self.perLen = 0;
    
    // Allocate & initialize data storage
    self.dataModel = [[NSMutableArray alloc] init];
    self.persistent = [[NSMutableArray alloc] init];
    
    // Init all data storage values to 0 (flat line at start)
    for (int i = 0; i < self.len; i++) {
        [self.dataModel addObject:[NSNumber numberWithInt:0]];
    };
    
    return self;
}

- (void) addValue:(int) newValue{
    
    // Replace current with newValue
    [self.dataModel replaceObjectAtIndex:self.curr withObject:[NSNumber numberWithInt:newValue]];
    
    // Store in persistent data
    [self.persistent addObject:[NSNumber numberWithInt:newValue]];
    self.perLen++;
    
    self.curr++;
    
    if (self.curr >= self.len) {
        self.curr = 0;
    }
}

- (NSArray*) getGraphDataModel {
    return [[NSArray alloc] initWithArray:self.dataModel];
}

- (void) addTestData {
    for (int i=0; i<self.len; i++) {
        [self.dataModel replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:i]];
    }
}


@end
