#import "HSFacebookPhotoAlbums.h"

static NSString *kAppID = @"200064460066186";
static NSString *PREFS_FILE = @"/User/Library/Preferences/com.homeschooldev.FacebookPluginPrefs.plist";
static BOOL loaded = NO;
static BOOL editing = NO;
static BOOL cellSelected = NO;
static BOOL creatingAlbum = NO;
static int kCreateAlbum = 1234567;
static int kTextField = 132400;

@implementation HSFacebookPhotoAlbums

- (id)init {
    if ((self = [super init])) {
        facebook = [[Facebook alloc] initWithAppId:kAppID andDelegate:self];
        albums = [[NSMutableArray alloc] init];
        ids = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *prefs;
        if ([[NSFileManager defaultManager] fileExistsAtPath:PREFS_FILE])
            prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
        else 
            prefs = [NSMutableDictionary dictionary];
        
        if (![prefs objectForKey:@"FirstTime"]) {
            if ([prefs objectForKey:@"FBAccessTokenKey"] || [prefs objectForKey:@"FBExpirationDateKey"]) {
                //First time running the plugin prefs, but a token existed from a previous install... We need to remove it.
                [prefs removeObjectForKey:@"FBAccessTokenKey"];
                [prefs removeObjectForKey:@"FBExpirationDateKey"];
            }
            //set the firstname key to no so this doesn't run again...
            [prefs setObject:@"NO" forKey:@"FirstTime"];
            [prefs writeToFile:PREFS_FILE atomically:YES];
        }
        
        if ([prefs objectForKey:@"FBAccessTokenKey"] && [prefs objectForKey:@"FBExpirationDateKey"]) {
            facebook.accessToken = [prefs objectForKey:@"FBAccessTokenKey"];
            facebook.expirationDate = [prefs objectForKey:@"FBExpirationDateKey"];
        }
    }
    return self;
}

- (id)initForContentSize:(CGSize)size {
	return [self init];
}

- (id)view {
	return _table;
}

- (void)viewWillAppear:(BOOL)animated {
	[self setNavigationTitle:[self navigationTitle]];
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (![facebook isSessionValid]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:@"You have no logged in yet. Would you like to log in now?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Log In",nil];
		[alert show];
		[alert release];
	}
}

- (void)setNavigationTitle:(NSString *)navigationTitle {
	if ([self respondsToSelector:@selector(navigationItem)]) { 
		[[self navigationItem] setTitle:navigationTitle]; 
	}
}

- (NSString *)navigationTitle {
	return @"Albums";
}

- (void)setSpecifier:(PSSpecifier *)specifier {
	[self loadFromSpecifier:specifier];
	[super setSpecifier:specifier];
}

- (void)loadFromSpecifier:(PSSpecifier *)specifier {
	_table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height - 65.0f) style:UITableViewStyleGrouped];
	
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait || 
			[[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) 
			_table.frame = CGRectMake(0,0,467,960);
		else
			_table.frame = CGRectMake(0,0,723,704);
	}
	
	[_table setDelegate:self];
	[_table setDataSource:self];
	[_table setAllowsSelectionDuringEditing:YES];
	
	act = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	act.frame = CGRectMake((_table.frame.size.width/2) - (act.frame.size.width/2),(_table.frame.size.height/2) - (act.frame.size.height/2),act.frame.size.width,act.frame.size.height);
	act.hidesWhenStopped = YES;
	[_table addSubview:act];
	[act release];
	
	if ([facebook isSessionValid])
		[self loadTable];
	else
		[_table reloadData];
}

- (void)loadTable {
	act.hidden = NO;
	[act startAnimating];

	[facebook requestWithGraphPath:@"me/albums" andDelegate:self];
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
	if (editing)
		return 2;
	else 
		return 1;
}

- (id)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section {
	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
	facebook.accessToken = [prefs objectForKey:@"FBAccessTokenKey"];
    facebook.expirationDate = [prefs objectForKey:@"FBExpirationDateKey"];
	
	if (section == 0) {
		if (![facebook isSessionValid])
			return @"Please log into your Facebook account before continuing...";
		else if (albums.count == 1)
			return @"You do not have any albums. You can create an album or do nothing and Fusion will upload to 'Fusion Photo'.";
		else
			return @"";
	}
	else 
		return @"";
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *c = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!c) {
		c = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
	}
	
	if (indexPath.section == 1) {
		c.textLabel.text = @"Create New Album";
	}
	else {
		NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
		if ([prefs objectForKey:@"SelectedAlbum"] && [[prefs objectForKey:@"SelectedAlbum"] isEqualToString:[albums objectAtIndex:indexPath.row]]) {
			cellSelected = YES;
			c.accessoryType = UITableViewCellAccessoryCheckmark;
			lastIndex = [indexPath retain];
		}
		c.textLabel.text = [albums objectAtIndex:indexPath.row];
	}

	return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES]; 
	
	if (lastIndex) {
		UITableViewCell *cell = [_table cellForRowAtIndexPath:lastIndex];
		cell.accessoryType = UITableViewCellAccessoryNone;
		[lastIndex release];
	}
	
	lastIndex = [indexPath retain];
	
	if (indexPath.section == 0) {
		UITableViewCell *cell = [_table cellForRowAtIndexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
		[prefs setObject:[albums objectAtIndex:indexPath.row] forKey:@"SelectedAlbum"];
		[prefs setObject:[ids objectAtIndex:indexPath.row] forKey:@"SelectedAlbumID"];
		[prefs writeToFile:PREFS_FILE atomically:YES];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Facebook Album" message:@"Please enter the name of the album you would like to create\n\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
		[alert setTag:kCreateAlbum];
		
		UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 95.0, 260.0, 31.0)];
        myTextField.placeholder = @"Album Name";
        [myTextField becomeFirstResponder];
        [myTextField setBackgroundColor:[UIColor whiteColor]];
        [myTextField setTag:kTextField];
        [myTextField setBorderStyle:UITextBorderStyleRoundedRect];
        myTextField.textAlignment=UITextAlignmentCenter;
        [alert addSubview:myTextField];
		
		[alert show];
		[myTextField release];
		[alert release];
	}
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(int)section {
	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
	facebook.accessToken = [prefs objectForKey:@"FBAccessTokenKey"];
    facebook.expirationDate = [prefs objectForKey:@"FBExpirationDateKey"];

	if (section == 0) {
		if ([facebook isSessionValid])
			return [albums count];
		else 
			return 0;
	}
	else {
		if (loaded && editing)
			return 1;
		else 
			return 0;
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath {
	if (indexPath.section == 1)
		return UITableViewCellEditingStyleInsert;
	else	
		return UITableViewCellEditingStyleNone;
}

- (void)login {
    if (![facebook isSessionValid]) {
        NSArray *permissions = [NSArray arrayWithObjects:@"user_photos",@"user_videos",@"publish_stream",@"offline_access",@"user_checkins",@"friends_checkins",@"email",@"user_location",@"publish_checkins" ,nil];
        facebook.controller = [self navigationController];
        [facebook authorize:permissions];
    }
}

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if ([alertView tag] == kCreateAlbum) {
		UITextField *textField = (UITextField*)[alertView viewWithTag:kTextField];
		[textField resignFirstResponder];
		if (![[textField text] isEqualToString:@""]) {
			[albums addObject:[textField text]];
			editing = NO;
			[_table setEditing:NO animated:NO];
			UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editTable:)];
			[[self navigationItem] setRightBarButtonItem:editButton];
			[editButton release];
			[act setHidden:NO];
			[act startAnimating];
			
			NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
			facebook.accessToken = [prefs objectForKey:@"FBAccessTokenKey"];
            facebook.expirationDate = [prefs objectForKey:@"FBExpirationDateKey"];
			NSMutableDictionary *params = [NSMutableDictionary dictionary];
			[params setObject:[textField text] forKey:@"message"];
			[params setObject:[textField text] forKey:@"name"];
			creatingAlbum = YES;
			[facebook requestWithGraphPath:@"me/albums" andParams:params andHttpMethod:@"POST" andDelegate:self];
		}
		else {
			UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry buddy, you can't have an album with no name. Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[error show];
			[error release];
		}
	}
	else {
		if (buttonIndex == 1) {
			[self login];
		}
	}
}

- (void)editTable:(id)sender {
	editing = YES;
	[_table setEditing:YES animated:NO];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(finishEditing:)];
	[[self navigationItem] setRightBarButtonItem:doneButton];
	[doneButton release];	
	[_table reloadData];
}

- (void)finishEditing:(id)sender {
	editing = NO;
	[_table setEditing:NO animated:NO];
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editTable:)];
	[[self navigationItem] setRightBarButtonItem:editButton];
	[editButton release];
	[_table reloadData];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		if (toInterfaceOrientation == UIInterfaceOrientationPortrait || 
			toInterfaceOrientation == UIDeviceOrientationPortraitUpsideDown) 
			_table.frame = CGRectMake(0,0,467,960);
		else
			_table.frame = CGRectMake(0,0,723,704);
	}
	//phones can't rotate in settings so no need to change the size of the view...
}

//******* Facebook delegate crap*******//
- (void)request:(FBRequest *)request didLoad:(id)result {
	if (creatingAlbum) {
		[ids addObject:[result objectForKey:@"id"]];
		creatingAlbum = NO;
		[act stopAnimating];
		[_table reloadData];
		
		return;
	}

	loaded = YES;
	NSArray *data = [result objectForKey:@"data"];
	for (NSDictionary *item in data) {
		[albums addObject:[item objectForKey:@"name"]];
		[ids addObject:[item objectForKey:@"id"]];
	}
	
	if (![albums containsObject:@"Fusion Photos"]) {
		[albums addObject:@"Fusion Photos"];
		[ids addObject:@"Fusion Photos"];
	}
	
	if (!cellSelected) {	
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[albums indexOfObject:@"Fusion Photos"] inSection:0];
		UITableViewCell *cell = [_table cellForRowAtIndexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		lastIndex = [indexPath retain];
		
		NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
		[prefs setObject:@"Fusion Photos" forKey:@"SelectedAlbum"];
		[prefs setObject:@"Fusion Photos" forKey:@"SelectedAlbumID"];
		[prefs writeToFile:PREFS_FILE atomically:YES];
	}
	
	[_table reloadData];
	
	[act stopAnimating];
	
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editTable:)];
	[[self navigationItem] setRightBarButtonItem:editButton];
	[editButton release];
}
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	[act stopAnimating];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Connection to Facebook failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}
- (void)fbDidLogin {
    NSMutableDictionary *prefs;
    if ([[NSFileManager defaultManager] fileExistsAtPath:PREFS_FILE])
    	prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
    else 
    	prefs = [NSMutableDictionary dictionary];
    [prefs setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [prefs setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [prefs writeToFile:PREFS_FILE atomically:YES];
    
    [self loadTable];
}
- (void)fbDidLogout {}
- (void)fbDidNotLogin:(BOOL)cancelled {}
- (void)fbDidExtendToken:(NSString*)accessToken expiresAt:(NSDate*)expiresAt {}
- (void)fbSessionInvalidated {}
//************************************//

- (void)dealloc {
    [facebook release];
    [albums release];
    [ids release];
    [lastIndex release];
    [super dealloc];
}

@end
