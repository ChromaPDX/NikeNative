//
//  GameStatsViewController.m
//  ChromaNSFW
//
//  Created by Leif Shackelford on 11/25/13.
//  Copyright (c) 2013 Chroma. All rights reserved.
//

#import "GameStatsViewController.h"
#import "Game.h"
#import "NSData+CocoaDevUsersAdditions.h"

@interface GameStatsViewController ()

@end

@implementation GameStatsViewController

- (id)initWithGame:(Game *)game style:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
        _game = game;
        
        // Custom initialization
//        _match = match;
//        
//        NSData *comp = _match.matchData;
//        
//        NSLog(@"compressed size: %d", comp.length);
//        NSData *data = [comp gzipInflate];
//        
//        //NSData *data = comp;
//        NSLog(@"uncompressed size: %d", data.length);
//        
//        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
//        
//        _matchInfo = [unarchiver decodeObjectForKey:@"matchInfo"];
        
        
    }
    return self;
    
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIPanGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];

    [self.view addGestureRecognizer:tap];
    
    NSLog(@"META VIEW DID LOAD");
    [self.tableView reloadData];
    
}

-(void)handleTap:(UITapGestureRecognizer*)recognizer {
    //[self.view removeFromSuperview];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
  
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return @"GAME STATS";
    }
    
    else if (section == 1){
        return @"TEAM STATS";
    }
    

    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 0) {
        _matchInfo = _game.matchInfo;
        return _game.matchInfo.allKeys.count;
    }
    
    else if (section == 1){
        _matchInfo = [_game metaDataForManager:_game.me];
        return  _matchInfo.allKeys.count;
        
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];

    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, tableView.bounds.size.width, cell.bounds.size.height);
    
    if (indexPath.section == 0){
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:cell.frame];
        
        NSString *title = [_matchInfo.allKeys[indexPath.row] uppercaseString];
        NSString *value = _matchInfo.allValues[indexPath.row];
        
        label.text = [NSString stringWithFormat:@"%@ : %@", title, value];
        
        [cell addSubview:label];
        
    }

    else if (indexPath.section == 1){
        
        NSDictionary *m1 = [_game metaDataForManager:_game.me];
        NSDictionary *m2 = [_game metaDataForManager:_game.opponent];
        
        UILabel *label = [[UILabel alloc] initWithFrame:cell.frame];
        UILabel *label2 = [[UILabel alloc] initWithFrame:cell.frame];
        UILabel *label3 = [[UILabel alloc] initWithFrame:cell.frame];
    
        NSString *title = [m1.allKeys[indexPath.row] uppercaseString];
        
        label.text = [NSString stringWithFormat:@".    %@", m1.allValues[indexPath.row]];
        label2.text = [NSString stringWithFormat:@"%@", title];
        label3.text = [NSString stringWithFormat:@"%@    .", m2.allValues[indexPath.row]];

        label2.textAlignment = NSTextAlignmentCenter;
        label3.textAlignment = NSTextAlignmentRight;
        
        [cell addSubview:label];
        [cell addSubview:label2];
        [cell addSubview:label3];
        
        float height = cell.bounds.size.height * .5;
        
        //label.center = CGPointMake(cell.bounds.size.width * .6, height);
        //label2.center = CGPointMake(cell.bounds.size.width, height);
        //label3.center = CGPointMake(cell.bounds.size.width, height);

        //cell.center = tableView.center
        
    }

    // Configure the cell...
    
    return cell;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
