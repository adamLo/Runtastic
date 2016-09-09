//
//  SessionCell.h
//  Runtastic1
//
//  Created by Adam Lovastyik on 2014. 12. 01..
//  Copyright (c) 2014. Adam Lovastyik. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  displays a sport session
 */
@interface SessionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *idLabel; /** Displays session id */
@property (weak, nonatomic) IBOutlet UILabel *typeLabel; /** Displays session type */
@property (weak, nonatomic) IBOutlet UILabel *durationLabel; /** Displays session duration */

/**
 *  Set up cell with given session
 *
 *  @param session Session data
 */
- (void)setupWithSession:(NSDictionary*)session;

@end
