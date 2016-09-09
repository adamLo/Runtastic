//
//  HeartrateZonesViewController.h
//  Runtastic1
//
//  Created by Adam Lovastyik on 2014. 12. 01..
//  Copyright (c) 2014. Adam Lovastyik. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Displays how mane time and percantage spent in each heart rate zones in given session
 */
@interface HeartrateZonesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSDictionary *session; /** Sport session */

@end
