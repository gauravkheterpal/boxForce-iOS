//
//  Evernote.m
//  
//  A simple application demonstrating the use of the Evernote API
//  on iOS.
//
//  Before running this sample, you must change the API consumer key
//  and consumer secret to the values that you received from Evernote.
//
//  Evernote API sample code is provided under the terms specified 
//  in the file LICENSE.txt which was included with this distribution.
//

#import "Evernote.h"
#import "Utility.h"
#import "TTransportException.h"

// NOTE: You must change the consumer key and consumer secret to the
// key and secret that you received from Evernote. If you do not have
// an API key, visit http://dev.evernote.com/documentation/cloud/ to
// get one.
//NSString * const consumerKey  = @"dubeynikhileshs";
//NSString * const consumerSecret = @"1845964c8335f00c";
//NSString * const consumerKey  = @"noteprise-6118";
//NSString * const consumerSecret = @"86270bc68d76886d";
NSString * const consumerKey  = @"erritikamathur";
NSString * const consumerSecret = @"138fdc6191f75f0a";
// NOTE: You must change the username and password to the username and
// password of an account that you have created on the appropriate
// Evernote service. If you are testing against the sandbox service,
// you must create an account by visiting
//NSString * const username = @"dubeynikhileshs";
//NSString * const password = @"20091984nd";  

//NSString * username= nil;
//NSString * password = nil;;

//NSString * const userStoreUri = @"https://sandbox.evernote.com/edam/user";
//NSString * const userStoreUri = @"https://www.evernote.com/edam/user";

// NOTE: You must set the Application name and version
// used in the User-Agent
NSString * const applicationName = @"Noteprise";
NSString * const applicationVersion = @"1.0";

@implementation Evernote

//NSString * username= nil;
//NSString * password = nil;


@synthesize authToken, noteStoreUri, user, noteStore;

/************************************************************
 *
 *  Implementing the singleton pattern
 *
 ************************************************************/

static Evernote *sharedEvernoteManager = nil;

/************************************************************
 *
 *  Accessing the static version of the instance
 *
 ************************************************************/

+ (Evernote *)sharedInstance {

    if (sharedEvernoteManager == nil) {        
        sharedEvernoteManager = [[Evernote alloc] init];
    }
    
    return sharedEvernoteManager;
    
}

-(id)init{
  self = [super init];
    
  return self;
}

/************************************************************
 *
 *  Connecting to the Evernote server using simple
 *  authentication
 *
 ************************************************************/

- (BOOL) connect {
    EDAMAuthenticationResult* authResult = nil;
   
    
    authResult = [Utility autResult];
    if (authToken == nil || authResult == nil)
        //if (authResult == nil) 
    {      
        // In the case we are not connected we don't have an authToken
        // Instantiate the Thrift objects
        //NSURL * NSURLuserStoreUri = [[[NSURL alloc] initWithString: userStoreUri] autorelease];
        

        NSURL * NSURLuserStoreUri = [[[NSURL alloc] initWithString: [Utility valueInPrefForEvernoteUserStoreUri]] autorelease];
        
        THTTPClient *userStoreHttpClient = [[[THTTPClient alloc] initWithURL:  NSURLuserStoreUri] autorelease];
        TBinaryProtocol *userStoreProtocol = [[[TBinaryProtocol alloc] initWithTransport:userStoreHttpClient] autorelease];
        EDAMUserStoreClient *userStore = [[[EDAMUserStoreClient alloc] initWithProtocol:userStoreProtocol] autorelease];

        // Check that we can talk to the server
        bool versionOk = [userStore checkVersion: applicationName :[EDAMUserStoreConstants EDAM_VERSION_MAJOR] :    [EDAMUserStoreConstants EDAM_VERSION_MINOR]];
        
        if (!versionOk) {
           // Alerting the user that the note was created
            UIAlertView *alertDone = [[UIAlertView alloc] initWithTitle: @"Evernote" message: @"Incompatible EDAM client protocol version" delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
            
            [alertDone show];
            [alertDone release];
            
            return NO;
        }

        // Returned result from the Evernote servers after authentication
        
        @try {
            
            NSLog(@"Found AuthResult");
            authResult = nil;
            authResult =[userStore authenticate:[Utility valueInPrefForKey:KEY_EN_UNAME] :[Utility valueInPrefForKey:KEY_EN_PASSWORD] : consumerKey :consumerSecret];
        }
        @catch (EDAMUserException  *exception) {
            
            NSLog(@"Recvd Exception:%d",exception.errorCode );
            [Utility showAlert:@"Login Failed. Please check your username and password."];
            return NO;
        }
        @catch (EDAMSystemException *exception) {
            [Utility showExceptionAlert:exception.description];
            return NO;
        }
        @catch (TTransportException *exception) {
            [Utility showExceptionAlert:exception.reason];
            return NO;
        }
    }
        if(authResult){
            // User object describing the account
            self.user = [authResult user];
            // We are going to save the authentication token
            self.authToken = [authResult authenticationToken];
            
            noteStoreUri = [[[NSURL alloc] initWithString:[authResult noteStoreUrl] ] autorelease];
            
            // Creating the User-Agent
            UIDevice *device = [UIDevice currentDevice];
            NSString * userAgent = [NSString stringWithFormat:@"%@/%@;%@(%@)/%@", applicationName,applicationVersion, [device systemName], [device model], [device systemVersion]]; 
            
            // Initializing the NoteStore client
            THTTPClient *noteStoreHttpClient = [[[THTTPClient alloc] initWithURL:noteStoreUri userAgent: userAgent timeout:15000] autorelease];
            TBinaryProtocol *noteStoreProtocol = [[[TBinaryProtocol alloc] initWithTransport:noteStoreHttpClient] autorelease];
            noteStore = [[[EDAMNoteStoreClient alloc] initWithProtocol:noteStoreProtocol] retain]; 
            [Utility saveAuthResult:authResult];
        } else {
            [Utility showAlert:@"Login Failed. Please check your username and password."];
            return NO;
        }
        return YES;
}

/************************************************************
 *
 *  Listing all the user's notebooks
 *
 ************************************************************/

- (NSArray *) listNotebooks {   
    
    // Checking the connection
    [self connect];
    
    // Calling a function in the API
    NSArray *notebooks = [[NSArray alloc] initWithArray:[[self noteStore] listNotebooks:authToken] ];
    
    return notebooks;
}

/************************************************************
 *
 *  Listing all the user's notebooks
 *
 ************************************************************/

- (NSArray *) listTags {   
    // Calling a function in the API
    NSArray *notebooks = [[NSArray alloc] initWithArray:[[self noteStore] listTags:authToken] ];
    return notebooks;
}


/************************************************************
 *
 *  Searching for notes using a EDAM Note Filter
 *
 ************************************************************/

- (EDAMNoteList *) findNotes: (EDAMNoteFilter *) filter {
    // Checking the connection
    [self connect];
    
    
    // Calling a function in the API 
    return [noteStore findNotes:authToken:filter:0 :100];
}


/************************************************************
 *
 *  Loading a note using the guid
 *
 ************************************************************/

- (EDAMNote *) getNote: (NSString *) guid {
    // Checking the connection
    [self connect];
    
    // Calling a function in the API
    return [noteStore getNote:authToken :guid :true :true :true :true];
}


/************************************************************
 *
 *  Deleting a note using the guid
 *
 ************************************************************/

- (void) deleteNote: (NSString *) guid {
    // Checking the connection
    [self connect];

    // Calling a function in the API
    [noteStore deleteNote:authToken :guid];
}


/************************************************************
 *
 *  Creating a note
 *
 ************************************************************/

- (void) createNote: (EDAMNote *) note {
    // Checking the connection
    [self connect];

    // Calling a function in the API
    [noteStore createNote:authToken :note];
}

- (void)dealloc
{
    [noteStore release];
    [super dealloc];

}

@end
