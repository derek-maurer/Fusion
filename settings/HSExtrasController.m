#import "HSExtrasController.h"

@implementation HSExtrasController

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
	return @"Extras";
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
    
    images = [[NSMutableArray alloc] initWithObjects:@"sounds.png",@"TweetButton.png",@"nowplaying.png",@"HQPhotos.png",@"info.png",@"TwitterKeyboard.png",nil];
    controllers = [[NSMutableArray alloc] initWithObjects:@"Sounds",@"Tweet Button Editor",@"Now Playing",@"Photo Uploads",@"Info",nil];
    switches = [[NSMutableArray alloc] initWithObjects:@"Twitter Keyboard",nil];
    switchKeys = [[NSMutableArray alloc] initWithObjects:@"TwitterKeyboard",nil];
    
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
    if (indexPath.section == 0) {
    	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    	if ([[controllers objectAtIndex:indexPath.row] isEqualToString:@"Sounds"]) {
        	HSSoundSettings *sound = [[HSSoundSettings alloc] init];
        	[sound setSpecifier:nil];
        	[[self navigationController] pushViewController:(UIViewController *)sound animated:YES];
        	[sound release];
    	}
    	else if ([[controllers objectAtIndex:indexPath.row] isEqualToString:@"Tweet Button Editor"]) {
        	HSTweetButtonEditor *editor = [[HSTweetButtonEditor alloc] init];
        	[editor setSpecifier:nil];
        	[[self navigationController] pushViewController:(UIViewController *)editor animated:YES];
        	[editor release];
    	}
    	else if ([[controllers objectAtIndex:indexPath.row] isEqualToString:@"Info"]) {
        	HSFusionInfo *info = [[HSFusionInfo alloc] init];
        	[info setSpecifier:nil];
        	[[self navigationController] pushViewController:(UIViewController *)info animated:YES];
        	[info release];
    	}
    	else if ([[controllers objectAtIndex:indexPath.row] isEqualToString:@"Now Playing"]) {
    		HSNowPlayingEditor *playing = [[HSNowPlayingEditor alloc] init];
    		[playing setSpecifier:nil];
        	[[self navigationController] pushViewController:(UIViewController *)playing animated:YES];
        	[playing release];
    	}
        else if ([[controllers objectAtIndex:indexPath.row] isEqualToString:@"Photo Uploads"]) {
            HSPhotoUploadsController *controller = [[HSPhotoUploadsController alloc] init];
            [controller setSpecifier:nil];
        	[[self navigationController] pushViewController:(UIViewController *)controller animated:YES];
        	[controller release];
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
	[controllers release];
    [switchKeys release];
	[switches release];
	[super dealloc];
}

@end
