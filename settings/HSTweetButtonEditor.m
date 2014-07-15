#import "HSTweetButtonEditor.h"

@implementation HSTweetButtonEditor

- (id)initForContentSize:(CGSize)size {
	return [self init];
}

- (id)init {
	if ((self = [super init])) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setNavigationTitle:(NSString *)navigationTitle {
	if ([self respondsToSelector:@selector(navigationItem)]) { 
		[[self navigationItem] setTitle:navigationTitle]; 
	}
}

- (NSString *)navigationTitle {
	return @"Tweet Button Editor";
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
	if (userApps.count > 0) return 3;
    else return 2;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 1;
    else if (section == 1) return systemApps.count;
    else if (section == 2) return userApps.count;
    return 0;
}

- (id)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section {
    if (section == 0) return @"This feature allows you to change the title of 'Tweet' buttons to whatever you like (Example: Tweet to Share)\n\nNote: this feature is advanced, PROCEDE WITH CAUTION. This feature will only work with apps that support localized strings.\n\nYou can read a tutorial on how to change app strings here.";
    else if (section == 1) return @"System Apps";
    else if (section == 2) return @"User Apps";
    return @"";
}

- (id)view {
	return _table;
}

- (void)setSpecifier:(PSSpecifier *)specifier {
	[self loadFromSpecifier:specifier];
	[super setSpecifier:specifier];
}

- (void)filterApps {
    NSArray *items = [NSArray arrayWithObjects:@"AdSheet.app",@"DemoApp.app",@"FieldTest.app",@"Setup.app",@"TrustMe.app",@"Utilities",@"Web.app"
                      @"WebSheet.app",@"iOS Diagnostics.app",nil];
    for (NSString *item in items)
        if ([systemApps containsObject:item]) [systemApps removeObject:item];
}

- (void)loadFromSpecifier:(PSSpecifier *)specifier {
	[self setNavigationTitle:[self navigationTitle]];
    
	_table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height - 65.0f) style:UITableViewStyleGrouped];
	[_table setDelegate:self];
	[_table setDataSource:self];
	[_table setAllowsSelectionDuringEditing:YES];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"/Applications" forKey:@"path"];
    NSDictionary *dict2 = [NSDictionary dictionaryWithObject:@"/User/Applications" forKey:@"path"];    
    CPDistributedMessagingCenter *center = [CPDistributedMessagingCenter centerNamed:@"com.homeschooldev.fusiond"];
    NSDictionary *returnData = [center sendMessageAndReceiveReplyName:@"contentsOfPath" userInfo:dict];
    systemApps = [[NSMutableArray alloc] initWithArray:[returnData objectForKey:@"contents"]];
    [systemApps addObject:@"Photos.app"];
    [systemApps sortUsingSelector:@selector(compare:)];
    NSDictionary *returnData2 = [center sendMessageAndReceiveReplyName:@"contentsOfPath" userInfo:dict2];
    userApps = [[NSMutableArray alloc] initWithArray:[returnData2 objectForKey:@"contents"]];
    
    for (NSUInteger i = 0; i < userApps.count; i++) {
        //get contents of each user app...
        NSDictionary *request = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"/User/Applications/%@",[userApps objectAtIndex:i]] forKey:@"path"];
        CPDistributedMessagingCenter *center = [CPDistributedMessagingCenter centerNamed:@"com.homeschooldev.fusiond"];
        NSDictionary *returnData = [center sendMessageAndReceiveReplyName:@"contentsOfPath" userInfo:request];
        NSArray *contents = [returnData objectForKey:@"contents"];
        NSString *appName = nil;
        for (NSString *path in contents) {
            if ([path rangeOfString:@".app"].location != NSNotFound)
                appName = path;
        }
        NSString *newPath = [NSString stringWithFormat:@"%@/%@",[userApps objectAtIndex:i],appName];
        [userApps replaceObjectAtIndex:i withObject:newPath];
    }
    
    [self filterApps];
    
	[_table reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!c) {
		c = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
	}
	
    c.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 0)
        c.textLabel.text = @"Tutorial";
    else if (indexPath.section == 1)
        c.textLabel.text = [[systemApps objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@".app" withString:@""];
    else if (indexPath.section == 2) {
        NSRange range = [[userApps objectAtIndex:indexPath.row] rangeOfString:@"/"];
        NSString *new = [[userApps objectAtIndex:indexPath.row] substringFromIndex:range.location + 1];
        c.textLabel.text = [new stringByReplacingOccurrencesOfString:@".app" withString:@""];
    }
    
	return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        HSWebViewer *viewer = [[HSWebViewer alloc] initWithTitle:@"Tutorial" andURL:[NSURL URLWithString:@"http://www.homeschooldev.com/index_files/f8379cdcfdf66b7e38cbca7317f78587-8.php"]];
        [viewer setSpecifier:nil];
        [[self navigationController] pushViewController:(UIViewController *)viewer animated:YES];
        [viewer release];
    }
    else {
        NSString *p = nil;
        if (indexPath.section == 1) {
            if ([[systemApps objectAtIndex:indexPath.row] isEqualToString:@"Photos.app"]) 
                p = [NSString stringWithFormat:@"/System/Library/PrivateFrameworks/PhotoLibrary.framework"];
            else
                p = [NSString stringWithFormat:@"/Applications/%@",[systemApps objectAtIndex:indexPath.row]];
        }
        else if (indexPath.section == 2)
            p = [NSString stringWithFormat:@"/User/Applications/%@",[userApps objectAtIndex:indexPath.row]];
    
        HSTweetButtonLocation *controller = [[HSTweetButtonLocation alloc] initWithPath:p];
        [controller setSpecifier:nil];
        [[self navigationController] pushViewController:(UIViewController *)controller animated:YES];
        [controller release];
    }
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

-(void)dealloc {
    [_table release];
    [userApps release];
    [systemApps release];
	[super dealloc];
}

@end
