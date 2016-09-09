//
//  HeartrateZoneCell.h
//  Runtastic1
//
//  Created by Adam Lovastyik on 2014. 12. 01..
//  Copyright (c) 2014. Adam Lovastyik. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Displays time and percentage spent in a heart rate zone
 */
@interface HeartrateZoneCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel; /** Displays heart rate zone name */
@property (weak, nonatomic) IBOutlet UILabel *timeLabel; /** Displays time and percentage spent in zone */

/**
 *  Set up cell with data
 *
 *  @param name        Name of heart rate zone
 *  @param measured    Measurement
 *  @param duration    Total duration
 *  @param timeMeasure YEs if measurement in time
 */
- (void)setupWithZoneName:(NSString*)name measured:(long)measured totalDuration:(long)duration timeMeasure:(BOOL)timeMeasure;

@end
