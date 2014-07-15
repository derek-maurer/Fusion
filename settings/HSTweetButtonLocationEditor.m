#import "HSTweetButtonLocationEditor.h"

@implementation HSTweetButtonLocationEditor

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
    NSDictionary *dict = [NSDictionary dictionaryWithObject:path forKey:@"path"];
    CPDistributedMessagingCenter *center = [CPDistributedMessagingCenter centerNamed:@"com.homeschooldev.fusiond"];
    info = [[center sendMessageAndReceiveReplyName:@"contentsOfFile" userInfo:dict] retain];
    keys = [[NSMutableArray alloc] initWithArray:[info allKeys]];
    [keys sortUsingSelector:@selector(compare:)];
    [_table reloadData];
    
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
	return @"Strings";
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
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([keys count] == 1 && [[keys objectAtIndex:0] isEqualToString:@"error"]) return 0;
    return [keys count];
}

- (id)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section {
    if ([keys count] <= 0) return @"No localization file found.";
    else if ([keys count] == 1 && [[keys objectAtIndex:0] isEqualToString:@"error"]) return @"No localization file found.";
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *kCellIdentifier = @"HSCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:kCellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [keys objectAtIndex:indexPath.row];;
    
    return cell;    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HSStringEditor *editor = [[HSStringEditor alloc] initWithPath:path key:[keys objectAtIndex:indexPath.row] andValue:[[info allValues] objectAtIndex:indexPath.row]];
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
    [keys release];
	[info release];
	[super dealloc];
}

@end
