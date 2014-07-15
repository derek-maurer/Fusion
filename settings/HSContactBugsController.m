#import "HSContactBugsController.h"

@implementation HSContactBugsController
@synthesize newBug;

- (void)setNavigationTitle:(NSString *)navigationTitle {
	if ([self respondsToSelector:@selector(navigationItem)]) { 
		[[self navigationItem] setTitle:navigationTitle]; 
	}
}

- (id)view {
	return _table;
}

- (void)viewWillAppear:(BOOL)animated {
	[self setNavigationTitle:@"Bugs"];
    
	_table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height - 65.0f) style:UITableViewStyleGrouped];
	[_table setDelegate:self];
	[_table setDataSource:self];
    
    if (!bugs) {
        //Only show the spinner the first time the view is loaded.
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        activityIndicator.center = self.view.center;
        activityIndicator.hidesWhenStopped = YES;
        [activityIndicator startAnimating];
        [_table addSubview:activityIndicator];
        [activityIndicator release];
    }
    
	[self performSelectorInBackground:@selector(getBugs) withObject:nil];
    
    [super viewWillAppear:animated];
}

- (void)getBugs {
    bugsLoaded = NO;

    NSString *urlString = [NSString stringWithFormat:@"http://www.homeschooldev.com/bugs/bugs.php?function=getBugs&package=com.homeschooldev.fusion&udid=%@",[[UIDevice currentDevice] uniqueIdentifier]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSError *error = nil;
    NSData *connectionData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (!error) {
        NSString *response = [[[NSString alloc] initWithData:connectionData encoding:NSASCIIStringEncoding] autorelease];
        if (![response isEqualToString:@"file didn't exist"]) {
            bugs = [[self parseXML:connectionData] retain];
        }
        else {
            bugs = [[NSMutableArray alloc] init];
        }
    }
    
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
    if ([prefs objectForKey:@"NewBug"]) {
        //A bug existed in the preferences file.
        BOOL found = NO;
        if (bugs.count > 0) {
            for (NSUInteger i = 0; i < bugs.count; i++) {
                NSDictionary *bug = [bugs objectAtIndex:i];
                if ([[bug objectForKey:@"ID"] isEqualToString:[[prefs objectForKey:@"NewBug"] objectForKey:@"ID"]])
                    found = YES;
                if (i == bugs.count - 1 && !found)
                    [bugs addObject:[prefs objectForKey:@"NewBug"]];
                else if (i == bugs.count - 1 && found) {
                    [prefs removeObjectForKey:@"NewBug"];
                    [prefs writeToFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist" atomically:YES];
                }
            }
        }
        else {
            [bugs addObject:[prefs objectForKey:@"NewBug"]];
        }
    }
    
    bugsLoaded = YES;

    [_table reloadData];
    [activityIndicator stopAnimating];
}

- (NSArray*)parseXML:(NSData*)data {
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
    NSString *pTweleve = [pEleven stringByReplacingOccurrencesOfString:@"<Reporters>" withString:@"<key>Reporters</key><array>"];
    NSString *pTeen = [pTweleve stringByReplacingOccurrencesOfString:@"</Reporters>" withString:@"</array>"];
    NSString *pFourteen = [pTeen stringByReplacingOccurrencesOfString:@"<Reporter>" withString:@"<string>"];
    NSString *final = [pFourteen stringByReplacingOccurrencesOfString:@"</Reporter>" withString:@"</string>"];
    
    NSData* plistData = [final dataUsingEncoding:NSUTF8StringEncoding];
    NSString *error;
    NSPropertyListFormat format;
    NSArray* plist = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];
   
    if (!error) return plist; //Nothing went wrong. Bugs existed.
    else return [[[NSMutableArray alloc] init] autorelease]; //Something went wrong.
}

- (id)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section {
    if (section == 0 && bugs.count > 0) return @"Here is a list of bugs that are known and are being worked on. If you don't see your issue here tap 'Report new bug' at the bottom of the list. If your issue appears here, be assured that it's being resolved. Also, if your issue is here please tap it and click 'I suffer from this too' so that I will know which bugs are more important.";
	return @"";
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!c) {
		c = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
	}
	
    if (indexPath.section == 0) {
        c.textLabel.text = [[[bugs objectAtIndex:indexPath.row] objectForKey:@"ShortDescription"] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    }
    else if (indexPath.section == 1) {
        c.textLabel.text = @"Report new bug";
    }
    
	c.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        //Bugs existed
        HSContactBugDetail *creator = [[HSContactBugDetail alloc] init];
        creator.bug = [bugs objectAtIndex:indexPath.row];
        [[self navigationController] pushViewController:creator animated:YES];
        [creator release];
    }
    else if (indexPath.section == 1) {
        //Bugs existed, but create was tapped
        HSContactBugDetail *creator = [[HSContactBugDetail alloc] init];
        creator.addingNew = YES;
        [[self navigationController] pushViewController:creator animated:YES];
        [creator release];
    }
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!bugsLoaded) return 0; //Show nothing since the fetch hasn't finished
    else return 2;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(int)section {
    if (section == 0) return bugs.count;
    else return 1;
}

- (void)dealloc {
    [_table release];
    if (bugs) {
        [bugs release];
        bugs = nil;
    }
    if (newBug) {
        [newBug release];
        newBug = nil;
    }
	[super dealloc];
}

@end
