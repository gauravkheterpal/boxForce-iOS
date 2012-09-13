//
//  BoxListViewController.m
//  client
//
//  Evernote API sample code is provided under the terms specified in the file LICENSE.txt which was included with this distribution.
//

#import "BoxListViewController.h"
#import "RootViewController.h"
#import "SettingsViewController.h"
#import "SignInViewController.h"
#import "BoxListViewController.h"
#import "BoxFolderXMLBuilder.h"
#import "BoxLoginViewController.h"
#import "BoxFileViewController.h"
#import "Utility.h"
@implementation BoxListViewController
@synthesize fileObjArray;

 

//viewDidLoad method declared in RootViewController.m
- (void)viewDidLoad {
    [super viewDidLoad];
    fileObjArray = [[NSMutableArray alloc] init];
    //self.title = @"Noteprise";
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Top_nav_768x44.png"] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:45/255.0 green:127/255.0 blue:173/255.0 alpha:1];
    }
    
    //toolbar.backgroundColor = [UIColor clearColor];
    UIImage *buttonImage = [UIImage imageNamed:@"Logout.png"];
    UIImage *buttonSelectedImage = [UIImage imageNamed:@"Logout_down.png"];
    
    //create the button and assign the image
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button setImage:buttonSelectedImage forState:UIControlStateSelected];
    [button addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    //sets the frame of the button to the size of the image
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    //creates a UIBarButtonItem with the button as a custom view
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.leftBarButtonItem = customBarItem;
    UIImageView * logo = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 187.0f, 31.0f)];
    logo.image = [UIImage imageNamed:@"noteprise_logo.png"];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
       logo.image = [UIImage imageNamed:@"Noteprise_icon_iPhone.png"];
    logo.center = [self.navigationController.navigationBar center];
    self.navigationItem.titleView = logo;
    notesTbl.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Background_pattern_tableview.png"]];
    
    [BoxCommonUISetup formatNavigationBarWithBoxIconAndColorScheme:self.navigationController andNavItem:self.navigationItem];
    [NSThread detachNewThreadSelector:@selector(getFoldersAsync:) toTarget:self withObject:nil];

}
#pragma mark Folder Methods

-(void)folderRetrievalCallback:(BoxFolder*)folderModel {
	if(!folderModel) {
		[BoxCommonUISetup popupAlertWithTitle:@"Error" andText:@"Could not access your box account at this time. Please check your internet connection and try again" andDelegate:nil];
		[self.navigationController popViewControllerAnimated:YES];
	}
    _folderModel = [folderModel retain];
    DebugLog(@"_folderModel:%d", [[_folderModel objectsInFolder]count]);
    
    for (int i =0; i< [[_folderModel objectsInFolder] count]; i++) {
        BoxObject * curModel = (BoxObject*)[[_folderModel objectsInFolder] objectAtIndex:i];
        if(![curModel isKindOfClass:[BoxFolder class]]) {
            [fileObjArray addObject:[[_folderModel objectsInFolder] objectAtIndex:i]];
            DebugLog(@"name of object = %@ , id of object is = %@ array count = %d", curModel.objectName,curModel.objectId,[fileObjArray count] );
        }
        
    }
    DebugLog(@"array count = %d ,Array = %@",[fileObjArray count], fileObjArray);
    
    //listOfItems = [[_folderModel objectsInFolder]retain];
    [notesTbl setDelegate:self];
    [notesTbl setDataSource:self];
	[notesTbl  reloadData];
    [Utility hideCoverScreen];
	[_activityIndicator stopAnimating];
}

-(void)getFoldersAsync:(id)object {
    [Utility showCoverScreen];
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	BoxUser * userModel = [BoxUser savedUser];
	
	NSString * ticket = userModel.authToken;
	// Step 2a
	NSNumber * folderIdToDownload = [NSNumber numberWithInt:0];//0];folderForId
	// Step 2b
	BoxFolderDownloadResponseType responseType = 0;
	BoxFolder * folderModel = [BoxFolderXMLBuilder folderForId:@"0" token:ticket responsePointer:&responseType basePathOrNil:nil];
    
	
	// Step 2c
	if(responseType == boxFolderDownloadResponseTypeFolderSuccessfullyRetrieved) {
		//Step 2d
		NSLog(@"folderModel = %@", [folderModel objectToString]);
        DebugLog(@"Dictionary = %@",[folderModel objectDescription]);
	}
	
	[self performSelectorOnMainThread:@selector(folderRetrievalCallback:) withObject:folderModel waitUntilDone:YES];
	
	[pool release];
}
-(void)changeSegmentControlBtnsWithOrientationAndDevice {
    NSString *device,*orientation;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        device = @"iPhone";
        if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) 
            orientation = @"landscape";
        else 
            orientation = @"potrait";
    } else {
        device = @"iPad";
        if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
            orientation = @"landscape";
        else 
            orientation = @"potrait"; 
    }
    //Customize segement control buttons
    if([searchOptionsChoiceCntrl selectedSegmentIndex] == 0)
        [searchOptionsChoiceCntrl setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Segment_control_button_all_pressed_%@_%@.png",device,orientation]] forSegmentAtIndex:0];
    else
        [searchOptionsChoiceCntrl setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Segment_control_button_all_unpressed_%@_%@.png",device,orientation]] forSegmentAtIndex:0];
    if([searchOptionsChoiceCntrl selectedSegmentIndex] == 1)
        [searchOptionsChoiceCntrl setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Segment_control_button_notebook_pressed_%@_%@.png",device,orientation]] forSegmentAtIndex:1];
    else [searchOptionsChoiceCntrl setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Segment_control_button_notebook_unpressed_%@_%@.png",device,orientation]] forSegmentAtIndex:1];
    if([searchOptionsChoiceCntrl selectedSegmentIndex] == 2)
        [searchOptionsChoiceCntrl setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Segment_control_button_tag_pressed_%@_%@.png",device,orientation]] forSegmentAtIndex:2];
    else
        [searchOptionsChoiceCntrl setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Segment_control_button_tag_unpressed_%@_%@.png",device,orientation]] forSegmentAtIndex:2];
    if([searchOptionsChoiceCntrl selectedSegmentIndex] == 3)
        [searchOptionsChoiceCntrl setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Segment_control_button_keyword_pressed_%@_%@.png",device,orientation]] forSegmentAtIndex:3];
    else 
        [searchOptionsChoiceCntrl setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Segment_control_button_keyword_unpressed_%@_%@.png",device,orientation]] forSegmentAtIndex:3];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}
/*-(void)changeBkgrndImgWithOrientation {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
            backgroundImgView.image = [UIImage imageNamed:@"bgE-480x287.png"];
        else {
            backgroundImgView.image = [UIImage imageNamed:@"bgE-320x480.png"];
        }
    } else {
        if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
            backgroundImgView.image = [UIImage imageNamed:@"bgE-1024x572.png"];
        else {
            backgroundImgView.image = [UIImage imageNamed:@"bgE-768x1024.png"];
        }
    }
}*/
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
     //[self changeSegmentControlBtnsWithOrientationAndDevice];
}
-(IBAction)showSettings:(id)sender{
    SettingsViewController *settingsView = [[SettingsViewController alloc]initWithStyle:UITableViewStyleGrouped];
    settingsView.popover_delegate = self;
    UINavigationController *settingsNavCntrl = [[UINavigationController alloc] initWithRootViewController:settingsView];
	settingsNavCntrl.navigationBar.barStyle = UIBarStyleBlackOpaque;
    if ([settingsNavCntrl.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        [settingsNavCntrl.navigationBar setBackgroundImage:[UIImage imageNamed:@"blue_bcg_iPhone.png"] forBarMetrics:UIBarMetricsDefault];
       settingsNavCntrl.navigationBar.tintColor = [UIColor colorWithRed:45/255.0 green:127/255.0 blue:173/255.0 alpha:1];
    }
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		//sendSubView.view.frame=CGRectMake(0, 0, 300, 400);
		[self dismissPopover];
		UIPopoverController *popoverSettings = [[UIPopoverController alloc] initWithContentViewController:settingsNavCntrl]; 
		//popoverSend.delegate = self;
		settingsView.contentSizeForViewInPopover =CGSizeMake(320, 400);
		popoverController = popoverSettings;
		[popoverSettings presentPopoverFromBarButtonItem:settingsBtn 
                                permittedArrowDirections:UIPopoverArrowDirectionAny 
                                                animated:YES];
        //[popoverSettings release];
        
	} else {
		UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered
																		target:self action:@selector(dismissModalView)];      
		settingsView.navigationItem.leftBarButtonItem = cancelButton;
		[self.navigationController presentModalViewController:settingsNavCntrl animated:YES];
        [cancelButton release];
	}
    
    
}
-(void)logout
{
    [BoxLoginViewController logoutCurrentUser];
    //[[EvernoteSession sharedSession] logout];
    SignInViewController *loginView = [[SignInViewController alloc]init];
    [[[UIApplication sharedApplication]delegate]window].rootViewController = loginView;
    [loginView release];
}

-(void)showLoadingLblWithText:(NSString*)Loadingtext{
    dialog_imgView.hidden = NO;
    loadingLbl.text = Loadingtext;
    loadingLbl.hidden = NO;
}
-(void)hideDoneToastMsg:(id)sender{
	dialog_imgView.hidden = YES;
    loadingLbl.hidden = YES;
}
-(void)reloadNotesTable {
    [Utility hideCoverScreen];
    [searchBar resignFirstResponder];
    notesTbl.delegate =self;
    notesTbl.dataSource =self;
    [self hideDoneToastMsg:nil];
    loadingLbl.hidden = YES;
    [notesTbl reloadData];
}
-(void)dismissModalView {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}
-(void)dismissPopover {
    if(popoverController!=nil)
        [popoverController dismissPopoverAnimated:YES];
}

#pragma mark -
#pragma mark UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedRowIndex = indexPath.row;
    //BoxObject * curModel = (BoxObject*)[_folderModel.objectsInFolder objectAtIndex:[indexPath row]];
    BoxObject * curModel = (BoxObject*)[fileObjArray objectAtIndex:[indexPath row]];
    if([curModel isKindOfClass:[BoxFolder class]]) {
        [Utility showAlert:@"It is folder.Please select a file"];
        return;
    }
    BoxFileViewController* boxFileViewController = [[BoxFileViewController alloc] init];
    boxFileViewController.title = curModel.objectName;
    [boxFileViewController setGuid:curModel.objectId];
    [self.navigationController pushViewController:boxFileViewController animated:YES];
}


/*- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}*/



/************************************************************
 *
 *  Functions configuring the listView
 *
 ************************************************************/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [fileObjArray count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier]autorelease];
    }

    BoxObject * curModel = (BoxObject*)[fileObjArray objectAtIndex:[indexPath row]];
    cell.textLabel.text = curModel.objectName;
    cell.textLabel.font = [UIFont fontWithName:@"Verdana" size:13];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.text = [Utility humanFriendlyFileSize:[curModel.objectSize longValue]];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Verdana" size:11];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    UIImageView *accIMGView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    accIMGView.image =[UIImage imageNamed:@"Blue_arrow_30x30.png"];
    cell.accessoryView = accIMGView;
    cell.accessoryView.backgroundColor  =[UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}
#pragma mark -
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
-(void)viewDidUnload {
    [super viewDidUnload];
}
//dealloc method declared in NoteListViewController.m
- (void)dealloc {
    
    [listOfItems release];
    [super dealloc];
}

@end
