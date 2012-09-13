//
//  BoxFileViewController.m
//  client
//

#import "BoxFileViewController.h"
#import "RootViewController.h"
#import "Utility.h"
#import "BoxUser.h"
#import "NSData+Base64.h"
@implementation BoxFileViewController {
}


@synthesize guid, noteNavigation, noteContent,textContent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


/************************************************************
 *
 *  Function that loads all the information concerning 
 *  the note we are viewing
 *
 ************************************************************/

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Background_pattern_tableview.png"]];
    self.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
    
    _operationQueue = [[NSOperationQueue alloc] init];
    DebugLog(@"guid:%@",guid);
    [self getFileDownloadAsyncWithObjectId:guid];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
        [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:45/255.0 green:127/255.0 blue:173/255.0 alpha:1]];
    
}
-(void)getFileDownloadAsyncWithObjectId:(NSString*)fileId {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    BoxUser * userModel = [BoxUser savedUser];
    
    //NSString * ticket = userModel.authToken;
    
    NSString *filePath = [[Utility applicationDocumentsDirectory] stringByAppendingPathComponent:self.title]; 
        DebugLog(@"filePath:%@", filePath);
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    BoxDownloadOperation *downOper = [BoxDownloadOperation operationForFileID:fileId toPath:filePath];
    downOper.delegate = self;
    //BoxDownloadOperation *downOper = [BoxDownloadOperation operationForFileID:[fileId intValue] toPath:filePath authToken:ticket delegate:self];
    [_operationQueue addOperation:downOper];
    
    [pool release];
}
-(void)addAttachment:(NSData*)fileData fileName:(NSString*)fName{
    
    NSString * base64Str =  [fileData  base64EncodedString];
    NSMutableDictionary * fields =[[NSMutableDictionary alloc] init];
    
    // parrentTaskID = @"00T9000000AaYSsEAN";
    
    [fields setValue:@"0019000000DNqzl" forKey:@"ParentId"];
    [fields setValue:fName forKey:@"Name"];
    [fields setValue:base64Str forKey:@"Body"];
    
    SFRestRequest * request =  [[SFRestAPI sharedInstance] requestForCreateWithObjectType:@"Attachment" fields:fields];
    [[SFRestAPI sharedInstance] send:request delegate:self];
    
}
- (void)operation:(BoxOperation *)op willBeginForPath:(NSString *)path {
	NSLog(@"lockout the UI here");
    //[Utility showCoverScreen];
    saveToSFBarBtn.enabled = NO;
    DebugLog(@"filePath:%@", path);
    progressView.hidden = NO;
    [progressView setProgress:0];
    [loadingSpinner startAnimating];
    dialog_imgView.hidden = NO;
    loadingLbl.text = GETTING_NOTE_DETAILS_MSG;
    loadingLbl.hidden = NO;
    [loadingSpinner startAnimating];
}
- (void)operation:(BoxOperation *)op didProgressForPath:(NSString *)path completionRatio:(NSNumber *)ratio{
    DebugLog(@"didProgressForPath :%@ Percentage:%@", path,ratio);
    [self performSelectorOnMainThread:@selector(setProgress:) withObject:ratio waitUntilDone:YES];
    
}
-(void)setProgress:(NSNumber*)ratio
{   
    [progressView setProgress:[ratio floatValue]];
}
- (void)operation:(BoxOperation *)op didCompleteForPath:(NSString *)path response:(BoxOperationResponse)response{
    progressView.hidden = YES;
    saveToSFBarBtn.enabled = YES;
    [progressView setProgress:0];
    //NSData *fileData = [NSData dataWithContentsOfFile:path];
    NSArray *temp = [path componentsSeparatedByString:@"/"]; 
    NSString *fileName = [temp objectAtIndex:[temp count]-1];
    NSLog(@"didCompleteForPath %@ resp:%d fileNAme:%@",path,response,fileName);
    [Utility hideCoverScreen];
    [self hideDoneToastMsg:nil];
    if(response == BoxOperationResponseSuccessful){
        //[self addAttachment:fileData fileName:fileName];
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:path];
        NSURLRequest* request = [NSURLRequest requestWithURL:fileURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
        NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
        [NSURLCache setSharedURLCache:sharedCache];
        [sharedCache release];
        sharedCache = nil;
        //[webView loadRequest:request];
		[noteContent loadRequest:request];
    }
    else
        [Utility showAlert:@"Error downloading file"];
    
}

- (NSString *)getDataBetweenFromString:(NSString *)data leftString:(NSString *)leftData rightString:(NSString *)rightData leftOffset:(NSInteger)leftPos 
{         
    NSInteger left, right;         
    NSString *foundData;
    NSScanner *scanner=[NSScanner scannerWithString:data];                  
    [scanner scanUpToString:leftData intoString: nil];         
    left = [scanner scanLocation];         
    [scanner setScanLocation:left + leftPos];         
    [scanner scanUpToString:rightData intoString: nil];         
    right = [scanner scanLocation] + 1;         
    left += leftPos;         
    foundData = [data substringWithRange: NSMakeRange(left, (right - left) - 1)];         return foundData; 
}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
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
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == CHATTER_POST_LIMIT_ALERT_TAG && alertView.cancelButtonIndex == buttonIndex) {
    } else if (alertView.tag == CHATTER_POST_LIMIT_ALERT_TAG) {
        [Utility showCoverScreen];
        [self showLoadingLblWithText:POSTING_NOTE_TO_CHATTER_WALL_MSG];
        //truncationg note text to 1000 character for posting to Chatter
        NSString *truncatedTextContent = [[textContent substringToIndex:999]mutableCopy];
        NSString * path = POST_TO_CHATTER_WALL_URL;
        NSDictionary *param = [[NSDictionary alloc]initWithObjectsAndKeys:@"Text",@"type",truncatedTextContent, @"text",nil];
        NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:param],@"messageSegments", nil];
        NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:message,@"body", nil];
        SFRestRequest *request = [SFRestRequest requestWithMethod:SFRestMethodPOST path:path queryParams:body];
        [[SFRestAPI sharedInstance] send:request delegate:self];
    }
}
-(IBAction)linkEvernoteToSF:(id)sender {
    [self dismissPreviousPopover];
    DebugLog(@"old obj:%@ sf obje:%@",[Utility valueInPrefForKey:OLD_SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY],[Utility valueInPrefForKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY]);
    if(([Utility valueInPrefForKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY] == nil)&& ([Utility valueInPrefForKey:OLD_SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY] == nil)) {
        //set previous selected mapping
        [Utility showAlert:SF_OBJECT_FIELD_MISSING_MSG];
        return;
    }
    else if(([Utility valueInPrefForKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY] == nil ) && [Utility valueInPrefForKey:OLD_SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY] !=nil) {
        //set previous selected mapping
        [Utility setValueInPref:[Utility valueInPrefForKey:OLD_SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY] forKey:SFOBJ_WITH_ATTACHEMNT_TO_MAP_KEY];

    }
    [Utility showCoverScreen];
    [self moveToSF];
}
-(IBAction)postToChatter:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self dismissPreviousPopover];
        postToChatterOptionActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Post to Wall",@"Post to Chatter Users",@"Post to Chatter Group", nil];
    } else {
        [self dismissPreviousPopover];
        postToChatterOptionActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Post to Wall",@"Post to Chatter Users",@"Post to Chatter Group", nil];
    }

    postToChatterOptionActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [postToChatterOptionActionSheet showFromBarButtonItem:postToChatterBarBtn animated:YES];
}
-(void)dismissPreviousPopover{    
    if([postToChatterOptionActionSheet isVisible])
        [postToChatterOptionActionSheet dismissWithClickedButtonIndex:[postToChatterOptionActionSheet cancelButtonIndex] animated:YES];

}
-(IBAction)editPage:(id)sender 
{
    CGRect frameimg = CGRectMake(0, 0, 27,27);
    if (self.navigationItem.rightBarButtonItem.tag == editBtnTag) {
        saveToSFBarBtn.enabled = NO;
        postToChatterBarBtn.enabled = NO;
        
        self.navigationItem.rightBarButtonItem.title = @"Save to Evernote";
        
        UIImage* saveImg = [UIImage imageNamed:@"Save.png"];
        UIImage* saveDoneImg = [UIImage imageNamed:@"Save_down.png"];
        
        UIButton *saveButton = [[UIButton alloc] initWithFrame:frameimg];
        [saveButton setBackgroundImage:saveImg forState:UIControlStateNormal];
        [saveButton setBackgroundImage:saveDoneImg forState:UIControlStateHighlighted];
        [saveButton addTarget:self action:@selector(editPage:) forControlEvents:UIControlEventTouchUpInside];
        [saveButton setShowsTouchWhenHighlighted:YES];
        UIBarButtonItem *saveBarButton =[[UIBarButtonItem alloc] initWithCustomView:saveButton];
        
        self.navigationItem.rightBarButtonItem = saveBarButton;
        [saveButton release];
        self.navigationItem.rightBarButtonItem.tag = saveBtnTag;
        dialog_imgView.hidden = NO;
        [loadingSpinner stopAnimating];
        loadingLbl.text = @"Edit mode activated...";
        loadingLbl.hidden = NO;
        [Utility hideCoverScreen];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hideDoneToastMsg:) userInfo:nil repeats:NO];
        
        [self setContentEditable:YES];
        [self setWebViewKeyPressDetectionEnabled:YES];
        [self setWebViewTapDetectionEnabled:YES];    
        [self increaseZoomFactorRange];
    }
    else if (self.navigationItem.rightBarButtonItem.tag == saveBtnTag) {
        [self.view endEditing:YES];
        saveToSFBarBtn.enabled = YES;
        postToChatterBarBtn.enabled = YES;
        self.navigationItem.rightBarButtonItem.title = @"Edit";
       
        
        UIImage* editImg = [UIImage imageNamed:@"Edit.png"];
        UIImage* editDownImg = [UIImage imageNamed:@"Edit_down.png"];
        UIButton *editButton = [[UIButton alloc] initWithFrame:frameimg];
        [editButton setBackgroundImage:editImg forState:UIControlStateNormal];
        [editButton setBackgroundImage:editDownImg forState:UIControlStateHighlighted];
        [editButton addTarget:self action:@selector(editPage:) forControlEvents:UIControlEventTouchUpInside];
        [editButton setShowsTouchWhenHighlighted:YES];
        UIBarButtonItem *editBarButton =[[UIBarButtonItem alloc] initWithCustomView:editButton];
        
        self.navigationItem.rightBarButtonItem = editBarButton;
        [editButton release];
         self.navigationItem.rightBarButtonItem.tag = editBtnTag;
        [self setContentEditable:NO];
        [self setWebViewKeyPressDetectionEnabled:NO];
        [self setWebViewTapDetectionEnabled:NO];  
        [self resignFirstResponder];
        [noteContent resignFirstResponder];
        //[self increaseZoomFactorRange];
        // NSString *htmlString = [noteContent stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
        // DebugLog(@"htmlString : %@",htmlString);
        [self updateNoteEvernote];
    }
  
   
    
    
}

-(void)moveToSF{
    RootViewController * rootVC = [[RootViewController alloc] init];
    rootVC.fileName = self.title; 
    rootVC.noteContent = textContent;
    //rootVC.noteContent = noteContent.text;
    [self.navigationController pushViewController:rootVC animated:YES];
    [rootVC release];
    
    [Utility hideCoverScreen];
    
}

/************************************************************
 *
 *  Function that closes the view
 *  On the back click
 *
 ************************************************************/

-(void)goBack:(id)sender
{
    [self.parentViewController dismissModalViewControllerAnimated:true];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
    [self changeBkgrndImgWithOrientation];
}
#pragma mark - View lifecycle
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    //[noteImage release];
    [noteNavigation release];
    [noteContent release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    DebugLog(@"Url to load = %@",request.URL.absoluteString);
    [self showLoadingLblWithText:@"Loading file"];
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [Utility showAlert:[error localizedDescription]];
    [self hideDoneToastMsg:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideDoneToastMsg:nil];
}
-(void)showLoadingLblWithText:(NSString*)Loadingtext{
    [loadingSpinner startAnimating];
    dialog_imgView.hidden = NO;
    loadingLbl.text = Loadingtext;
    loadingLbl.hidden = NO;
}
-(void)hideDoneToastMsg:(id)sender{
	dialog_imgView.hidden = YES;
    loadingLbl.hidden = YES;
    doneImgView.hidden = YES;
    [loadingSpinner stopAnimating];
}
#pragma mark - SFRestAPIDelegate
- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    DebugLog(@"request:%@",[request description]);
    DebugLog(@"jsonResponse:%@",jsonResponse);

    if([[request path] rangeOfString:POST_TO_CHATTER_WALL_URL].location != NSNotFound){
        //post to wall
        if([[jsonResponse objectForKey:@"errors"] count]==0){
            [Utility hideCoverScreen];
            [self showLoadingLblWithText:salesforce_chatter_post_self_success_message];
            [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(hideDoneToastMsg:) userInfo:nil repeats:NO];
            [loadingSpinner stopAnimating];
            NSArray *records = [jsonResponse objectForKey:@"records"];
            DebugLog(@"request:didLoadResponse: #records: %d records %@ req %@ rsp %@", records.count,records,request,jsonResponse);
            
        }
        else{
            [loadingSpinner stopAnimating];
            [Utility showAlert:POSTING_NOTE_FAILED_TO_CHATTER_WALL_MSG];
            [Utility hideCoverScreen];
        }
        
        
    }
}


- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    DebugLog(@"request:didFailLoadWithError: %@ code:%d path:%@", error,error.code,request.path);
    DebugLog(@"request:didFailLoadWithError:error.userInfo :%@",error.userInfo);
    [Utility hideCoverScreen];
    [self hideDoneToastMsg:nil];
    //add your failed error handling here
    NSString *alertMessaage ;
    if([[error.userInfo valueForKey:@"errorCode"] isEqualToString:@"STRING_TOO_LONG"]) {
        alertMessaage = CHATTER_LIMIT_CROSSED_ERROR_MSG;
    } else if([[error.userInfo valueForKey:@"errorCode"] isEqualToString:@"API_DISABLED_FOR_ORG"]) {
        alertMessaage = CHATTER_API_DISABLED;
    }
    else {
        alertMessaage = [error.userInfo valueForKey:@"message"];
    }
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:alertMessaage delegate:nil cancelButtonTitle:ALERT_NEUTRAL_BUTTON_TEXT otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
    DebugLog(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
    [Utility hideCoverScreen];
    [self hideDoneToastMsg:nil];
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    DebugLog(@"requestDidTimeout: %@", request);
    //add your failed error handling here
    [Utility hideCoverScreen];
    [self hideDoneToastMsg:nil];
}

@end
