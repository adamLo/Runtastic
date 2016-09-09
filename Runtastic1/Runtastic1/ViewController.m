//
//  ViewController.m
//  Runtastic1
//
//  Created by Adam Lovastyik on 2014. 12. 01..
//  Copyright (c) 2014. Adam Lovastyik. All rights reserved.
//

#import "ViewController.h"
#import "SessionCell.h"
#import "HeartrateZonesViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *statusLabel; /** Displays operation status */
@property (weak, nonatomic) IBOutlet UITableView *sessionsTable; /** Displays sport sessions fetched from API */

@property (nonatomic, strong) NSArray* sportSessions; /** Sport sessions fetched from AI */

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Sessions", @"Sessions title");
    
    //Fetch Activities
    [self fetchActivities];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchActivities {
    
    //Construct URL
    NSURL *url = [NSURL URLWithString:@"http://codingcontest.runtastic.com/api/user/2/sport_sessions"];
    
    //Update status
    self.statusLabel.text = NSLocalizedString(@"Fetching activities...", @"Fetching status label");
    
    //Configure task
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              
                                              //Nice, we have a response
                                              if (!error) {
                                              
                                                  //Try parsing response
                                                  NSError *jsonError = nil;
                                                  NSDictionary *activities = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                                              
                                                  if (!jsonError) {
                                                      
                                                      //We have a valid response, count activities
                                                      self.sportSessions = activities[@"sport_sessions"];
                                                      NSInteger activityCount = [self.sportSessions count];
                                                      
                                                      NSLog(@"Count of activities: %ld", (long)activityCount);
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          self.statusLabel.text = [NSString stringWithFormat:@"Count of activities: %ld", (long)activityCount];
                                                          [self.sessionsTable reloadData];
                                                      });
                                                      
                                                  }
                                                  else {
                                                      //Something wrong with JSON
                                                      NSLog(@"Error parsing return value: %@", jsonError);
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          self.statusLabel.text = jsonError.localizedDescription;
                                                      });
                                                  }
                                                  
                                              }
                                              else {
                                                  //Something wrong with reponse
                                                  NSLog(@"Error fetching activities: %@", error);
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      self.statusLabel.text = error.localizedDescription;
                                                  });
                                                  
                                              }
                                              
                                          }];
    
    
    //Start task
    [downloadTask resume];
    
    
}


#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.sportSessions.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Dequeue cell
    SessionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SessionCell" forIndexPath:indexPath];
    
    //Configure cell
    NSDictionary *session = self.sportSessions[indexPath.row];
    [cell setupWithSession:session];
    
    return cell;
    
}

#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Clear selection
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    //Check if session contains heart rate
    NSDictionary *session = self.sportSessions[indexPath.row];
    if ([session[@"heartRateAvailable"] boolValue]) {
        
        //Go to heart rate zones detail screen
        [self performSegueWithIdentifier:@"heartrateZones" sender:session];
        
    }
    else {
        
        //Display alert
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", @"Alert title for no heart rate signal") message:NSLocalizedString(@"No heart rate information available for session", @"Error message for no heart rate available") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        
    }
    
}

#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"heartrateZones"]) {
        
        //Pass session to target
        HeartrateZonesViewController *target = segue.destinationViewController;
        [target setSession:sender];
        
    }
    
}

@end
