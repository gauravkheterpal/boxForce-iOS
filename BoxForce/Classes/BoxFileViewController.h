//
//  BoxFileViewController.h
//  
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"
#import "BoxDownloadOperation.h"
static int editBtnTag = 1;
static int saveBtnTag = 2;

@interface BoxFileViewController : UIViewController <UIWebViewDelegate,SFRestDelegate,UIActionSheetDelegate,BoxOperationDelegate>{

    UINavigationBar * noteNavigation;
    //UITextView * noteContent;
    UIWebView * noteContent;
    //UIImageView * noteImage;
    IBOutlet UIActivityIndicatorView *loadingSpinner;
    IBOutlet UIImageView *dialog_imgView;
    IBOutlet UILabel *loadingLbl;
    IBOutlet UIImageView *backgroundImgView;
    
    //UIBarButtonItem *saveButton;
    //UIBarButtonItem *editButton;
    //UIToolbar* toolbar;
    IBOutlet UIImageView *doneImgView;
    UIActionSheet *postToChatterOptionActionSheet;
    IBOutlet UIBarButtonItem *saveToSFBarBtn;
    IBOutlet UIBarButtonItem *postToChatterBarBtn;
    IBOutlet UIProgressView *progressView;
    NSOperationQueue * _operationQueue;
	id delegate;

}

@property(nonatomic, assign) NSString * guid;
//@property (nonatomic, retain) IBOutlet UIImageView * noteImage;
@property (nonatomic, retain) IBOutlet UINavigationBar * noteNavigation;
//@property (nonatomic, retain) IBOutlet UITextView * noteContent;
@property (nonatomic, retain) IBOutlet UIWebView * noteContent;
@property (nonatomic, retain) NSMutableString * textContent;

-(IBAction)linkEvernoteToSF:(id)sender;
-(void)goBack:(id)sender;
-(void)moveToSF;
-(void)setContentEditable:(BOOL)isEditable;
-(void)setWebViewKeyPressDetectionEnabled:(BOOL)isEnabled ;
-(void)setWebViewTapDetectionEnabled:(BOOL)isEnabled ;
-(void)increaseZoomFactorRange;
-(void)updateNoteEvernote ;
//-(void)setupNavigationButtons ;
-(void)changeBkgrndImgWithOrientation;
-(void)hideDoneToastMsg:(id)sender;
- (NSString *)getDataBetweenFromString:(NSString *)data leftString:(NSString *)leftData rightString:(NSString *)rightData leftOffset:(NSInteger)leftPos;
-(void)dismissPreviousPopover;
-(void)showLoadingLblWithText:(NSString*)Loadingtext;
-(void)postToChatterWall ;
-(void)getFileDownloadAsyncWithObjectId:(NSString*)fileId;

@end
