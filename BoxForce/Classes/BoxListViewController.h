//
//  BoxListViewController.h
//  Noteprise
//
//  Created by Ritika on 23/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import "BoxCommonUISetup.h"
#import "BoxFolder.h"
#define IDX_SEARCH_BASED_ON_NOTEBOOK 0
#define IDX_SEARCH_VIA_TAG 1
#define IDX_SEARCH_ACROSS_ACCOUNT 2

@interface BoxListViewController : UIViewController <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,MyPopoverDelegate>{
    
    NSMutableArray *listOfItems;
    NSMutableArray *fileObjArray;
    IBOutlet UITableView *notesTbl;
    IBOutlet UILabel *loadingLbl;
    IBOutlet UISearchBar *searchBar;
    IBOutlet UIBarButtonItem *addNoteBtn;
    IBOutlet UIBarButtonItem *settingsBtn;
    UIBarButtonItem *saveToSFBtn;
    UIPopoverController *popoverController;
    IBOutlet UISegmentedControl *searchOptionsChoiceCntrl;
    NSArray *noteBooks;
    NSArray * tags;
    NSString *noteTitle;
    NSString *noteContent;
    int selectedRowIndex;
    IBOutlet UIImageView *backgroundImgView;
    IBOutlet UIImageView *dialog_imgView;
    IBOutlet UIToolbar *bottom_bar;
    IBOutlet UIToolbar *toolbar;
    BoxFolder * _folderModel;
    IBOutlet 	UIActivityIndicatorView * _activityIndicator;
}
@property (nonatomic, retain) NSMutableArray *fileObjArray;

@end
