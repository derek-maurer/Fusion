#import "HSFoursquarePluginView.h"

static NSString *VENUE = @"/User/Library/Preferences/com.homeschooldev.FourSquarePrefs.plist";
static NSString *PREFS = @"/User/Library/Preferences/com.homeschooldev.FourSquareAccessToken.plist";
static BOOL foundLocationID = NO;

@implementation HSFoursquarePluginView
@synthesize selectedIndex, location, data, delegate;

- (id)initWithData:(NSDictionary *)d location:(CLLocation *)l andDelegate:(id<FusionViewDelegate>) del {
	if ((self = [super init])) {
		self.delegate = del;
		self.data = d;
		self.location = l;
		
		wrapperView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,480)];
		
		tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,480) style:UITableViewStylePlain];
		tableView.delegate = self;
		tableView.dataSource = self;
		tableView.hidden = YES;
		[wrapperView addSubview:tableView];
		[tableView release];
		
		textView = [[UITextView alloc] initWithFrame:CGRectMake(0,0,320,480)];
		textView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
		textView.editable = NO;
		textView.textColor = [UIColor whiteColor];
		textView.textAlignment = UITextAlignmentCenter;
		textView.hidden = YES;
		[wrapperView addSubview:textView];
		[textView release];
		
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREFS];
        if ([dict objectForKey:@"access_token"]) {
        	[Foursquare2 setAccessToken:[dict objectForKey:@"access_token"]];
        }
        
        if (![Foursquare2 isNeedToAuthorize]) {
        	if (location) {
        		textView.hidden = YES;
        		tableView.hidden = NO;
				NSString *lat = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
				NSString *lon = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
				[self startSpinner];
				[Foursquare2 searchVenuesNearByLatitude:lat longitude:lon accuracyLL:nil altitude:nil 
					accuracyAlt:nil query:nil limit:@"1000" intent:@"checkin" callback:^(BOOL success, id result) {
					items = [self venueNames:(NSDictionary*)result];
					[tableView reloadData];
					if (act) [act stopAnimating];
				}];
            	
            }
            else {
				textView.text = @"No location...";
				tableView.hidden = YES;
				textView.hidden = NO;
            }
        }
        else {
			textView.text = @"You must authenticate Foursquare before you can get nearby locations.";
			tableView.hidden = YES;
			textView.hidden = NO;
        }
	}
	return self;
}

- (NSMutableDictionary *)venueNames:(NSDictionary *)results {
	if (items) [items release];
	
	NSMutableDictionary *tems = [[NSMutableDictionary alloc] init];
	
	NSMutableArray *names = [[[NSMutableArray alloc] init] autorelease];
	NSMutableArray *venueIds = [[[NSMutableArray alloc] init] autorelease];
	NSMutableArray *dist = [[[NSMutableArray alloc] init] autorelease];
	
	NSDictionary *response = [(NSDictionary*)results objectForKey:@"response"];
	NSArray *groups = [response objectForKey:@"groups"];
	NSDictionary *itemsDict = [groups objectAtIndex:0];
	NSArray *itemsArray = [itemsDict objectForKey:@"items"];
	for (NSUInteger i=0; i < itemsArray.count; i++) {
		NSDictionary *item = [itemsArray objectAtIndex:i];
		[venueIds addObject:[item objectForKey:@"id"]];
		[dist addObject:[[item objectForKey:@"location"] objectForKey:@"distance"]];
		[names addObject:[item objectForKey:@"name"]];
	}
	
	[tems setObject:names forKey:@"names"];
	[tems setObject:venueIds forKey:@"ids"];
	[tems setObject:dist forKey:@"distance"];
	
	return tems;
}

- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tView deselectRowAtIndexPath:indexPath animated:YES];

	NSMutableDictionary *dict;
	if ([[NSFileManager defaultManager] fileExistsAtPath:VENUE])
		dict = [[NSMutableDictionary alloc] initWithContentsOfFile:VENUE];
	else
		dict = [[NSMutableDictionary alloc] init];
		
	UITableViewCell *cell = [tView cellForRowAtIndexPath:indexPath];
	if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
		cell.accessoryType = UITableViewCellAccessoryNone;
		[dict setObject:@"" forKey:@"Venue"];
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		[dict setObject:[[items objectForKey:@"ids"] objectAtIndex:indexPath.row] forKey:@"Venue"];
	}
	
	if (selectedIndex && selectedIndex.row >= 0 && selectedIndex.row != indexPath.row) {
		UITableViewCell *cell = [tView cellForRowAtIndexPath:selectedIndex];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
		
	self.selectedIndex = indexPath;
	
	[dict writeToFile:VENUE atomically:YES];
	[dict release];
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *MyIdentifier = @"cell";

    UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
        	reuseIdentifier:MyIdentifier] autorelease];
    }
    
    if (items.count > 0) {
    	cell.accessoryType = UITableViewCellAccessoryNone;
    	cell.textLabel.text = [[items objectForKey:@"names"] objectAtIndex:indexPath.row];
    	int feet = [[[items objectForKey:@"distance"] objectAtIndex:indexPath.row] doubleValue] * 3.2808399;
    	cell.detailTextLabel.text = [NSString stringWithFormat:@"%i ft",feet];
    
    	NSDictionary *dict = [[[NSDictionary alloc] initWithContentsOfFile:VENUE] autorelease];

    	if ((selectedIndex && indexPath.row == selectedIndex.row) || [[dict objectForKey:@"Venue"] isEqualToString:[[items objectForKey:@"ids"] objectAtIndex:indexPath.row]]) {
    		cell.accessoryType = UITableViewCellAccessoryCheckmark;
    		foundLocationID = YES;
   		}
    	
    	if (indexPath.row == [[items objectForKey:@"names"] count] && foundLocationID) {	
    		NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:VENUE];
    		[dict setObject:@"" forKey:@"Venue"];
    	}
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[items objectForKey:@"names"] count];
}

- (void)startSpinner {
	act = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	act.center = wrapperView.center;
	[act setHidesWhenStopped:YES];
	[act startAnimating];
	[wrapperView addSubview:act];
	[act release];
}

- (void)locationButtonTappedOnWithLocation:(CLLocation*)loc {
	
	if (![Foursquare2 isNeedToAuthorize]) {
		[items removeAllObjects];
        [tableView reloadData];
		textView.hidden = YES;
		tableView.hidden = NO;
		
		[self startSpinner];
		self.location = loc;
		NSString *lat = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
		NSString *lon = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
		[Foursquare2 searchVenuesNearByLatitude:lat longitude:lon accuracyLL:nil altitude:nil 
				accuracyAlt:nil query:nil limit:@"1000" intent:@"checkin" callback:^(BOOL success, id result) {
				items = [self venueNames:(NSDictionary*)result];
				[tableView reloadData];
				if (act) [act stopAnimating];
		}];
	}
	else {
		textView.text = @"You must authenticate Foursquare before you can get nearby locations.";
		tableView.hidden = YES;
		textView.hidden = NO;
	}
}

- (void)locationButtonTappedOff {

	if (act) [act stopAnimating];

	NSMutableDictionary *dict;
	if ([[NSFileManager defaultManager] fileExistsAtPath:VENUE])
		dict = [[NSMutableDictionary alloc] initWithContentsOfFile:VENUE];
	else
		dict = [[NSMutableDictionary alloc] init];
	[dict setObject:@"" forKey:@"Venue"];
	[dict writeToFile:VENUE atomically:YES];

	location = nil;
	textView.text = @"No location...";
	tableView.hidden = YES;
	textView.hidden = NO;
}

- (void)viewUpdatedWithFrame:(CGRect)frame {
	textView.frame = frame;
	tableView.frame = frame;
}

- (BOOL)shouldAppearBeforePost {
    
	if (!location) return NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:VENUE]) return YES;
	
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:VENUE];	
	
	if ([[dict objectForKey:@"Venue"] isEqualToString:@""])
		return YES;
	else 
		return NO;
}

- (id)view {
	return wrapperView;
}

- (void)dealloc {
	if (items) [items release];
	if (wrapperView) [wrapperView release];
	if (data) [data release];
	if (location) [location release];
	if (selectedIndex) [selectedIndex release];
	if (delegate) [delegate release];
	
	[super dealloc];
}


@end
