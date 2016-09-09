//
//  NSNumber+SportType.m
//  Runtastic1
//
//  Created by Adam Lovastyik on 2014. 12. 01..
//  Copyright (c) 2014. Adam Lovastyik. All rights reserved.
//

#import "NSNumber+SportType.h"

@implementation NSNumber (SportType)

- (NSString*)sportName {
    
    switch (self.integerValue) {
        case 1: return NSLocalizedString(@"Running", @"Running");
            break;
        case 2: return NSLocalizedString(@"Nordic Walking", @"Nordic Walking");
            break;
        case 3: return NSLocalizedString(@"Biking", @"Biking");
            break;
        case 4: return NSLocalizedString(@"Mountainbiking", @"Mountainbiking");
            break;
            
        default:
            return NSLocalizedString(@"Other", @"Other sport");
            break;
    }
        
}

@end
