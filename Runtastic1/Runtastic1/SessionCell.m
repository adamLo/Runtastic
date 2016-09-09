//
//  SessionCell.m
//  Runtastic1
//
//  Created by Adam Lovastyik on 2014. 12. 01..
//  Copyright (c) 2014. Adam Lovastyik. All rights reserved.
//

#import "SessionCell.h"
#import "NSNumber+SportType.h"

@implementation SessionCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithSession:(NSDictionary *)session {
    
    NSLog(@"Session: %@", session);
    
    //Set up cell labels
    self.idLabel.text = session[@"id"] ? [NSString stringWithFormat:@"%@", session[@"id"]] : @"N/A";
    
    self.typeLabel.text = session[@"sportTypeId"] ? [session[@"sportTypeId"] sportName] : @"N/A";
    
    //Format duration
    if (session[@"duration"]){
        long duration = [session[@"duration"] longValue];
        NSInteger hours = (long) (duration / 3600000);
        duration -= (hours * 3600000);
        NSInteger minutes = (long) (duration / 60000);
        duration -= (minutes * 60000);
        float seconds = duration / 1000;
    
        self.durationLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02.00f", (long)hours, (long)minutes, seconds];
    }
    else {
        self.durationLabel.text = @"N/A";
    }
    
    //Show disclosure indicator for sessions with heart rate
    BOOL heartRateAvailable = [session[@"heartRateAvailable"] boolValue];
    self.accessoryType = heartRateAvailable ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    
}

@end
