#import "HSTweetButtonLocation.h"

@implementation HSTweetButtonLocation

- (id) initForContentSize:(CGSize)size {
	return [self init];
}

- (id)initWithPath:(NSString *)p {
	if ((self = [super init])) {
        path = [p retain];
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
	return @"Locations";
}

- (id)view {
	return _table;
}

- (void)setSpecifier:(PSSpecifier *)specifier {
	[self loadFromSpecifier:specifier];
	[super setSpecifier:specifier];
}

- (void)loadFromSpecifier:(PSSpecifier *)specifier {
    
	[self setNavigationTitle:[self navigationTitle]];
	_table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height - 65.0f) style:UITableViewStyleGrouped];
	[_table setDelegate:self];
	[_table setDataSource:self];
	[_table setAllowsSelectionDuringEditing:YES];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:path forKey:@"path"];
    CPDistributedMessagingCenter *center = [CPDistributedMessagingCenter centerNamed:@"com.homeschooldev.fusiond"];
    NSDictionary *returnData = [center sendMessageAndReceiveReplyName:@"contentsOfPath" userInfo:dict];    
    NSArray *contents = [returnData objectForKey:@"contents"];
    locations = [[NSMutableArray alloc] init];
    for (NSString *p in contents) {
        if ([p rangeOfString:@".lproj"].location != NSNotFound)
            [locations addObject:p];
    }
	
	[_table reloadData];
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return locations.count;
}

- (id)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section {
    if (locations.count <= 0) return @"There are no localized strings for this application. This feature will not work for this app.";
    else return @"";
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!c) {
		c = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
	}
	
    c.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    c.textLabel.text = [[locations objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@".lproj" withString:@""];
 
	return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *p = [NSString stringWithFormat:@"%@/%@",path,[locations objectAtIndex:indexPath.row]];
    HSTweetButtonLocationFiles *files = [[HSTweetButtonLocationFiles alloc] initWithPath:p];
    [files setSpecifier:nil];
    [[self navigationController] pushViewController:(UIViewController*)files animated:YES];
    [files release];
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
    [path release];
	[locations release];
	[super dealloc];
}

@end
