//
//  GraphDataModel.h
//  MobileMonitor
//
//  Created by Diego Carranza on 11/22/14.
//  Copyright (c) 2014 tufts.edu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface GraphDataModel : NSObject

// Data storage
@property (nonatomic, strong) NSMutableArray* dataModel;
@property (nonatomic, strong) NSMutableArray* persistent;

// Internal index and length
@property (assign) int curr;
@property (assign) int len;
@property (assign) int perLen;

// Operators
- (void) addValue:(double) newValue;
- (void) addTestData;

// DataModel getters
- (NSMutableArray*) getDataModel;
- (NSNumber*) dataModelLen_NS;
- (int) dataModelLen_Int;
- (CGFloat) dmObjectAtIndex: (int) index;

// Persistent getters
- (NSMutableArray*) getPersistent;
- (NSNumber*) persistentLen_NS;
- (int) persistentLen_Int;
- (CGFloat) perObjectAtIndex: (int) index;

@end
