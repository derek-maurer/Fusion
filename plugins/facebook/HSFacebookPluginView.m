#import "HSFacebookPluginView.h"

static NSString *Location = @"/User/Library/Preferences/com.homeschooldev.FacebookLocation.plist";
static BOOL foundLocationID = NO;

@implementation HSFacebookPluginView
@synthesize data, location, delegate, selectedIndex;

- (id)initWithData:(NSDictionary *)d location:(CLLocation *)l andDelegate:(id<FusionViewDelegate>)del {
	if ((self = [super init])) {
		self.data = d;
		self.location = l;
		self.delegate = del;
		
		wrapperView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,480)];
		textView = [[UILabel alloc] initWithFrame:wrapperView.frame];
		
		textView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
		textView.textColor = [UIColor whiteColor];
		textView.textAlignment = UITextAlignmentCenter;
		[wrapperView addSubview:textView];
		[textView release];
		
		tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,480) style:UITableViewStylePlain];
		tableView.delegate = self;
		tableView.dataSource = self;
		[wrapperView addSubview:tableView];
		[tableView release];
		
		tableView.hidden = YES;
		textView.hidden = NO;
		
		if (location) {
			[self initFacebook];
		}
		else {
			textView.text = @"No location...";
			tableView.hidden = YES;
			textView.hidden = NO;
		}
	}
	return self;
}

- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tView deselectRowAtIndexPath:indexPath animated:YES];

	NSMutableDictionary *dict;
	if ([[NSFileManager defaultManager] fileExistsAtPath:Location])
		dict = [[NSMutableDictionary alloc] initWithContentsOfFile:Location];
	else
		dict = [[NSMutableDictionary alloc] init];
		
	UITableViewCell *cell = [tView cellForRowAtIndexPath:indexPath];
	if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
		cell.accessoryType = UITableViewCellAccessoryNone;
		[dict setObject:@"" forKey:@"Venue"];
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		if ([[items objectForKey:@"ids"] objectAtIndex:indexPath.row]) 
			[dict setObject:[[items objectForKey:@"ids"] objectAtIndex:indexPath.row] forKey:@"Venue"];
	}
	
	if (selectedIndex && selectedIndex.row >= 0 && selectedIndex.row != indexPath.row) {
		UITableViewCell *cell = [tView cellForRowAtIndexPath:selectedIndex];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
		
	self.selectedIndex = indexPath;
	
	[dict writeToFile:Location atomically:YES];
	[dict release];
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *MyIdentifier = @"cell";

    UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
        	reuseIdentifier:MyIdentifier] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = [[items objectForKey:@"names"] objectAtIndex:indexPath.row];
    
    NSDictionary *dict = [[[NSDictionary alloc] initWithContentsOfFile:Location] autorelease];

    if ((selectedIndex && indexPath.row == selectedIndex.row) || [[dict objectForKey:@"Venue"] isEqualToString:[[items objectForKey:@"ids"] objectAtIndex:indexPath.row]]) {
    	cell.accessoryType = UITableViewCellAccessoryCheckmark;
    	foundLocationID = YES;
   	}
    	
    if (indexPath.row == [[items objectForKey:@"names"] count] && foundLocationID) {	
    	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:Location];
    	[dict setObject:@"" forKey:@"Venue"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[items objectForKey:@"names"] count];
}

- (void)locationButtonTappedOnWithLocation:(CLLocation*)loc {

	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
	if ([prefs objectForKey:@"FBAccessTokenKey"] && [prefs objectForKey:@"FBExpirationDateKey"]) {
    	facebook.accessToken = [prefs objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [prefs objectForKey:@"FBExpirationDateKey"];
    }

	if (![facebook isSessionValid]) {
		textView.text = @"You must authenticate Facebook before you can get nearby locations.";
		textView.hidden = NO;
		tableView.hidden = YES;
    }
    else {    	
    	//self.location = loc;
    	textView.hidden = YES;
    	tableView.hidden = NO;
    	[wrapperView bringSubviewToFront:tableView];
    	[self startSpinner];
		NSString *centerString = [NSString stringWithFormat: @"%f,%f", loc.coordinate.latitude, loc.coordinate.longitude];
		NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"place",@"type",centerString,@"center",@"10000",@"distance", nil];
		[facebook requestWithGraphPath:@"search" andParams: params andDelegate:self];
    }
}

- (void)locationButtonTappedOff {
	NSMutableDictionary *dict;
	if ([[NSFileManager defaultManager] fileExistsAtPath:Location])
		dict = [[NSMutableDictionary alloc] initWithContentsOfFile:Location];
	else
		dict = [[NSMutableDictionary alloc] init];
	[dict setObject:@"" forKey:@"Venue"];
	[dict writeToFile:Location atomically:YES];

	//if (location) [location release];
	tableView.hidden = YES;
	textView.hidden = NO;
	textView.text = @"No location...";
	
	if (items.count > 0) [items removeAllObjects];
	[tableView reloadData];
}

- (void)viewUpdatedWithFrame:(CGRect)frame {
	textView.frame = frame;
	tableView.frame = frame;
}

- (BOOL)shouldAppearBeforePost {
	if (!location) return NO;
	if (![[NSFileManager defaultManager] fileExistsAtPath:Location]) return YES;
    
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:Location];	
	
	if ([[dict objectForKey:@"Venue"] isEqualToString:@""]) return YES;
	else return NO;
}

- (id)view {
	return wrapperView;
}

- (void)startSpinner {
	act = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	act.center = wrapperView.center;
	[act setHidesWhenStopped:YES];
	[act startAnimating];
	[wrapperView addSubview:act];
	[act release];
}

- (void)initFacebook {
	facebook = [[Facebook alloc] initWithAppId:kAppID andDelegate:self];
	
	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_FILE];
	
    if ([prefs objectForKey:@"FBAccessTokenKey"] && [prefs objectForKey:@"FBExpirationDateKey"]) {
    	facebook.accessToken = [prefs objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [prefs objectForKey:@"FBExpirationDateKey"];
    }
    
    if (![facebook isSessionValid]) {
		textView.text = @"You must authenticate Facebook before you can get nearby locations.";
		textView.hidden = NO;
		tableView.hidden = YES;
    }
    else {
		textView.hidden = YES;
		tableView.hidden = NO;
		
		[self startSpinner];
		
		NSString *centerString = [NSString stringWithFormat: @"%f,%f", location.coordinate.latitude, location.coordinate.longitude];
		NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"place",@"type",centerString,@"center",@"10000",@"distance", nil];
		[facebook requestWithGraphPath:@"search" andParams: params andDelegate:self];
    }
}

- (void)request:(FBRequest *)request didLoad:(id)result {
	if (act) [act stopAnimating];
	
	NSArray *tems = [result objectForKey:@"data"];
	if (!items) items = [[NSMutableDictionary alloc] init];
	NSMutableArray *names = [[[NSMutableArray alloc] init] autorelease];
	NSMutableArray *ids = [[[NSMutableArray alloc] init] autorelease];
	for (NSUInteger i=0; i < tems.count; i++) {
		NSDictionary *item = [tems objectAtIndex:i];
		if ([item objectForKey:@"name"] && ![[item objectForKey:@"name"] isEqualToString:@""]) {
			[names addObject:[item objectForKey:@"name"]];
		}
		if ([item objectForKey:@"id"] && ![[item objectForKey:@"id"] isEqualToString:@""]) {
			[ids addObject:[item objectForKey:@"id"]];
		}
	}
	
	if (names) [items setObject:names forKey:@"names"];
	if (ids) [items setObject:ids forKey:@"ids"];
	
	if (names.count == 0) {
		textView.text = @"No nearby locations...";
		textView.hidden = NO;
		[wrapperView bringSubviewToFront:textView];
	}
	
	[tableView reloadData];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	if (act) [act stopAnimating];
	NSLog(@"NearbyPlaces %@", [error localizedDescription]);
}

//Facebook delegate methods...
- (void)fbDidLogin {}
- (void)fbDidLogout {}
- (void)fbDidNotLogin:(BOOL)cancelled {}
- (void)fbDidExtendToken:(NSString*)accessToken expiresAt:(NSDate*)expiresAt {}
- (void)fbSessionInvalidated {}

- (void)dealloc {
	if (items) [items release];
	if (data) [data release];
	if (location) [location release];
	if (delegate) [delegate release];
	if (selectedIndex) [selectedIndex release];
	if (wrapperView) [wrapperView release];
	
	[super dealloc];
}

@end
