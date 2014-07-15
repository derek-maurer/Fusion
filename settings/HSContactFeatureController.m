#import "HSContactFeatureController.h"

@implementation HSContactFeatureController
@synthesize newFeature;

- (void)setNavigationTitle:(NSString *)navigationTitle {
	if ([self respondsToSelector:@selector(navigationItem)]) { 
		[[self navigationItem] setTitle:navigationTitle]; 
	}
}

- (id)view {
	return _table;
}

- (void)viewWillAppear:(BOOL)animated {
	[self setNavigationTitle:@"Features"];
    
	_table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height - 65.0f) style:UITableViewStyleGrouped];
	[_table setDelegate:self];
	[_table setDataSource:self];
    
    if (!features) {
        //Only show the spinner the first time the view is loaded.
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        activityIndicator.center = self.view.center;
        activityIndicator.hidesWhenStopped = YES;
        [activityIndicator startAnimating];
        [_table addSubview:activityIndicator];
        [activityIndicator release];
    }
    
	[self performSelectorInBackground:@selector(getFeatures) withObject:nil];
    
    [super viewWillAppear:animated];
}

- (void)getFeatures {
    featuresLoaded = NO;

    NSString *urlString = [NSString stringWithFormat:@"http://www.homeschooldev.com/features/features.php?function=getFeatures&package=com.homeschooldev.fusion&udid=%@",[[UIDevice currentDevice] uniqueIdentifier]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSError *error = nil;
    NSData *connectionData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (!error) {
        NSString *response = [[[NSString alloc] initWithData:connectionData encoding:NSASCIIStringEncoding] autorelease];
        if (![response isEqualToString:@"file didn't exist"]) {
            features = [[self parseXML:connectionData] retain];
        }
        else
            features = [[NSMutableArray alloc] init];
    }
    else
        features = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
    if ([prefs objectForKey:@"NewFeature"]) {
        //A feature existed in the preferences file.
        BOOL found = NO;
        if (features.count > 0) {
            for (NSUInteger i = 0; i < features.count; i++) {
                NSDictionary *feature = [features objectAtIndex:i];
                if ([[feature objectForKey:@"ID"] isEqualToString:[[prefs objectForKey:@"NewFeature"] objectForKey:@"ID"]])
                    found = YES;
                if (i == features.count - 1 && !found)
                    [features addObject:[prefs objectForKey:@"NewFeature"]];
                else if (i == features.count - 1 && found) {
                    [prefs removeObjectForKey:@"NewFeature"];
                    [prefs writeToFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist" atomically:YES];
                }
            }
        }
        else {
            [features addObject:[prefs objectForKey:@"NewFeature"]];
        }
    }
    
    featuresLoaded = YES;

    [_table reloadData];
    [activityIndicator stopAnimating];
}

- (NSMutableArray*)parseXML:(NSData*)data {
    NSString *response = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
    NSString *pOne = [response stringByReplacingOccurrencesOfString:@"<?xml version=\"1.0\"?>" withString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">"];
    NSString *pTwo = [pOne stringByReplacingOccurrencesOfString:@"<xml>" withString:@"<plist version=\"1.0\">"];
    NSString *pThree = [pTwo stringByReplacingOccurrencesOfString:@"</xml>" withString:@"</plist>"];
    NSString *pFour = [pThree stringByReplacingOccurrencesOfString:@"<ID>" withString:@"<key>ID</key><string>"];
    NSString *pFive = [pFour stringByReplacingOccurrencesOfString:@"</ID>" withString:@"</string>"];
    NSString *pSix = [pFive stringByReplacingOccurrencesOfString:@"<ShortDescription>" withString:@"<key>ShortDescription</key><string>"];
    NSString *pSeven = [pSix stringByReplacingOccurrencesOfString:@"</ShortDescription>" withString:@"</string>"];
    NSString *pEight = [pSeven stringByReplacingOccurrencesOfString:@"<LongDescription>" withString:@"<key>LongDescription</key><string>"];
    NSString *pNine = [pEight stringByReplacingOccurrencesOfString:@"</LongDescription>" withString:@"</string>"];
    NSString *pTen = [pNine stringByReplacingOccurrencesOfString:@"<UDIDOfReporter>" withString:@"<key>UDIDOfReporter</key><string>"];
    NSString *pEleven = [pTen stringByReplacingOccurrencesOfString:@"</UDIDOfReporter>" withString:@"</string>"];
    NSString *pTweleve = [pEleven stringByReplacingOccurrencesOfString:@"<Requesters>" withString:@"<key>Requesters</key><array>"];
    NSString *pTeen = [pTweleve stringByReplacingOccurrencesOfString:@"</Requesters>" withString:@"</array>"];
    NSString *pFourteen = [pTeen stringByReplacingOccurrencesOfString:@"<Requester>" withString:@"<string>"];
    NSString *final = [pFourteen stringByReplacingOccurrencesOfString:@"</Requester>" withString:@"</string>"];
    
    NSData* plistData = [final dataUsingEncoding:NSUTF8StringEncoding];
    NSString *error;
    NSPropertyListFormat format;
    NSMutableArray* plist = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];
    
    if (!error) return plist; //Nothing went wrong. features existed.
    else return [[[NSMutableArray alloc] init] autorelease]; //Something went wrong.
}

- (id)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section {
    if (section == 0 && features.count > 0) return @"Here is a list of features that have already been requested. If you don't see the feature here that you would like to see in Fusion then tap the 'Request new feature button'";
	return @"";
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!c) {
		c = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
	}
	
    if (indexPath.section == 0) {
        c.textLabel.text = [[[features objectAtIndex:indexPath.row] objectForKey:@"ShortDescription"] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    }
    else if (indexPath.section == 1) {
        c.textLabel.text = @"Request new feature";
    }
    
	c.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        //features existed
        HSContactFeatureDetail *creator = [[HSContactFeatureDetail alloc] init];
        creator.feature = [features objectAtIndex:indexPath.row];
        [[self navigationController] pushViewController:creator animated:YES];
        [creator release];
    }
    else if (indexPath.section == 1) {
        //features existed, but create was tapped
        HSContactFeatureDetail *creator = [[HSContactFeatureDetail alloc] init];
        creator.addingNew = YES;
        [[self navigationController] pushViewController:creator animated:YES];
        [creator release];
    }
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!featuresLoaded) return 0; //Show nothing since the fetch hasn't finished
    else return 2;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(int)section {
    if (section == 0) return features.count;
    else return 1;
}

- (void)dealloc {
    [_table release];
    if (features) {
        [features release];
        features = nil;
    }
    if (newFeature) {
        [newFeature release];
        newFeature = nil;
    }
	[super dealloc];
}

@end
