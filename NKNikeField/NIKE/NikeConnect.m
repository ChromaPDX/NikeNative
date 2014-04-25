//
//  NikeConnect.m
//  Nico
//
//  Created by Robby on 7/9/13.
//  Copyright (c) 2013 robbykraft. All rights reserved.
//

#import "NikeConnect.h"
#import "PAPCache.h"
#import "PAPConstants.h"
#import "ParseController.h"


#define resolution 120 // data points in one day
/*
 so long as a user is logged in, NSUserDefaults @"userName" is their name for database and key in "people"
*/

@interface NikeConnect ()



@end

@implementation NikeConnect
@synthesize delegate;
@synthesize database;

-(id) init{
    self = [super init];
    if(self){
        //people = [[NSMutableDictionary alloc] init];
        //[self disconnect];
    }
    return self;
}
-(BOOL)isConnected { return [Nike isLoggedIn]; }

-(void)connect{
    if (![Nike isLoggedIn]){
        NSLog(@"Logging in to Nike...");
        [Nike logInWithCompletion:^(BOOL success, id json, NSError *error){
            
            if (success) {
                 [self loadDataBase];
            }
//            if (![[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]) {
//                NSLog(@"Nike has Logged In (T/F): %d",[Nike isLoggedIn]);
//                
//                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Hello" message:@"What is your name?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
//                [alertView setDelegate:self];
//                [alertView show];
//            }
//            else {
//                [self loadDataBase];
//            }

            
        }];
    }
}
//-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    NSLog(@"settingUserName: %@",[[alertView textFieldAtIndex:0] text]);
//    [[NSUserDefaults standardUserDefaults] setObject:[[alertView textFieldAtIndex:0] text] forKey:@"userName"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    [self loadDataBase];
//    
//}

-(void)loadDataBase {
    
//    [self openDatabase:[NSString stringWithFormat:@"%@.sqlite",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]]];
//    if([people objectForKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]] == nil){
//        [people setObject:[[NSMutableDictionary alloc] init] forKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]];
//    }
    [delegate connectionSuccessful];

}


-(void)disconnect{
    if([Nike isLoggedIn]){
        NSLog(@"Logging out of Nike Connect");
        [Nike logOut];
        //[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userName"];
        [ParseController cacheToUserDefaults];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)request10Days{
    [self requestDataOfSize:@10 Offset:@1 useParse:YES];
}
-(void)requestCascadingDataOfMonths:(NSInteger)months{
    for(int i = 0; i < months; i++)
        [self performSelector:@selector(monthlyRequest:) withObject:[NSNumber numberWithInt:i] afterDelay:i*10.0];
}

-(void)monthlyRequest:(NSNumber*) offset{
    [self requestDataOfSize:@30 Offset:[NSNumber numberWithInt:[offset integerValue]*30+1] useParse:YES];
}

- (void)requestDataOfSize:(NSNumber*)count Offset:(NSNumber*)offset useParse:(BOOL)useParse {
    NSDictionary *params = @{@"offset": offset, @"count": count};
    
    [Nike performRequestWithHTTPMethod:NikeHTTPMethodGET path:@"/me/sport/activities" parameters:params bodyData:nil completion:^(BOOL success, id json, NSError *error) {
        if (success){
            //NSLog(@"JSON: %@",json);
            
            NSMutableArray *NikeConnectActivity = [[NSMutableArray alloc] initWithArray:[json objectForKey:@"data"]];
            
            // MAKE SURE OUR DICTIONARIES ARE MUTABLE
            
            NSMutableDictionary *player = [[[ParseController sharedInstance].playerCache objectForKey:[[PFUser currentUser] username]] mutableCopy];

            if (!player) {
                
                NSLog(@"adding new player: %@ to parse cache", [[PFUser currentUser] username]);
                
                player = [[NSMutableDictionary alloc] init];
            }
            
            [[ParseController sharedInstance].playerCache setObject:player forKey:[[PFUser currentUser] username]];
            
            NSMutableDictionary *fuel = [[player objectForKey:FUEL_DATA_KEY] mutableCopy];

            if (!fuel) {
                NSLog(@"player has no fuel data yet");
                
                fuel = [[NSMutableDictionary alloc] init];
                
                [player setObject:fuel forKey:FUEL_DATA_KEY];
                
            }
            
            [player setObject:fuel forKey:FUEL_DATA_KEY];
            
            for(NSDictionary *element in NikeConnectActivity){
                if([[element objectForKey:@"deviceType"] isEqualToString:@"FUELBAND"]){

                    [self requestParseObjectForDay:[element objectForKey:@"activityId"] Date:[element objectForKey:@"startTime"] forDict:(fuel)];
        
                }
            }
            
        }
        
        else{
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedFailureReason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

//-(void)requestMetrics:(NSString*)activityId Date:(NSString*)dateLong{
//    NSString *path = [@"/me/sport/activities/" stringByAppendingString:activityId];
//    [Nike performRequestWithHTTPMethod:NikeHTTPMethodGET path:path parameters:nil bodyData:nil completion:^(BOOL success, id json, NSError *error) {
//        if(success){
//            NSLog(@"Getting details of %@",[json objectForKey:@"startTime"]);
//            NSMutableDictionary *compressedMetrics = [NSMutableDictionary dictionary];
//            for(NSDictionary *metric in [json objectForKey:@"metrics"])
//                [compressedMetrics setObject:[self compressArray:[metric objectForKey:@"values"]]
//                                      forKey:[metric objectForKey:@"metricType"]];
//            [self updateDatabaseAtActivityId:activityId
//                                    withFuel:[NSKeyedArchiver archivedDataWithRootObject:[compressedMetrics objectForKey:@"FUEL"]]
//                                       Steps:[NSKeyedArchiver archivedDataWithRootObject:[compressedMetrics objectForKey:@"STEPS"]]
//                                    Calories:[NSKeyedArchiver archivedDataWithRootObject:[compressedMetrics objectForKey:@"CALORIES"]]];
//
//            NSString *date = [dateLong substringToIndex:10];
//            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:activityId, @"activityId",
//                                         [compressedMetrics objectForKey:@"FUEL"], @"fuel",
//                                         [compressedMetrics objectForKey:@"STEPS"], @"steps",
//                                         [compressedMetrics objectForKey:@"CALORIES"], @"calories",
//                                         [[json objectForKey:@"metricSummary"] objectForKey:@"fuel"], @"totalFuel",
//                                         [[json objectForKey:@"metricSummary"] objectForKey:@"steps"], @"totalSteps",
//                                         [[json objectForKey:@"metricSummary"] objectForKey:@"calories"], @"totalCalories",
//                                         [[json objectForKey:@"metricSummary"] objectForKey:@"distance"], @"totalDistance",
//                                         nil];
//            
//            
//            [[people objectForKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]] setObject:data forKey:date];
//            
//            
//            
//            [delegate dataDidUpdate];
//        }
//        else
//            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedFailureReason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//    }];
//}

-(void)requestParseObjectForDay:(NSString*)activityId Date:(NSString*)dateLong forDict:(NSMutableDictionary*)activity{
    
    NSString *path = [@"/me/sport/activities/" stringByAppendingString:activityId];
    

    [Nike performRequestWithHTTPMethod:NikeHTTPMethodGET path:path parameters:nil bodyData:nil completion:^(BOOL success, id json, NSError *error) {
        if(success){
            //NSLog(@"Getting details of %@",[json objectForKey:@"startTime"]);
            
            NSMutableDictionary *compressedMetrics = [NSMutableDictionary dictionary];
            
            for(NSDictionary *metric in [json objectForKey:@"metrics"])
                [compressedMetrics setObject:[self compressArray:[metric objectForKey:@"values"]]
                                      forKey:[metric objectForKey:@"metricType"]];
            
            
            NSString *date = [dateLong substringToIndex:10];
            

            
            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:activityId, @"activityId",
                                         [compressedMetrics objectForKey:@"FUEL"], @"fuel",
                                         [compressedMetrics objectForKey:@"STEPS"], @"steps",
                                         [compressedMetrics objectForKey:@"CALORIES"], @"calories",
                                         [[json objectForKey:@"metricSummary"] objectForKey:@"fuel"], @"totalFuel",
                                         [[json objectForKey:@"metricSummary"] objectForKey:@"steps"], @"totalSteps",
                                         [[json objectForKey:@"metricSummary"] objectForKey:@"calories"], @"totalCalories",
                                         [[json objectForKey:@"metricSummary"] objectForKey:@"distance"], @"totalDistance",
                                         nil];
            
   
   
            

                // THIS WILL SAVE API CALLS EVENTUALLY

            
            //            for (NSString *s in activity.allKeys) {
            //                if ([s isEqualToString:date]) {
            //                    return;
            //                }
            //            }
       
            [activity setObject:data forKey:date];
            
            [[ParseController sharedInstance] addFuelDataToUser:data forKey:date];
            
            
        }
        
                 
        
        
        
    }];
    //  [self.parentViewController dismissModalViewControllerAnimated:YES];
}




-(NSArray*)compressArray:(NSArray*)array{
    NSInteger part = 0;
    NSInteger sum = 0;
    NSMutableArray *sums = [NSMutableArray array];
    for(int i = 0; i < array.count; i++){
        if(i > array.count/resolution*(part+1)){
            [sums setObject:[NSNumber numberWithInteger:sum] atIndexedSubscript:part];
            part++;
            sum = 0;
        }
        else
            sum+=[[array objectAtIndex:i] integerValue];
    }
    return sums;
}
-(void)loadAllPriorLogins{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSLog(@"Documents Directory Contents: %@",[fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil]);
    NSArray *databases = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    for(NSString *fileName in databases){
        [self openDatabase:fileName];
        NSLog(@"Loading %@",[fileName substringWithRange:NSMakeRange(0, fileName.length-7)]);
        
        //[people setObject:[self extractDatabase] forKey:[fileName substringWithRange:NSMakeRange(0, fileName.length-7)]];
        
        [self closeDatabase];
    }
    [delegate dataDidUpdate];
    
}

- (void)openDatabase:(NSString*)fileName {
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSString *dbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"nike.sqlite"];
    //create database if necessary
    if(![fileManager fileExistsAtPath:path])
        [fileManager copyItemAtPath:dbPath toPath:path error:&error];
    //open database
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        sqlite3_exec(database, "PRAGMA cache_size = 1;PRAGMA synchronous = 0;", NULL, NULL, NULL);
    }
}
- (NSDictionary*)extractDatabase {
    // refreshes ACTIVITY object with data from the database if available
    NSMutableDictionary *activity = [NSMutableDictionary dictionary];
    sqlite3_stmt *statement = nil;
    const char *sql = [@"SELECT activityId, FUEL, STEPS, CALORIES, totalFuel, totalSteps, totalCalories, totalDistance, date FROM fuelband" UTF8String];
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement)==SQLITE_ROW) {
            char *activityIdChars = (char *) sqlite3_column_text(statement, 0);
            NSString *activityId = [[NSString alloc] initWithUTF8String:activityIdChars];
            int fuelLength = sqlite3_column_bytes(statement, 1);
            NSData *fuelData = [[NSData dataWithBytes:sqlite3_column_blob(statement, 1) length:fuelLength] copy];
            int stepsLength = sqlite3_column_bytes(statement, 2);
            NSData *stepsData = [[NSData dataWithBytes:sqlite3_column_blob(statement, 2) length:stepsLength] copy];
            int caloriesLength = sqlite3_column_bytes(statement, 3);
            NSData *caloriesData = [[NSData dataWithBytes:sqlite3_column_blob(statement, 3) length:caloriesLength] copy];
            int totalFuel = sqlite3_column_int(statement, 4);
            int totalSteps = sqlite3_column_int(statement, 5);
            int totalCalories = sqlite3_column_int(statement, 6);
            double totalDistance = sqlite3_column_double(statement, 7);
            char *dateChars = (char *) sqlite3_column_text(statement, 8);
            NSString *date = [[[NSString alloc] initWithUTF8String:dateChars] substringToIndex:10];
            // test against fuel data
            if(fuelLength == 0)
                NSLog(@"data for %@ still being requested",date);
            else if([activity objectForKey:date] == nil){
                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:activityId, @"activityId",
                                      [NSKeyedUnarchiver unarchiveObjectWithData:fuelData], @"fuel",
                                      [NSKeyedUnarchiver unarchiveObjectWithData:stepsData], @"steps",
                                      [NSKeyedUnarchiver unarchiveObjectWithData:caloriesData], @"calories",
                                      [NSNumber numberWithInteger:totalFuel], @"totalFuel",
                                      [NSNumber numberWithInteger:totalSteps], @"totalSteps",
                                      [NSNumber numberWithInteger:totalCalories], @"totalCalories",
                                      [NSNumber numberWithDouble:totalDistance], @"totalDistance",
                                      nil];
                [activity setObject:data forKey:date];
                NSLog(@"adding %@ to memory",date);
            }
            else
                NSLog(@"%@ already logged in memory",date);
        }
        sqlite3_finalize(statement);
    }
    else
        NSLog(@"Error preparing the SQL");
    return activity;
}

-(void)closeDatabase{
    sqlite3_close(database);
}



-(BOOL) createDatabaseEntryWithActivityId:(NSString*)activityId Date:(NSString*)date Summary:(NSDictionary*)metricSummary{
    BOOL success = false;
    sqlite3_stmt *statement = nil;
    const char *sql = [@"INSERT INTO fuelband(activityId,date,totalFuel,totalCalories,totalSteps,totalDistance) Values(?,?,?,?,?,?)" UTF8String];
    if(sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
        NSLog(@"[SQLITE] Error when preparing query");
    sqlite3_bind_text(statement, 1, [activityId UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 2, [date UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(statement, 3, [[metricSummary objectForKey:@"fuel"] integerValue]);
    sqlite3_bind_int(statement, 4, [[metricSummary objectForKey:@"calories"] integerValue]);
    sqlite3_bind_int(statement, 5, [[metricSummary objectForKey:@"steps"] integerValue]);
    sqlite3_bind_double(statement, 6, [[metricSummary objectForKey:@"distance"] doubleValue]);
    if(sqlite3_step(statement) == SQLITE_DONE)
        success = true;
    sqlite3_finalize(statement);

    if(!success){
        // an entry for this day already exists, check if it needs updating
        sqlite3_stmt *statement = nil;
        const char *sql = [@"SELECT totalFuel FROM fuelband WHERE activityId=?" UTF8String];
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [activityId UTF8String], -1, SQLITE_TRANSIENT);
            if(sqlite3_step(statement) != SQLITE_ROW)
                NSLog(@"Error when making the step, database is corrupt");
            int totalFuel = sqlite3_column_int(statement, 0);
            sqlite3_finalize(statement);
            //NSLog(@"%@ since last update: (%d :: %d)",date,totalFuel, [[metricSummary objectForKey:@"fuel"] integerValue]);
            if(totalFuel != [[metricSummary objectForKey:@"fuel"] integerValue]){
                NSLog(@"%@ has since been updated, must refresh database",date);
                sqlite3_stmt *statement = nil;
                const char *sql = [@"UPDATE fuelband SET date=?,totalFuel=?,totalCalories=?,totalSteps=?,totalDistance=? WHERE activityId=?" UTF8String];
                if(sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
                    NSLog(@"[SQLITE] Error when preparing query");
                sqlite3_bind_text(statement, 1, [date UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_int(statement, 2, [[metricSummary objectForKey:@"fuel"] integerValue]);
                sqlite3_bind_int(statement, 3, [[metricSummary objectForKey:@"calories"] integerValue]);
                sqlite3_bind_int(statement, 4, [[metricSummary objectForKey:@"steps"] integerValue]);
                sqlite3_bind_double(statement, 5, [[metricSummary objectForKey:@"distance"] doubleValue]);
                sqlite3_bind_text(statement, 6, [activityId UTF8String], -1, SQLITE_TRANSIENT);
                if(sqlite3_step(statement) == SQLITE_DONE){
                    success = true;
                    NSLog(@"%@ successfully updated from an incomplete update",date);
                }
                sqlite3_finalize(statement);
            }
        }
    }
    else
        NSLog(@"%@ successfully created from scratch",date);
    return success;
}

-(void) updateDatabaseAtActivityId:(NSString*)activityId withFuel:(NSData*)fuel Steps:(NSData*)steps Calories:(NSData*)calories{
    sqlite3_stmt *statement=nil;
    const char *sql = "UPDATE fuelband SET fuel=?, steps=?, calories=? WHERE activityId=?";
    if(sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
        NSLog(@"[SQLITE] Error when preparing query");
    sqlite3_bind_blob(statement, 1, [fuel bytes], [fuel length], SQLITE_TRANSIENT);
    sqlite3_bind_blob(statement, 2, [steps bytes], [steps length], SQLITE_TRANSIENT);
    sqlite3_bind_blob(statement, 3, [calories bytes], [calories length], SQLITE_TRANSIENT);
    sqlite3_bind_text(statement, 4, [[NSString stringWithFormat:@"%@",activityId] UTF8String], -1, SQLITE_TRANSIENT);
    if(sqlite3_step(statement) != SQLITE_DONE)
        NSLog(@"[SQLITE] Error when making the step");
    sqlite3_finalize(statement);
}

@end
