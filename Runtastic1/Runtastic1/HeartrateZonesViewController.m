//
//  HeartrateZonesViewController.m
//  Runtastic1
//
//  Created by Adam Lovastyik on 2014. 12. 01..
//  Copyright (c) 2014. Adam Lovastyik. All rights reserved.
//

#import "HeartrateZonesViewController.h"
#import "HeartrateZoneCell.h"

@interface HeartrateZonesViewController() {
    
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *measureToggle; /** Lets user change between tme and distance */

@property (weak, nonatomic) IBOutlet UITableView *zoneTable; /** Displays heart rate zones */

@property (nonatomic, strong) NSArray *zoneData; /** Contains calculated heart rate zone informations */
@property (nonatomic, strong) NSArray *fetchedData; /** Original data fetched from API */

@property (nonatomic, strong) NSArray *zoneSpecs; /** Contains heart rate zone specifications */

@property (nonatomic, assign) long totalDuration; /** Total duration calculated from heart rate data */

@end

@implementation HeartrateZonesViewController

//Heart rate zone constants
NSString* const kZoneId = @"id";
NSString* const kZoneName = @"name";
NSString* const kZoneMin = @"min";
NSString* const kZoneMax = @"max";

//Calculated data constants
NSString* const kZoneMeasure = @"measure";

#pragma mark UI LifeCycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Heart rate in zones", @"Heart rate detail screen title");
    
    [self.measureToggle setTitle:NSLocalizedString(@"Time", @"Time measure toggle title") forSegmentAtIndex:0];
    [self.measureToggle setTitle:NSLocalizedString(@"Distance", @"Distance toggle title") forSegmentAtIndex:1];
    self.measureToggle.selectedSegmentIndex = 0;
    self.measureToggle.enabled = NO;
    
    //Set up zone specs
    [self setupZones];
    
    //Fetch heart rate data
    [self fetchHeartRateData];
    
}

- (void)setupZones {
    
    self.zoneSpecs = @[
                       @{
                           kZoneId: @1,
                           kZoneName: NSLocalizedString(@"Easy", @"Easy zone"),
                           kZoneMin: @90,
                           kZoneMax: @119
                           },
                       @{
                           kZoneId: @2,
                           kZoneName: NSLocalizedString(@"Fat burning", @"Fat burning zone"),
                           kZoneMin: @120,
                           kZoneMax: @139
                           },
                       @{
                           kZoneId: @3,
                           kZoneName: NSLocalizedString(@"Aerobic", @"Aerobic zone"),
                           kZoneMin: @140,
                           kZoneMax: @159
                           },
                       @{
                           kZoneId: @4,
                           kZoneName: NSLocalizedString(@"Anaerobic", @"Anaerobic zone"),
                           kZoneMin: @160,
                           kZoneMax: @171
                           },
                       @{
                           kZoneId: @5,
                           kZoneName: NSLocalizedString(@"Red line", @"Red line zone"),
                           kZoneMin: @172,
                           kZoneMax: @179
                           },
                       @{
                           kZoneId: @6,
                           kZoneName: NSLocalizedString(@"Not in any zone", @"Not in zone title"),
                           kZoneMin: @(MAXFLOAT),
                           kZoneMax: @(-MAXFLOAT)
                           }
                       ];
    
    
}

#pragma mark Fetch and calculate

- (void)fetchHeartRateData {
    
    if (self.session[@"id"]) {
        
        //Construct URL
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://codingcontest.runtastic.com/api/user/2/sport_sessions/%@/heart_rate_trace", self.session[@"id"]]];
        
        //Configure task
        NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                              dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                  
                                                  //Nice, we have a response
                                                  if (!error) {
                                                      
                                                      //Try parsing response
                                                      NSError *jsonError = nil;
                                                      NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                                                      
                                                      if (!jsonError) {
                                                          
                                                          //We have a valid response, calculate zone data
                                                          dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                                                              self.fetchedData = fetchedData;
                                                              self.zoneData = [self calculateZoneData];
                                                              
                                                              dispatch_async(dispatch_get_main_queue(), ^(void) {
                                                                  [self.zoneTable reloadData];
                                                              
                                                                  self.measureToggle.enabled = YES;
                                                              });
                                                          });
                                                          
                                                      }
                                                      else {
                                                          //Something wrong with JSON
                                                          NSLog(@"Error parsing return value: %@", jsonError);
                                                      }
                                                      
                                                  }
                                                  else {
                                                      //Something wrong with reponse
                                                      NSLog(@"Error fetching heart rate zone data: %@", error);
                                                      
                                                  }
                                                  
                                              }];
        
        
        //Disable toggler
        self.measureToggle.enabled = NO;
        
        //Start task
        [downloadTask resume];
        
    }
    
}

- (NSArray*)calculateZoneData {
    
    NSArray *sortedData = [self.fetchedData sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if (self.measureToggle.selectedSegmentIndex == 0) {
            //Sort on time
            return [obj1[@"duration"] compare:obj2[@"duration"]];
        }
        else {
            //Sort on distance
            return [obj1[@"distance"] compare:obj2[@"distance"]];
        }
    }];
    
    //Will contain temporary calculated data
    NSMutableDictionary *calcData = [NSMutableDictionary new];
    
    long prevMeasure = 0; //Previous measurement stamp
    long prevHR = -999; //Previous heart rate
    
    for (NSDictionary *data in sortedData) {
        
        long nextHR = [data[@"heart_rate"] longValue];
        long currentMeasure = (self.measureToggle.selectedSegmentIndex == 0) ? [data[@"duration"] longValue] : [data[@"distance"] longValue];
        long spent = currentMeasure - prevMeasure;
        
        NSString *zoneId = [self.zoneSpecs lastObject][kZoneId];
        
        //Check if data fits in any zone
        for (NSDictionary *zone in self.zoneSpecs) {
            if (prevHR && (prevHR >= [zone[kZoneMin] integerValue]) && (prevHR <= [zone[kZoneMax] integerValue])) {
                 zoneId = zone[kZoneId];
            }
        }
        
        NSNumber *inZone = calcData[zoneId];
        if (!inZone) {
            //Not yet added
            inZone = @0;
        }
        
        //Add time to zone data        
        inZone = [NSNumber numberWithLong:[inZone longValue] + spent];
        calcData[zoneId] = inZone;
        
        prevMeasure = currentMeasure;
        prevHR = nextHR;
        
    }
    
    self.totalDuration = prevMeasure;
    
    //Order data by zone id
    NSMutableArray *temp = [NSMutableArray new];
    for (NSNumber *zoneId in calcData) {
        [temp addObject:@{
                          kZoneId: zoneId,
                          kZoneMeasure: calcData[zoneId]
                          }];
    }
    
    return [temp sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1[kZoneId] compare:obj2[kZoneId]];
    }];
}


#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.zoneData.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Dequeue cell
    HeartrateZoneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"zoneCell" forIndexPath:indexPath];
    
    //Configure cell data
    NSDictionary *data = self.zoneData[indexPath.row];
    
    NSString *zoneName;
    for (NSDictionary *zonespec in self.zoneSpecs) {
        if ([zonespec[kZoneId] isEqualToNumber:data[kZoneId]]) {
            zoneName = zonespec[kZoneName];
        }
    }
    
    long zoneMeasure = [data[kZoneMeasure] longValue];
    [cell setupWithZoneName:zoneName measured:zoneMeasure totalDuration:self.totalDuration timeMeasure:(self.measureToggle.selectedSegmentIndex == 0)];
    
    return cell;
    
}

# pragma mark Toggle

- (IBAction)measureToggleChanged:(UISegmentedControl *)sender {
    
    self.measureToggle.enabled = NO;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
    
        self.zoneData = [self calculateZoneData];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
        
            self.measureToggle.enabled = YES;
            [self.zoneTable reloadData];
        });
    });
    
}

@end
