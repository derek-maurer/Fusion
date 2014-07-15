#import "HSSoundSettings.h"

static NSString *ringtonesPath = @"/Library/Ringtones";
static NSString *UISounds = @"/System/Library/Audio/UISounds";
static NSString *newSound = @"/System/Library/Audio/UISounds/New";
static NSString *prefs = @"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist";

@implementation HSSoundSettings
@synthesize selectedIndex;

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
	return @"Sounds";
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
    
    sounds = [[NSMutableArray alloc] init];
    [sounds addObjectsFromArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:UISounds error:nil]];
    [sounds removeObject:@"New"];
    [sounds addObjectsFromArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:newSound error:nil]];
    ringtones = [[NSMutableArray alloc] init];
    [ringtones addObjectsFromArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:ringtonesPath error:nil]];
	
	[_table reloadData];
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) return 1;
    else if (section == 1) return sounds.count;
    else if (section == 2) return ringtones.count;
    return 0;
}

- (id)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section {
    if (section == 0) return @"Choose a ringtone that will be played when the post finishes";
    else if (section == 1) return @"Sounds";
    else if (section == 2) return @"Ringtones";
    return @"";
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *prefsDict = [NSDictionary dictionaryWithContentsOfFile:prefs];
    
	UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!c) {
		c = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
	}
    
    c.accessoryType = UITableViewCellAccessoryNone;
    
    if (self.selectedIndex && self.selectedIndex.row == indexPath.row && selectedIndex.section == indexPath.section) {
        c.accessoryType = UITableViewCellAccessoryCheckmark;
    }
	
    if (indexPath.section == 1) {
        NSString *uiPath = [NSString stringWithFormat:@"%@/%@",UISounds,[sounds objectAtIndex:indexPath.row]];
        NSString *newPath = [NSString stringWithFormat:@"%@/%@",newSound,[sounds objectAtIndex:indexPath.row]];
        if ([[prefsDict objectForKey:@"Sound"] isEqualToString:uiPath] || [[prefsDict objectForKey:@"Sound"] isEqualToString:newPath]) {
            c.accessoryType = UITableViewCellAccessoryCheckmark;
            self.selectedIndex = indexPath;
        }
        
        NSRange range = [[sounds objectAtIndex:indexPath.row] rangeOfString:@"."];
        if (range.location != NSNotFound) {
            NSString *label = [[sounds objectAtIndex:indexPath.row] substringToIndex:range.location];
            c.textLabel.text = label;
        }
        else {
            c.textLabel.text = [sounds objectAtIndex:indexPath.row];
        }
    }
    else if (indexPath.section == 2) {
        NSString *path = [NSString stringWithFormat:@"%@/%@",ringtonesPath,[ringtones objectAtIndex:indexPath.row]];
        if ([[prefsDict objectForKey:@"Sound"] isEqualToString:path]) {
            c.accessoryType = UITableViewCellAccessoryCheckmark;
            self.selectedIndex = indexPath;
        }
        
        NSRange range = [[ringtones objectAtIndex:indexPath.row] rangeOfString:@"."];
        if (range.location != NSNotFound) {
            NSString *label = [[ringtones objectAtIndex:indexPath.row] substringToIndex:range.location];
            c.textLabel.text = label;
        }
        else {
            c.textLabel.text = [ringtones objectAtIndex:indexPath.row];
        }
    }
    else if (indexPath.section == 0) {
    	if ([[prefsDict objectForKey:@"Sound"] isEqualToString:@"NoSound"]) {
            c.accessoryType = UITableViewCellAccessoryCheckmark;
            self.selectedIndex = indexPath;
        }
    	c.textLabel.text = @"No Sound";
    }
    
	return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.selectedIndex) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:selectedIndex];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    self.selectedIndex = indexPath;
    
    if (indexPath.section == 1) {
        //UI sounds
        NSString *uiPath = [NSString stringWithFormat:@"%@/%@",UISounds,[sounds objectAtIndex:indexPath.row]];
        NSString *newPath = [NSString stringWithFormat:@"%@/%@",newSound,[sounds objectAtIndex:indexPath.row]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:uiPath]) {
            NSURL *toneURLRef = [NSURL URLWithString:uiPath];
            SystemSoundID toneSSID = 0;
            AudioServicesCreateSystemSoundID((CFURLRef) toneURLRef,&toneSSID);
            AudioServicesPlaySystemSound(toneSSID);
            
            //write sound choice to file
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            NSMutableDictionary *prefsDict;
            if ([[NSFileManager defaultManager] fileExistsAtPath:prefs])
                prefsDict = [NSMutableDictionary dictionaryWithContentsOfFile:prefs];
            else 
                prefsDict = [NSMutableDictionary dictionary];
            [prefsDict setObject:uiPath forKey:@"Sound"];
            [prefsDict writeToFile:prefs atomically:YES];
        }
        else {
            NSURL *toneURLRef = [NSURL URLWithString:newPath];
            SystemSoundID toneSSID = 0;
            AudioServicesCreateSystemSoundID((CFURLRef) toneURLRef,&toneSSID);
            AudioServicesPlaySystemSound(toneSSID);
            
            //write sound choice to file
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            NSMutableDictionary *prefsDict;
            if ([[NSFileManager defaultManager] fileExistsAtPath:prefs])
                prefsDict = [NSMutableDictionary dictionaryWithContentsOfFile:prefs];
            else 
                prefsDict = [NSMutableDictionary dictionary];
            [prefsDict setObject:newPath forKey:@"Sound"];
            [prefsDict writeToFile:prefs atomically:YES];
        }
    }
    else if (indexPath.section == 2) {
        //Ringtones
        NSString *path = [NSString stringWithFormat:@"%@/%@",ringtonesPath,[ringtones objectAtIndex:indexPath.row]];
        NSURL *toneURLRef = [NSURL URLWithString:path];
        SystemSoundID toneSSID = 0;
        AudioServicesCreateSystemSoundID((CFURLRef) toneURLRef,&toneSSID);
        AudioServicesPlaySystemSound(toneSSID);
        
        //write sound choice to file
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        NSMutableDictionary *prefsDict;
        if ([[NSFileManager defaultManager] fileExistsAtPath:prefs])
            prefsDict = [NSMutableDictionary dictionaryWithContentsOfFile:prefs];
        else 
            prefsDict = [NSMutableDictionary dictionary];
        [prefsDict setObject:path forKey:@"Sound"];
        [prefsDict writeToFile:prefs atomically:YES];
    }
    else if (indexPath.section == 0) {
    	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    	NSMutableDictionary *prefsDict;
        if ([[NSFileManager defaultManager] fileExistsAtPath:prefs])
            prefsDict = [NSMutableDictionary dictionaryWithContentsOfFile:prefs];
        else 
            prefsDict = [NSMutableDictionary dictionary];
        [prefsDict setObject:@"NoSound" forKey:@"Sound"];
        [prefsDict writeToFile:prefs atomically:YES];
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
	[sounds release];
    [ringtones release];
	[super dealloc];
}

@end
