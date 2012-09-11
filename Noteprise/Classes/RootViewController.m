/*
 Copyright (c) 2011, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "RootViewController.h"

#import "SBJson.h"
#import "SFRestAPI.h"
#import "SFRestRequest.h"
#import "NSData+Base64.h"
#import "Utility.h"
#import "CustomBlueToolbar.h"
NSString * parrentTaskID ;
NSString * accountID ;
int selectedRecordId;
NSString* selectedObj,*selectedObjID;
@implementation RootViewController
@synthesize attachmentData;
@synthesize dataRows,fieldsRows;
@synthesize fileName;
@synthesize noteContent,inEditMode,selectedImage,unselectedImage;
#pragma mark Misc


- (void)dealloc
{
    [attachmentData release];
    self.dataRows = nil;
    [super dealloc];
}


#pragma mark - View lifecycle

-(void)initializeSelectedRow {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[dataRows count]];
    for (int i=0; i < [dataRows count]; i++)
        [array addObject:[NSNumber numberWithBool:NO]];
    selectedRow = array;
}
- (void)viewDidLoad
{
    tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Background_pattern_tableview.png"]];
    //backgroundImgView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    //backgroundImgView.contentMode = UIViewContentModeScaleAspectFill;
    //[self changeBkgrndImgWithOrientation];
    self.fieldsRows = [[NSMutableArray alloc]init];
    [self fetchSelectedObjList];
    //selectedRow = [[NSMutableArray alloc]init];
    self.inEditMode = NO;
	self.selectedImage = [UIImage imageNamed:@"Checkbox_checked.png"];
	self.unselectedImage = [UIImage imageNamed:@"Checkbox.png"];
    
    DebugLog(@"subview:%@",[self.view subviews]);
    
}
-(void)viewDidAppear:(BOOL)animated{
    selectedRecordId = -999;
    // create a toolbar where we can place some buttons
    [self initToolbarButtons];
    
}
-(void)initToolbarButtons {
    CustomBlueToolbar* toolbar = [[CustomBlueToolbar alloc]
                          initWithFrame:CGRectMake(0, 0, 125, 44)];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight))
            toolbar.frame = CGRectMake(0, 0, 125, 32);
    //[toolbar setBarStyle: UIBarStyleBlackOpaque];
    
    // create an array for the buttons
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
    // create a spacer between the buttons
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                               target:nil
                               action:nil];
    [buttons addObject:spacer];
    [spacer release];
    if(!self.inEditMode)
    {
        UIImage* editBtnImg = [UIImage imageNamed:@"Edit.png"];
        UIImage* editBtnDownImg = [UIImage imageNamed:@"Edit_down.png"];
        UIButton *editButton = [[UIButton alloc] initWithFrame:BAR_BUTTON_FRAME];
        [editButton setBackgroundImage:editBtnImg forState:UIControlStateNormal];
        [editButton setBackgroundImage:editBtnDownImg forState:UIControlStateHighlighted];
        [editButton addTarget:self action:@selector(toggleEditMode) forControlEvents:UIControlEventTouchUpInside];
        [editButton setShowsTouchWhenHighlighted:YES];
        UIBarButtonItem *editBarButton =[[UIBarButtonItem alloc] initWithCustomView:editButton];
        [buttons addObject:editBarButton];
        [editButton release];
    }
    else {
        UIImage* cancelBtnImg = [UIImage imageNamed:@"Cancel.png"];
        UIImage* cancelBtnDownImg = [UIImage imageNamed:@"Cancel_down.png"];
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:BAR_BUTTON_FRAME];
        [cancelButton setBackgroundImage:cancelBtnImg forState:UIControlStateNormal];
        [cancelButton setBackgroundImage:cancelBtnDownImg forState:UIControlStateHighlighted];
        [cancelButton addTarget:self action:@selector(toggleEditMode) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setShowsTouchWhenHighlighted:YES];
        UIBarButtonItem *cancelBarButton =[[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        [buttons addObject:cancelBarButton];
        [cancelButton release];
    }
    
    
    UIImage* saveBtnImage = [UIImage imageNamed:@"Save.png"];
    UIImage* saveBtnDoneImage = [UIImage imageNamed:@"Save_down.png"];
    UIButton *saveButton = [[UIButton alloc] initWithFrame:BAR_BUTTON_FRAME];
    [saveButton setBackgroundImage:saveBtnImage forState:UIControlStateNormal];
    [saveButton setBackgroundImage:saveBtnDoneImage forState:UIControlStateSelected];
    [saveButton addTarget:self action:@selector(addSelectedEvernoteToSF) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *saveBarButton =[[UIBarButtonItem alloc] initWithCustomView:saveButton];
    
    [buttons addObject:saveBarButton];
    [saveButton release];
        
    [toolbar setItems:buttons];
    // place the toolbar into the navigation bar
    self.navigationItem.rightBarButtonItem =  [[[UIBarButtonItem alloc]
                                                initWithCustomView:toolbar] autorelease];
    [toolbar release];
    
}

-(IBAction)toggleEditMode{
	DebugLog(@"toggleEditMode");
	self.inEditMode = !self.inEditMode;
    self.navigationItem.rightBarButtonItem = nil;
    [self initToolbarButtons];
    if(!self.inEditMode)
        [self initializeSelectedRow];
    
	[tableView reloadData];
}

-(void)changeBkgrndImgWithOrientation {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
            backgroundImgView.image = [UIImage imageNamed:@"bgE-480x287.png"];
        else {
            backgroundImgView.image = [UIImage imageNamed:@"bgE-320x480.png"];
        }
    } else {
        if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
            backgroundImgView.image = [UIImage imageNamed:@"bgE-1024x704.png"];
        else {
            backgroundImgView.image = [UIImage imageNamed:@"bgE-768x1024.png"];
        }
    }
}
-(void)showLoadingLblWithText:(NSString*)Loadingtext{
    [loadingSpinner startAnimating];
    dialog_imgView.hidden = NO;
    loadingLbl.text = Loadingtext;
    loadingLbl.hidden = NO;
}

-(void)fetchSelectedObjList {
    if([Utility checkNetwork]) {
        [Utility showCoverScreen];
        DebugLog(@"old obj:%@ sf obje:%@",[Utility valueInPrefForKey:OLD_SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY],[Utility valueInPrefForKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY]);
        if(([Utility valueInPrefForKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY] == nil)&& ([Utility valueInPrefForKey:OLD_SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY] == nil)) {
            //set previous selected mapping
            [Utility showAlert:SF_OBJECT_FIELD_MISSING_MSG];
            return;
        }
        else if(([Utility valueInPrefForKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY] == nil ) && [Utility valueInPrefForKey:OLD_SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY] !=nil) {
            //set previous selected mapping
            [Utility setValueInPref:[Utility valueInPrefForKey:OLD_SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY] forKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY];
            //[Utility setValueInPref:[Utility valueInPrefForKey:OLD_SFOBJ_FIELD_TO_MAP_KEY] forKey:SFOBJ_FIELD_TO_MAP_KEY];
        }
        //NSString *selectedSFObj;
        NSUserDefaults* stdDefaults = [NSUserDefaults standardUserDefaults];
        
        
        NSString *selectedSFObj = [stdDefaults valueForKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY];
        if(selectedSFObj) {
            //selectedSFObj = [sfObj valueForKey:OBJ_NAME];
            NSMutableString *queryString;
            
            if ([selectedSFObj isEqualToString:@"Task"]) {
                queryString = [NSMutableString stringWithFormat:@"SELECT Id,Subject from %@",selectedSFObj];
            }
            else if ([selectedSFObj isEqualToString:@"Case"]) {
                queryString = [NSMutableString stringWithFormat:@"SELECT Id,CaseNumber from %@",selectedSFObj];
            }
            else if ([selectedSFObj isEqualToString:@"CaseComment"]) {
                queryString = [NSMutableString stringWithFormat:@"SELECT Id,ParentId from %@",selectedSFObj];
            }
            else if ([selectedSFObj isEqualToString:@"ContentVersion"]) {
                queryString = [NSMutableString stringWithFormat:@"SELECT Id,ContentDocumentId from %@",selectedSFObj];
            }
            else if ([selectedSFObj isEqualToString:@"Contract"]) {
                queryString = [NSMutableString stringWithFormat:@"SELECT Id,ContractNumber from %@",selectedSFObj];
            }
            else if ([selectedSFObj isEqualToString:@"Event"]) {
                queryString = [NSMutableString stringWithFormat:@"SELECT Id,Subject from %@",selectedSFObj];
            }
            else if ([selectedSFObj isEqualToString:@"Idea"]) {
                queryString = [NSMutableString stringWithFormat:@"SELECT Id,Title from %@",selectedSFObj];
            }
            else if ([selectedSFObj isEqualToString:@"Note"]) {
                queryString = [NSMutableString stringWithFormat:@"SELECT Id,Title from %@",selectedSFObj];
            }
            else if ([selectedSFObj isEqualToString:@"Solution"]) {
                queryString = [NSMutableString stringWithFormat:@"SELECT Id,SolutionName from %@",selectedSFObj];
            }
            else if ([selectedSFObj isEqualToString:@"FeedItem"]||[selectedSFObj isEqualToString:@"FeedComment"]) {
                queryString = [NSMutableString stringWithFormat:@"SELECT Id from %@",selectedSFObj];//CreatedById
            }
            else
            {
                queryString = [NSMutableString stringWithFormat:@"SELECT Name,Id from %@",selectedSFObj];
            }
            
            
            [self showLoadingLblWithText:progress_dialog_salesforce_getting_record_list_message];
            SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:queryString];    
            [[SFRestAPI sharedInstance] send:request delegate:self];
            self.title = [NSString stringWithFormat:@"%@",selectedSFObj];
        }
    } else {
        [Utility showAlert:NETWORK_UNAVAILABLE_MSG];
    }
}

-(void)addSelectedEvernoteToSF{
    //[Utility showCoverScreen];
    if([Utility checkNetwork]) {
        [self addAttachmentForFileName:self.fileName];
        /*NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *sfobjField =  [stdDefaults valueForKey:SFOBJ_FIELD_TO_MAP_KEY];
        if([self.noteContent length] <= [[sfobjField objectForKey:FIELD_LIMIT]intValue])*/
            //[self createSFRequestToSaveSelectedNoteWithContent:self.noteContent];
        /*else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Noteprise" message:SF_FIELDS_LIMIT_CROSSED_ALERT_MSG delegate:self cancelButtonTitle:ALERT_NEGATIVE_BUTTON_TEXT otherButtonTitles:ALERT_POSITIVE_BUTTON_TEXT, nil];
            alert.tag = SAVE_TO_SFOBJ_LIMIT_ALERT_TAG;
            [alert show];
            [alert release];
        }*/
    } else {
            [Utility showAlert:NETWORK_UNAVAILABLE_MSG];
    }
    
}
-(void)addAttachmentForFileName:(NSString*)fName{
    if(([Utility valueInPrefForKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY] == nil) && [Utility valueInPrefForKey:OLD_SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY] !=nil ) {
        [Utility setValueInPref:[Utility valueInPrefForKey:OLD_SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY] forKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY];
        //[Utility setValueInPref:[Utility valueInPrefForKey:OLD_SFOBJ_FIELD_TO_MAP_KEY] forKey:SFOBJ_FIELD_TO_MAP_KEY];
    }
    NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sfobj =  [stdDefaults valueForKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY];
    if(sfobj){
        
        
        selectedCount = 0;
       
        if(self.inEditMode){
            for(int i = 0;i < [selectedRow count] ; i++) {
                if ([[selectedRow objectAtIndex:i] boolValue] == YES) {
                    [self showLoadingLblWithText:progress_dialog_salesforce_record_updating_message];
                    NSString *filePath = [[Utility applicationDocumentsDirectory] stringByAppendingPathComponent:fName];
                    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
                    NSString * base64Str =  [fileData  base64EncodedString];
                    NSMutableDictionary * fields =[[NSMutableDictionary alloc] init];
                    [fields setValue:[[self.dataRows objectAtIndex:i] valueForKey:@"Id"] forKey:@"ParentId"];
                    [fields setValue:fName forKey:@"Name"];
                    [fields setValue:base64Str forKey:@"Body"];
                
                    SFRestRequest * request =  [[SFRestAPI sharedInstance] requestForCreateWithObjectType:@"Attachment" fields:fields];
                    [[SFRestAPI sharedInstance] send:request delegate:self];
                }
            }
        }
            else
            {
                if(selectedRecordId == -999) {   
                    [Utility hideCoverScreen];
                    [Utility showAlert:[NSString stringWithFormat:@"Please select %@ to map with",sfobj]];
                } else {
                    [self showLoadingLblWithText:progress_dialog_salesforce_record_updating_message];
                    NSString *filePath = [[Utility applicationDocumentsDirectory] stringByAppendingPathComponent:fName];
                    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
                    NSString * base64Str =  [fileData  base64EncodedString];
                    NSMutableDictionary * fields =[[NSMutableDictionary alloc] init];
                    [fields setValue:[[self.dataRows objectAtIndex:selectedRecordId] valueForKey:@"Id"] forKey:@"ParentId"];
                    [fields setValue:fName forKey:@"Name"];
                    [fields setValue:base64Str forKey:@"Body"];
                    
                    SFRestRequest * request =  [[SFRestAPI sharedInstance] requestForCreateWithObjectType:@"Attachment" fields:fields];
                    [[SFRestAPI sharedInstance] send:request delegate:self];
                }
        
        }
      
    } else {
        [Utility hideCoverScreen];
        [Utility showAlert:SF_OBJECT_MISSING_MSG];
    }
    
}
-(void)createSFRequestToSaveSelectedNoteWithContent:(NSString*)evernoteContent {
    
    if(([Utility valueInPrefForKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY] == nil) && [Utility valueInPrefForKey:OLD_SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY] !=nil ) {
        [Utility setValueInPref:[Utility valueInPrefForKey:OLD_SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY] forKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY];
        //[Utility setValueInPref:[Utility valueInPrefForKey:OLD_SFOBJ_FIELD_TO_MAP_KEY] forKey:SFOBJ_FIELD_TO_MAP_KEY];
    }
    NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sfobj =  [stdDefaults valueForKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY];
    //NSDictionary *sfobjField =  [stdDefaults valueForKey:SFOBJ_FIELD_TO_MAP_KEY];
    DebugLog(@"sfobj:%@ ",sfobj);
    if(sfobj){
        NSMutableDictionary * fields =[[NSMutableDictionary alloc] init];
        //[fields setValue:evernoteContent forKey:[sfobjField valueForKey:FIELD_NAME]];
        selectedCount = 0;
        if(self.inEditMode){
            for(int i = 0;i < [selectedRow count] ; i++) {
                if ([[selectedRow objectAtIndex:i] boolValue] == YES) {
                    [self showLoadingLblWithText:progress_dialog_salesforce_record_updating_message];
                    SFRestRequest * request =  [[SFRestAPI sharedInstance] requestForUpdateWithObjectType:[sfobj valueForKey:OBJ_NAME] objectId:[[self.dataRows objectAtIndex:i] valueForKey:@"Id"] fields:fields];
                    [[SFRestAPI sharedInstance] send:request delegate:self];
                    selectedCount ++;
                }
            }
            
        }
        else {
            
            //----------------------------------------------------------------------------------------------------
            selectedCount = 0;
            if(selectedRecordId == -999) {   
                [Utility hideCoverScreen];
                [Utility showAlert:[NSString stringWithFormat:@"Please select %@ to map with",[sfobj valueForKey:OBJ_NAME]]];
            } else {
                [self showLoadingLblWithText:progress_dialog_salesforce_record_updating_message];
                SFRestRequest * request =    [[SFRestAPI sharedInstance] requestForUpdateWithObjectType:[sfobj valueForKey:OBJ_NAME] objectId:[[self.dataRows objectAtIndex:selectedRecordId] valueForKey:@"Id"] fields:fields];
                [[SFRestAPI sharedInstance] send:request delegate:self];
                selectedCount ++;
            }
            
        }
    } else {
        [Utility hideCoverScreen];
        [Utility showAlert:SF_OBJECT_FIELD_MISSING_MSG];
    }

}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == SAVE_TO_SFOBJ_LIMIT_ALERT_TAG && alertView.cancelButtonIndex == buttonIndex) {
    } else if (alertView.tag == SAVE_TO_SFOBJ_LIMIT_ALERT_TAG) {
        [Utility showCoverScreen];
        [self showLoadingLblWithText:progress_dialog_salesforce_record_updating_message];
        //truncationg note text to 1000 character for posting to Chatter
        DebugLog(@"old length:%d", [self.noteContent length]);
        NSUserDefaults *stdDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *sfobjField =  [stdDefaults valueForKey:SFOBJ_FIELD_TO_MAP_KEY];
        int field_limit = [[sfobjField objectForKey:FIELD_LIMIT]intValue];
        NSString *truncateNoteContent = [[self.noteContent substringToIndex:field_limit-1]mutableCopy];
        DebugLog(@"new length:%d", [truncateNoteContent length]);
        [self createSFRequestToSaveSelectedNoteWithContent:truncateNoteContent];
    }
}
#pragma mark -
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
    //[self changeBkgrndImgWithOrientation];
    [self initToolbarButtons];
}
-(void)hideToastMsg:(id)sender{
	dialog_imgView.hidden = YES;
    loadingLbl.hidden = YES;
    [loadingSpinner stopAnimating];
}
-(void)hideDoneToastMsg:(id)sender{
	dialog_imgView.hidden = YES;
    loadingLbl.hidden = YES;
    doneImgView.hidden = YES;
    [loadingSpinner stopAnimating];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark - SFRestAPIDelegate
- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    //DebugLog(@"request:%@",[request description]);
        //DebugLog(@"jsonResponse:%@",jsonResponse);
    
    if([[request description] rangeOfString:@"SELECT"].location != NSNotFound){
        
        if([[jsonResponse objectForKey:@"errors"] count]==0){
            [Utility hideCoverScreen];
            dialog_imgView.hidden = YES;
            loadingLbl.hidden = YES;
            doneImgView.hidden = YES;
            [loadingSpinner stopAnimating];
            NSArray *records = [jsonResponse objectForKey:@"records"];
            DebugLog(@"request:didLoadResponse: #records: %d records %@ req %@ rsp %@", records.count,records,request,jsonResponse);
            
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"Name"  ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
            self.dataRows = [records sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
            [self initializeSelectedRow];
            if([self.dataRows count] == 0) {
                [Utility showAlert:[NSString stringWithFormat:@"%@%@",NO_RECORD_IN_SF_OBJ_MSG,self.title]];
            }
            [tableView reloadData];
        }
        else{
            [Utility showAlert:ERROR_LISTING_SF_OBJECT_MSG];
            [Utility hideCoverScreen];
        }
        

    }
    else{
        selectedCount --;
        if([[jsonResponse objectForKey:@"errors"] count]==0){
            //if(selectedCount == 0 ) {
                [loadingSpinner stopAnimating];
                doneImgView.hidden = NO;
                [self showLoadingLblWithText:progress_dialog_salesforce_record_updated_success_message];
                [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(hideDoneToastMsg:) userInfo:nil repeats:NO];
            //}
            [loadingSpinner stopAnimating];
        }
        else{
            [loadingSpinner stopAnimating];
            [self showLoadingLblWithText:salesforce_record_saving_failed_message];
            [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideToastMsg:) userInfo:nil repeats:NO];
        }
        [Utility hideCoverScreen];
    }
}


- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    DebugLog(@"request:didFailLoadWithError: %@ code:%d", error,error.code);
    [Utility hideCoverScreen];
    [self hideToastMsg:nil];
    //add your failed error handling here
    NSString *alertMessaage ;
    if([[error.userInfo valueForKey:@"errorCode"] isEqualToString:@"STRING_TOO_LONG"]) {
        alertMessaage = SF_FIELDS_LIMIT_CROSSED_ERROR_MSG;
    }
    else {
        alertMessaage = [error.userInfo valueForKey:NSLocalizedDescriptionKey];
    }
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:ALERT_NEUTRAL_BUTTON_TEXT otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
    DebugLog(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
    [Utility hideCoverScreen];
    [self hideToastMsg:nil];
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    DebugLog(@"requestDidTimeout: %@", request);
    //add your failed error handling here
    [Utility hideCoverScreen];
    [self hideToastMsg:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  //  DebugLog(@"class %@ dataRows %@",[self.dataRows class],self.dataRows);
    return [self.dataRows count];
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   static NSString *CellIdentifier = @"CellIdentifier";

   // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];

    }
	//if you want to add an image to your cell, here's how
	UIImage *image = [UIImage imageNamed:@"Record.png"];
    if(self.inEditMode) {
        NSNumber *selectedForDelete = [selectedRow objectAtIndex:indexPath.row];
        if([selectedForDelete boolValue]) 
            cell.imageView.image = self.selectedImage;
        else {
            cell.imageView.image = self.unselectedImage;
        }
        //cell.imageView.image = ([selectedForDelete boolValue]) ? self.selectedImage : self.unselectedImage;
    }
    else 
        cell.imageView.image = image;

	// Configure the cell to show the data.
	NSDictionary *obj = [dataRows objectAtIndex:indexPath.row];
    
    
    
    
    
    //NSString *selectedSFObj;
    NSUserDefaults* stdDefaults = [NSUserDefaults standardUserDefaults];
    
    
    NSString *selectedSFObj = [stdDefaults valueForKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY];
    if(selectedSFObj) {
            //selectedSFObj = [sfObj valueForKey:OBJ_NAME];
        /*else {
            selectedSFObj = @"Account";
            [Utility setSFDefaultMappingValues];
        }*/
        //NSMutableString *queryString;
        
        if ([selectedSFObj isEqualToString:@"Task"]) {
            
             //queryString = [NSMutableString stringWithFormat:@"SELECT Id,Subject from %@",selectedSFObj];
            if([obj objectForKey:@"Subject"])
                cell.textLabel.text =  [obj objectForKey:@"Subject"];
            else {
                
                    cell.textLabel.text =  [obj objectForKey:@"Id"];
                }
        }
        else if ([selectedSFObj isEqualToString:@"Case"]) {
            //queryString = [NSMutableString stringWithFormat:@"SELECT Id,CaseNumber from %@",selectedSFObj];
            if([obj objectForKey:@"CaseNumber"])
                cell.textLabel.text =  [obj objectForKey:@"CaseNumber"];
            else {
                
                cell.textLabel.text =  [obj objectForKey:@"Id"];
            }
        }
        else if ([selectedSFObj isEqualToString:@"CaseComment"]) {
            //queryString = [NSMutableString stringWithFormat:@"SELECT Id,ParentId from %@",selectedSFObj];
            if([obj objectForKey:@"ParentId"])
                cell.textLabel.text =  [obj objectForKey:@"ParentId"];
            else {
                
                cell.textLabel.text =  [obj objectForKey:@"Id"];
            }
        }
        else if ([selectedSFObj isEqualToString:@"ContentVersion"]) {
            //queryString = [NSMutableString stringWithFormat:@"SELECT Id,ContentDocumentId from %@",selectedSFObj];
            if([obj objectForKey:@"ContentDocumentId"])
                cell.textLabel.text =  [obj objectForKey:@"ContentDocumentId"];
            else {
                
                cell.textLabel.text =  [obj objectForKey:@"Id"];
            }
        }
        else if ([selectedSFObj isEqualToString:@"Contract"]) {
            //queryString = [NSMutableString stringWithFormat:@"SELECT Id,ContractNumber from %@",selectedSFObj];
            if([obj objectForKey:@"ContractNumber"])
                cell.textLabel.text =  [obj objectForKey:@"ContractNumber"];
            else {
                
                cell.textLabel.text =  [obj objectForKey:@"Id"];
            }
        }
        else if ([selectedSFObj isEqualToString:@"Event"]) {
            //queryString = [NSMutableString stringWithFormat:@"SELECT Id,Subject from %@",selectedSFObj];
            if([obj objectForKey:@"Subject"])
                cell.textLabel.text =  [obj objectForKey:@"Subject"];
            else {
                
                cell.textLabel.text =  [obj objectForKey:@"Id"];
            }
        
        }
        else if ([selectedSFObj isEqualToString:@"Idea"]) {
            //queryString = [NSMutableString stringWithFormat:@"SELECT Id,Title from %@",selectedSFObj];
            if([obj objectForKey:@"Title"])
                cell.textLabel.text =  [obj objectForKey:@"Title"];
            else {
                
                cell.textLabel.text =  [obj objectForKey:@"Id"];
            }
        }
        else if ([selectedSFObj isEqualToString:@"Note"]) {
            //queryString = [NSMutableString stringWithFormat:@"SELECT Id,Title from %@",selectedSFObj];
            if([obj objectForKey:@"Title"])
                cell.textLabel.text =  [obj objectForKey:@"Title"];
            else {
                
                cell.textLabel.text =  [obj objectForKey:@"Id"];
            }
        }
        else if ([selectedSFObj isEqualToString:@"Solution"]) {
            //queryString = [NSMutableString stringWithFormat:@"SELECT Id,SolutionName from %@",selectedSFObj];
            if([obj objectForKey:@"SolutionName"])
                cell.textLabel.text =  [obj objectForKey:@"SolutionName"];
            else {
                
                cell.textLabel.text =  [obj objectForKey:@"Id"];
            }
        }
        else
        {

             if([obj objectForKey:@"label"])
             cell.textLabel.text =  [obj objectForKey:@"label"];
             else {
                    if([obj valueForKey:@"Name"] != nil) {
                        cell.textLabel.text =  [obj objectForKey:@"Name"];
                    } 
                    else {
                            cell.textLabel.text =  [obj objectForKey:@"Id"];
                    }
             }
        }
    }
    
	//this adds the arrow to the right hand side.
    cell.textLabel.font = [UIFont fontWithName:@"Verdana" size:13];
    //cell.textLabel.font = [UIFont fontWithName:@"ChalkboardSE-Regular" size:16];
	cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.textColor = [UIColor blackColor];
	return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.inEditMode) {
        BOOL selected = [[selectedRow objectAtIndex:[indexPath row]] boolValue];
        [selectedRow replaceObjectAtIndex:[indexPath row] withObject:[NSNumber numberWithBool:!selected]];
        DebugLog(@"%@",selectedRow);
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
        [_tableView reloadData];
    } else {
        selectedRecordId=indexPath.row;
        }
    DebugLog(@"sel obj:%@",[self.dataRows objectAtIndex:indexPath.row]);
}

@end
