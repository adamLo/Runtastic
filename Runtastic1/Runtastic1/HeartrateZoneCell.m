//
//  HeartrateZoneCell.m
//  Runtastic1
//
//  Created by Adam Lovastyik on 2014. 12. 01..
//  Copyright (c) 2014. Adam Lovastyik. All rights reserved.
//

#import "HeartrateZoneCell.h"

@implementation HeartrateZoneCell

- (void)setupWithZoneName:(NSString*)name measured:(long)measured totalDuration:(long)duration timeMeasure:(BOOL)timeMeasure {

    //Show zone name
    self.nameLabel.text = name;
    
    NSString *durationString;
    
    if (timeMeasure) {
        //Show time
        long calcTime = measured;
        NSInteger hours = (long) (calcTime / 3600000);
        calcTime -= (hours * 3600000);
        NSInteger minutes = (long) (calcTime / 60000);
        calcTime -= (minutes * 60000);
        float seconds = calcTime / 1000;
    
        //Format time
        durationString = [NSString stringWithFormat:@"%02ld:%02ld:%02.00f", (long)hours, (long)minutes, seconds];
    }
    else {
        durationString = [NSString stringWithFormat:@"%01.02f km", (double) measured / 1000.0];
    }
    
    //Format percent
    NSString *percentString = duration ? [NSString stringWithFormat:@"%.01f", (double) measured / (double) duration * 100.0] : @"N/A";
    
    self.timeLabel.text = [NSString stringWithFormat:@"%@ (%@%%)", durationString, percentString];
    
}

@end
