#import "HSFusionInfo.h"

@implementation HSFusionInfo

- (id) initForContentSize:(CGSize)size {
	return [self init];
}

- (id)init {
	self = [super init];
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
	return @"Info";
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
    
    images = [[NSMutableArray alloc] initWithObjects:@"followme.png",@"legal.png",nil];
    firstControllers = [[NSMutableArray alloc] initWithObjects:@"Follow Maximus",nil];
    secondControllers = [[NSMutableArray alloc] initWithObjects:@"Legal",nil];
	
	[_table reloadData];
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return firstControllers.count;
    else if (section == 1) return secondControllers.count;
    return 0;
}

- (id)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section {
    if (section == 0) return @"Maximus helped a lot on this project, help him out, follow him on Twitter (He's not the developer)";
    else if (section == 2) return @"Hint: You can double tap a social network icon to show its view";
    return @"";
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!c) {
		c = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
	}
    
    int index;
    if (indexPath.section == 0) {
        c.textLabel.text = [firstControllers objectAtIndex:indexPath.row];
        index = indexPath.row;
    }
    else if (indexPath.section == 1) {
        c.textLabel.text = [secondControllers objectAtIndex:indexPath.row];
        index = indexPath.row + firstControllers.count;
    }
        
    NSRange period = [[images objectAtIndex:index] rangeOfString:@"."];
    NSString *fileType = [[images objectAtIndex:index] substringFromIndex:period.location];
    NSString *fileName = [[images objectAtIndex:index] substringToIndex:period.location];
    NSString *pathToRetinaImage = [NSString stringWithFormat:@"%@@2x%@",fileName,fileType];
    
    UIImage *cellImage;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00 &&
        [[NSFileManager defaultManager] fileExistsAtPath:pathToRetinaImage]) {
        //Device is retina and retina image is available
        cellImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/Library/PreferenceBundles/FusionSettings.bundle/%@",pathToRetinaImage]];
    }
    else {
        //Device is not retina or retina image was not available
        cellImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/Library/PreferenceBundles/FusionSettings.bundle/%@",[images objectAtIndex:index]]];
    }
        
    c.imageView.image = cellImage;
    c.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if ([[firstControllers objectAtIndex:indexPath.row] isEqualToString:@"Follow Maximus"]) {
            NSString *URL = @"twitter://user?screen_name=0_maximus_0";
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:URL]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL]];
            }
            else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.twitter.com/0_maximus_0"]];
            }
        }
    }
    else {
        if ([[secondControllers objectAtIndex:indexPath.row] isEqualToString:@"Legal"]) {
            HSFusionLegal *legal = [[HSFusionLegal alloc] init];
            [legal setSpecifier:nil];
            [[self navigationController] pushViewController:(UIViewController *)legal animated:YES];
            [legal release];
        }
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
    [images release];
	[firstControllers release];
    [secondControllers release];
	[super dealloc];
}

@end
