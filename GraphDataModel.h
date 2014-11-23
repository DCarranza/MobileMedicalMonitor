//
//  GraphDataModel.h
//  MobileMonitor
//
//  Created by Diego Carranza on 11/22/14.
//  Copyright (c) 2014 tufts.edu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GraphDataModel : NSObject

@property (nonatomic, strong) NSMutableArray* dataModel;
@property (nonatomic, strong) NSArray* persistent;
@property (assign) int curr;
@property (assign) int len;

@end
