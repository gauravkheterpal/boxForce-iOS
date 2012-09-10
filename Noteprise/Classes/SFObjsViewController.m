//
//  SFObjsViewController.m
//  Noteprise
//
//  Created by Ritika on 20/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SFObjsViewController.h"
#import "Utility.h"
#import "FieldsViewController.h"
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
    //[stdDefaults setObject:[Utility valueInPrefForKey:SFOBJ_FIELD_TO_MAP_KEY] forKey:OLD_SFOBJ_FIELD_TO_MAP_KEY];
    // Set the checkmark accessory for the selected row.
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark]; 
    //NSDictionary *dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[[sfObjsList objectAtIndex:indexPath.row]valueForKey:OBJ_NAME],OBJ_NAME,[[sfObjsList objectAtIndex:indexPath.row]valueForKey:OBJ_LABEL],OBJ_LABEL, nil];
    [stdDefaults setObject:[sfObjsList objectAtIndex:indexPath.row] forKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY];
    //[stdDefaults removeObjectForKey:SFOBJ_FIELD_TO_MAP_KEY];
    [stdDefaults synchronize];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [delegate dismissPopover];
    //[dict release];
    //[self listMetadataForObj];
}
-(void)viewDidAppear:(BOOL)animated {
    DebugLog(@"Object view appear");
    DebugLog(@"old obj:%@ ",[Utility valueInPrefForKey:OLD_SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY]);
    if(([Utility valueInPrefForKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY] == nil ) && [Utility valueInPrefForKey:OLD_SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY] != nil) {
        [Utility setValueInPref:[Utility valueInPrefForKey:OLD_SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY] forKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY];
        //[Utility setValueInPref:[Utility valueInPrefForKey:OLD_SFOBJ_FIELD_TO_MAP_KEY] forKey:SFOBJ_FIELD_TO_MAP_KEY];
    }
}
-(void)listMetadataForObj{
    if([Utility checkNetwork]){
        [Utility showCoverScreen];
        NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
        NSString *sfObjtoMap = [[stdDefaults valueForKey:SFOBJ_TO_MAP_KEY]valueForKey:OBJ_NAME];
        /*if (sfObjtoMap == nil) {
            sfObjtoMap = @"Account";
        }*/
        if(sfObjtoMap) {
            SFRestRequest * request =  [[SFRestAPI sharedInstance] requestForDescribeWithObjectType:sfObjtoMap];
            [[SFRestAPI sharedInstance] send:request delegate:self];
        }
    } else {
        [Utility showAlert:NETWORK_UNAVAILABLE_MSG];
    }
}

#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    [Utility hideCoverScreen];
    DebugLog(@"request:%@",[request description]);
    DebugLog(@"jsonResponse:%@",jsonResponse);
    if ([[request path] rangeOfString:@"describe"].location != NSNotFound) {
        //retrive all fields
        if([[jsonResponse objectForKey:@"errors"] count]==0){
            NSArray *fields = [jsonResponse objectForKey:@"fields"];
            NSMutableArray *fieldsRows = [[NSMutableArray alloc]init];
            DebugLog(@"request:didLoadResponse: #fields: %d records %@ req %@ rsp %@", fields.count,fields,request,jsonResponse);
            for (NSDictionary *field in fields) {
                if([[field valueForKey:@"type"]isEqualToString:@"string"]||[[field valueForKey:@"type"]isEqualToString:@"textarea"]){
                    if ([[field valueForKey:@"updateable"] boolValue] == true) {
                         [fieldsRows addObject:field];
                    }

                }
            }
            
            FieldsViewController *fieldsVCntrl = [[FieldsViewController alloc]init];
            fieldsVCntrl.delegate = self.delegate;
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:FIELD_LABEL ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
            fieldsRows = [[fieldsRows sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]mutableCopy];
            fieldsVCntrl.objFields = fieldsRows;
            [self.navigationController pushViewController:fieldsVCntrl animated:YES];
            [fieldsRows release];
            //self.dataRows = records;
            //[self.tableView reloadData];
        }
        else{
            [Utility showAlert:ERROR_LISTING_SFOBJECT_METADATA_MSG];
            [Utility hideCoverScreen];
        }
    } else{
        [Utility showAlert:ERROR_LISTING_SFOBJECT_METADATA_MSG];
        [Utility hideCoverScreen];
    }
}


- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    DebugLog(@"request:didFailLoadWithError: %@", error);
    [Utility hideCoverScreen];
    //add your failed error handling here
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:ALERT_NEUTRAL_BUTTON_TEXT otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
    DebugLog(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
    [Utility hideCoverScreen];
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    DebugLog(@"requestDidTimeout: %@", request);
    //add your failed error handling here
    [Utility hideCoverScreen];
}
@end
