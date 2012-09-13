//
//  SignInViewController.m
//  Noteprise
//
//  Created by Ritika on 19/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SignInViewController.h"
#import "Utility.h"
@interface SignInViewController ()

@end
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat iPad_LANDSCAPE_KEYBOARD_HEIGHT = 452;
static const CGFloat iPhone_PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat iPhone_LANDSCAPE_KEYBOARD_HEIGHT = 205;
@implementation SignInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
   // UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
/*
-(void)changeBkgrndImgWithOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
       if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
            backgroundImg.image = [UIImage imageNamed:@"evernoteBg480x300.png"];
        else {
            backgroundImg.image = [UIImage imageNamed:@"evernoteBg320x460.png"];
            }
        } else {
            
           if(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
               backgroundImg.image = [UIImage imageNamed:@"evernoteBg-1024x748.png"];
                //signInBtn.frame = CGRectMake(400, 520, 235, 57);
                }
           else {
               backgroundImg.image = [UIImage imageNamed:@"evernoteBg768x1024.png"];
                //signInBtn.frame = CGRectMake(270, 700, 235, 57);
                }
           }
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self changeBkgrndImgWithOrientation:toInterfaceOrientation];
}
 */
-(BOOL)validate{
    if([Utility isBlank:userNameTxt.text] || [Utility isBlank:pswdTxt.text]){
        return NO;
    }
    return YES;
}

-(void)navigateToSearchOptionVC{
    [Utility hideCoverScreen];
    BoxListViewController *notesListCnrl = [[BoxListViewController alloc]init];
    UINavigationController *noteListNavCntrl = [[UINavigationController alloc]initWithRootViewController:notesListCnrl];
    noteListNavCntrl.navigationBar.barStyle = UIBarStyleBlack;
    [[[UIApplication sharedApplication]delegate]window].rootViewController = noteListNavCntrl;
}
-(void)removeCoverScreen{
    [Utility hideCoverScreen];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == userNameTxt)
        [pswdTxt becomeFirstResponder];
    else if (textField == pswdTxt) {
        [self signin:nil];
    }
    return YES;
}
-(IBAction)signin:(id)sender{
    if([Utility checkNetwork]) {
        BoxLoginViewController * vc = [BoxLoginViewController loginViewControllerWithNavBar:YES];
        vc.boxLoginDelegate = self;
        [self presentModalViewController:vc animated:YES];
    } else {
        [Utility showAlert:NETWORK_UNAVAILABLE_MSG];
    }
}
- (void)boxLoginViewController:(BoxLoginViewController *)boxLoginViewController didFinishWithResult:(LoginResult)result{
    if(result == LoginSuccess)
            [self loadNotesListAfterAuthentication];
    else
            [Utility showAlert:ERROR_AUTHENTICATE_WITH_EVERNOTE_MSG];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)loadNotesListAfterAuthentication 
{    
    
    if ([BoxLoginViewController userSignedIn]) {
        BoxListViewController *noteListVC = [[BoxListViewController alloc]init];
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:noteListVC];
         navVC.navigationBar.barStyle = UIBarStyleBlack;
        [[[UIApplication sharedApplication]delegate]window].rootViewController = navVC;
        [noteListVC release];
    } else {
        //LOAD NOTHING ON FAILURE
    }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	//Perform an action
	[userNameTxt resignFirstResponder];
    [pswdTxt resignFirstResponder];
}

@end
