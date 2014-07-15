#import "HSPhotoUploadsController.h"

@implementation HSPhotoUploadsController

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

- (id)view {
	return _table;
}

- (void)setSpecifier:(PSSpecifier *)specifier {
	[self loadFromSpecifier:specifier];
	[super setSpecifier:specifier];
}

- (void)loadFromSpecifier:(PSSpecifier *)specifier {
    
	[self setNavigationTitle:@"Photo Uploads"];
	_table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height - 65.0f) style:UITableViewStyleGrouped];
	[_table setDelegate:self];
	[_table setDataSource:self];
	[_table setAllowsSelectionDuringEditing:YES];
    
    images = [[NSMutableArray alloc] initWithObjects:@"flickr.png",@"HQPhotos.png",nil];
    controllers = [[NSMutableArray alloc] initWithObjects:@"Flickr",nil];
    switches = [[NSMutableArray alloc] initWithObjects:@"HQ Photo Uploads",nil];
    switchKeys = [[NSMutableArray alloc] initWithObjects:@"HDPhotos",nil];
    
	[_table reloadData];
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0)
    	return controllers.count;
    else 
    	return switches.count;
}

- (id)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section {
    if (section == 0) return @"Using Flickr in Fusion will automatically upload all your photos there rather than passing the photos to each of the networks to upload themselves. Each of the networks will then receieve a link to the image, rather than the image itself. Doing this makes the post significantly faster if you are posting pictures to multiple networks.";
    return @"";
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	
	if (indexPath.section == 0) {
		if (!c) {
			c = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
		}
    	c.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        NSRange period = [[images objectAtIndex:indexPath.row] rangeOfString:@"."];
        NSString *fileType = [[images objectAtIndex:indexPath.row] substringFromIndex:period.location];
        NSString *fileName = [[images objectAtIndex:indexPath.row] substringToIndex:period.location];
        NSString *pathToRetinaImage = [NSString stringWithFormat:@"%@@2x%@",fileName,fileType];
        
        UIImage *cellImage;
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00 &&
            [[NSFileManager defaultManager] fileExistsAtPath:pathToRetinaImage]) {
            //Device is retina and retina image is available
            cellImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/Library/PreferenceBundles/FusionSettings.bundle/%@",pathToRetinaImage]];
        }
        else {
            //Device is not retina or retina image was not available
            cellImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/Library/PreferenceBundles/FusionSettings.bundle/%@",[images objectAtIndex:indexPath.row]]];
        }
        
        c.imageView.image = cellImage;
    	c.textLabel.text = [controllers objectAtIndex:indexPath.row];
    }
    else {
    	if (!c) {
			c = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
			HSSwitch *switchview = [[HSSwitch alloc] initWithFrame:CGRectZero];
			NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
			if ([prefs objectForKey:[switchKeys objectAtIndex:indexPath.row]])
				[switchview setOn:[[prefs objectForKey:[switchKeys objectAtIndex:indexPath.row]] boolValue] animated:NO];
			[switchview setIndexPath:indexPath];
			[switchview addTarget:self action:@selector(updateSwitchAtIndexPath:) forControlEvents:UIControlEventValueChanged];
    		c.accessoryView = switchview;
    		c.selectionStyle = UITableViewCellSelectionStyleNone;
    		[switchview release];
		}
        int index = indexPath.row + controllers.count;
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
		c.tag = indexPath.row;
    	c.textLabel.text = [switches objectAtIndex:indexPath.row];
    }
    
	return c;
}

- (void)updateSwitchAtIndexPath:(HSSwitch *)sw {
	UITableViewCell *cell = [_table cellForRowAtIndexPath:[sw indexPath]];
	HSSwitch *switchView = (HSSwitch *)cell.accessoryView;
	
	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];

	if ([switchView isOn]) {
   		[prefs setObject:[NSNumber numberWithBool:YES] forKey:[switchKeys objectAtIndex:[[sw indexPath] row]]];
	} 
	else {
    	[prefs setObject:[NSNumber numberWithBool:NO] forKey:[switchKeys objectAtIndex:[[sw indexPath ]row]]];
	}
	[prefs writeToFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist" atomically:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        HSFlickrActivation *flickr = [[HSFlickrActivation alloc] init];
        [flickr setSpecifier:nil];
        [[self navigationController] pushViewController:flickr animated:YES];
        [flickr release];
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
	[controllers release];
    [switchKeys release];
	[switches release];
	[super dealloc];
}

@end
