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
    self.len = 5; //10000;
    self.perLen = 0;
    
    // Allocate & initialize data storage
    self.dataModel = [[NSMutableArray alloc] init];
    self.persistent = [[NSMutableArray alloc] init];
    
    // Init all data storage values to 0 (flat line at start)
    for (int i = 0; i < self.len; i++) {
        [self.dataModel addObject:[NSNumber numberWithDouble:0.0]];
    };
    
    return self;
}

/* Data Storage Operators */

- (void) addValue:(double) newValue{
    
    // Replace current with newValue
    [self.dataModel replaceObjectAtIndex:self.curr withObject:[NSNumber numberWithDouble:newValue]];
    
    // Store in persistent data
    [self.persistent addObject:[NSNumber numberWithDouble:newValue]];
    self.perLen++;
    
    self.curr++;
    
    if (self.curr >= self.len) {
        self.curr = 0;
    }
}

- (void) addTestData {
    for (int i=0; i<self.len; i++) {
        [self.dataModel replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:i]];
    }
}


/* DataModel-specific getters/setters */

- (NSArray*) getDataModel {
    return [[NSArray alloc] initWithArray:self.dataModel copyItems:YES];
}

- (NSNumber*) dataModelLen_NS {
    return [NSNumber numberWithInt:self.len];
}

- (int) dataModelLen_Int {
    return self.len;
}

- (CGFloat) dmObjectAtIndex: (int) index {
    return [[self.dataModel objectAtIndex:index] doubleValue];
}


/* Persistent-specific getters/setters */

- (NSArray*) getPersistent {
    return [[NSArray alloc] initWithArray:self.persistent copyItems:YES];
}

- (NSNumber*) persistentLen_NS {
    return [NSNumber numberWithInt:self.perLen];
}

- (int) persistentLen_Int {
    return self.perLen;
}

- (CGFloat) perObjectAtIndex: (int) index {
    return [[self.persistent objectAtIndex:index] doubleValue];
}


@end
