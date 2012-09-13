//
//  SFObjsViewController.m
//  Noteprise
//
//  Created by Ritika on 20/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SFObjsViewController.h"
#import "Utility.h"
@interface SFObjsViewController ()

@end

@implementation SFObjsViewController
@synthesize sfObjsList,delegate;
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
    self.title = @"Choose Object";
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Select_note_bcg.png"]];
    [tempImageView setFrame:self.tableView.frame]; 
    
    self.tableView.backgroundView = tempImageView;
    [tempImageView release];
    UILabel *bigLabel = [[UILabel alloc] init];
    bigLabel.text = self.title;
    [bigLabel setBackgroundColor:[UIColor clearColor]];
    [bigLabel setTextColor:[UIColor whiteColor]];
    [UIFont fontWithName:@"Verdana" size:16];
    bigLabel.font = [UIFont boldSystemFontOfSize: 16.0];
    [bigLabel sizeToFit];
    self.navigationItem.titleView = bigLabel;
    [bigLabel release];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [sfObjsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
    //}
    // Configure the cell...
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = [sfObjsList objectAtIndex:indexPath.row];
    //cell.textLabel.text = [[sfObjsList objectAtIndex:indexPath.row]valueForKey:OBJ_NAME];
    NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sfobjToMapWith = [stdDefaults valueForKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY];
    if(sfobjToMapWith != nil) {
        if([[sfObjsList objectAtIndex:indexPath.row] isEqualToString:sfobjToMapWith])
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRowIndex = indexPath.row;
    //[tableView reloadData];
    NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentsfObj = [stdDefaults valueForKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY];
    
    if (currentsfObj != nil) {
        NSInteger index;
        for(int i=0 ;i<[sfObjsList count];i++){
            if ([[sfObjsList objectAtIndex:i] isEqualToString:currentsfObj]) {
                index = i;
                break;
            }
        }
		NSIndexPath *selectionIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
        UITableViewCell *checkedCell = [tableView cellForRowAtIndexPath:selectionIndexPath];
        checkedCell.accessoryType = UITableViewCellAccessoryNone;
    }
    DebugLog(@"old to set as obj:%@ ",[Utility valueInPrefForKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY]);
    [stdDefaults setObject:[Utility valueInPrefForKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY] forKey:OLD_SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY];
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark]; 
    [stdDefaults setObject:[sfObjsList objectAtIndex:indexPath.row] forKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY];
    [stdDefaults synchronize];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [delegate dismissPopover];
    
}
-(void)viewDidAppear:(BOOL)animated {
    DebugLog(@"Object view appear");
    DebugLog(@"old obj:%@ ",[Utility valueInPrefForKey:OLD_SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY]);
    if(([Utility valueInPrefForKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY] == nil ) && [Utility valueInPrefForKey:OLD_SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY] != nil) {
        [Utility setValueInPref:[Utility valueInPrefForKey:OLD_SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY] forKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY];
    }
}
@end
