#import "HSTweetButtonLocationFiles.h"

@implementation HSTweetButtonLocationFiles

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
	return @"String Files";
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
    files = [[NSMutableArray alloc] initWithArray:contents];
    
    for (NSString *file in files) {
        if ([file rangeOfString:@"%"].location != NSNotFound)
            [files removeObject:file];
    }
	
	[_table reloadData];
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return files.count;
}

- (id)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section {
    if (files.count <= 0) return @"There are no localized strings for this application. This feature will not work for this app.";
    else return @"";
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!c) {
		c = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
	}
	
    c.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    c.textLabel.text = [files objectAtIndex:indexPath.row];
 
	return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *p = [NSString stringWithFormat:@"%@/%@",path,[files objectAtIndex:indexPath.row]];
    HSTweetButtonLocationEditor *editor = [[HSTweetButtonLocationEditor alloc] initWithPath:p];
    [editor setSpecifier:nil];
    [[self navigationController] pushViewController:(UIViewController *)editor animated:YES];
    [editor release];
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
	[files release];
	[super dealloc];
}

@end
