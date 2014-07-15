#import "HSPluginSettings.h"

@implementation HSPluginSettings

- (id)initForContentSize:(CGSize)size {
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
	return @"Networks";
}

- (id)view {
	return _table;
}

- (void)editTable:(id)sender {
	[_table setEditing:YES];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(finishEditing:)];
	[[self navigationItem] setRightBarButtonItem:doneButton];
	[doneButton release];
}

- (void)finishEditing:(id)sender {
	[_table setEditing:NO];
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editTable:)];
	[[self navigationItem] setRightBarButtonItem:editButton];
	[editButton release];
}

- (void)setSpecifier:(PSSpecifier *)specifier {
	[self loadFromSpecifier:specifier];
	[super setSpecifier:specifier];
}

- (void)organizeArray {
	NSFileManager *manager = [NSFileManager defaultManager];
	
	if ([manager fileExistsAtPath:PLUGIN_ORDER]) {
		NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:PLUGIN_ORDER];
		NSMutableArray *order = [[NSMutableArray alloc] initWithArray:[plist objectForKey:@"Order"]];
		
		//Remove any plugins in the order file that don't exist on the filesystem
		NSMutableArray *objectsToRemove = [[NSMutableArray alloc] init];
		for (NSString *file in order)
			if (![manager fileExistsAtPath:file])
				[objectsToRemove addObject:file];
		if (objectsToRemove.count > 0) 
			for (NSString *remove in objectsToRemove)
				[order removeObject:remove];
		[objectsToRemove release];
				
		//Look to see if there are any plugins that don't exist in the plugin order plist yet
		NSMutableArray *notFound = [[NSMutableArray alloc] init];
		for (NSString *plugin in _plugins)
			if (![order containsObject:plugin]) 
				[notFound addObject:plugin];
		[order addObjectsFromArray:notFound];
		[notFound release];
				
		NSMutableArray *newPluginOrder = [[NSMutableArray alloc] init];
		NSMutableArray *noOrder = [[NSMutableArray alloc] init];
		for (NSString *plugin in order) {
			if ([_plugins containsObject:plugin])
				[newPluginOrder addObject:plugin];
			else 
				[noOrder addObject:plugin];
		}
		
		[_plugins removeAllObjects];
		[_plugins addObjectsFromArray:newPluginOrder];
		if (noOrder.count > 0)
			[_plugins addObjectsFromArray:noOrder];
		[newPluginOrder release];
		[noOrder release];
		
		NSDictionary *newPlist = [NSDictionary dictionaryWithObject:order forKey:@"Order"];
		[newPlist writeToFile:PLUGIN_ORDER atomically:YES];
		[order release];
	}
	else {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setObject:_plugins forKey:@"Order"];
		[dict writeToFile:PLUGIN_ORDER atomically:YES];
	}
}

- (void)loadFromSpecifier:(PSSpecifier *)specifier {
    
    [self insertSpecifiersInPlugins];
    
	[self setNavigationTitle:[self navigationTitle]];
	_table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height - 65.0f) style:UITableViewStyleGrouped];
	[_table setDelegate:self];
	[_table setDataSource:self];
	[_table setAllowsSelectionDuringEditing:YES];

	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editTable:)];
	[[self navigationItem] setRightBarButtonItem:editButton];
	[editButton release];
    
	NSArray *contents = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/Application Support/Fusion/Plugins/" error:nil] retain];
    
	_plugins = [[NSMutableArray alloc] init];
    	int count = contents.count;
	for (int i=0; i<count; i++) {
		NSString *path = [NSString stringWithFormat:@"/Library/Application Support/Fusion/Plugins/%@", [contents objectAtIndex:i]];
		[_plugins addObject:path];
	}
	[self organizeArray];
	
	[contents release];
	[_table reloadData];
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (id)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section {
	return @"";
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HSTableCell *c = (HSTableCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!c) {
		c = [[[HSTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
	}
	NSString *path = [NSString stringWithFormat:@"%@/Info.plist", [_plugins objectAtIndex:indexPath.row]];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	c.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	c.textLabel.text = [dict objectForKey:@"ServiceTitle"];
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
    ([UIScreen mainScreen].scale == 2.0)) {
        c.imageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Icon_Settings@2x.png",[_plugins objectAtIndex:indexPath.row]]];
    } 
    else {
        c.imageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Icon_Settings.png",[_plugins objectAtIndex:indexPath.row]]];
    }
    
    
	c.path = [_plugins objectAtIndex:indexPath.row];
	return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
    HSTableCell *cell = (HSTableCell *)[tableView cellForRowAtIndexPath:indexPath];
	NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Info.plist", cell.path]];
    NSBundle *prefs = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/%@.bundle",cell.path,[plist objectForKey:@"PreferenceBundleName"]]];
    Class popClass;
    if ((popClass = [prefs principalClass])) {
        id principalInstance = [[popClass alloc] init];
        [self pushController:principalInstance];
        [principalInstance release];
    }    
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(int)section {
	return [_plugins count];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSUInteger fromIndex = fromIndexPath.row;
	NSUInteger toIndex = toIndexPath.row;
	if (fromIndex == toIndex) return;
	NSString *object = [_plugins objectAtIndex:fromIndex];
	[_plugins removeObjectAtIndex:fromIndex];
	[_plugins insertObject:object atIndex:toIndex];
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
	[mutableDict setObject:_plugins forKey:@"Order"];
	[mutableDict writeToFile:PLUGIN_ORDER atomically:YES];
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)insertSpecifiersInPlugins {
    NSArray *plugins = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/Application Support/Fusion/Plugins" error:nil];
    
    for (NSString *p in plugins) {
        [self insertSpecifiersInPlugin:p];
    }
}

- (void)insertSpecifiersInPlugin:(NSString *)p {
	//Need to find the location of the specifiers and get a dictionary of them...
    NSString *ROOT_PATH = @"/Library/Application Support/Fusion";
    NSDictionary *pluginInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Plugins/%@/Info.plist",ROOT_PATH,p]];
    NSDictionary *prefsInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Plugins/%@/%@.bundle/Info.plist",ROOT_PATH,p,[pluginInfo objectForKey:@"PreferenceBundleName"]]];
    NSString *specifiersPath = [NSString stringWithFormat:@"%@/Plugins/%@/%@.bundle/%@.plist",ROOT_PATH,p,[pluginInfo objectForKey:@"PreferenceBundleName"],[prefsInfo objectForKey:@"CFBundleExecutable"]];
    NSString *defaultsPath = [prefsInfo objectForKey:@"CFBundleIdentifier"];
    NSMutableDictionary *specifiers = [[NSMutableDictionary alloc] initWithContentsOfFile:specifiersPath];
    NSMutableArray *items = [[specifiers objectForKey:@"items"] retain];
    
    //Loop through entire specifier plist
    BOOL enabledFound = NO;
    int enabledIndex = 0;
    BOOL locationFound = NO;
    int locationIndex = 0;
    BOOL selectionFound = NO;
    int selectionIndex = 0;
    
    for (NSUInteger i = 0; i < items.count; i++) {
        NSDictionary *dict = [items objectAtIndex:i];
        if ([[dict objectForKey:@"id"] isEqualToString:@"Enabled"]) {
            enabledFound = YES;
            enabledIndex = i;
        }
        else if ([[dict objectForKey:@"id"] isEqualToString:@"Location"]) {
            locationFound = YES;
            locationIndex = i;
        }
        else if ([[dict objectForKey:@"id"] isEqualToString:@"Auto Selection"]) {
            selectionFound = YES;
            selectionIndex = i;
        }
    }
    
    if (!enabledFound) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:@"PSSwitchCell" forKey:@"cell"];
        [dict setObject:[NSNumber numberWithBool:YES] forKey:@"default"];
        [dict setObject:defaultsPath forKey:@"defaults"];
        [dict setObject:@"Enabled" forKey:@"key"];
        [dict setObject:@"Enabled" forKey:@"label"];
        [dict setObject:@"Enabled" forKey:@"id"];
        [items addObject:dict];
    }
    if (!locationFound) {
        if (![p isEqualToString:@"TwitterPlugin.bundle"]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:@"PSSwitchCell" forKey:@"cell"];
            [dict setObject:[NSNumber numberWithBool:YES] forKey:@"default"];
            [dict setObject:defaultsPath forKey:@"defaults"];
            [dict setObject:@"Location" forKey:@"key"];
            [dict setObject:@"Location" forKey:@"label"];
            [dict setObject:@"Location" forKey:@"id"];
            [items addObject:dict];
        }
    }
    if (!selectionIndex) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:@"PSSwitchCell" forKey:@"cell"];
        [dict setObject:[NSNumber numberWithBool:NO] forKey:@"default"];
        [dict setObject:defaultsPath forKey:@"defaults"];
        [dict setObject:@"Auto Selection" forKey:@"key"];
        [dict setObject:@"Auto Selection" forKey:@"label"];
        [dict setObject:@"Auto Selection" forKey:@"id"];
        [items addObject:dict];
    }
    
    //Sort...
    for (NSUInteger j = 0; j < items.count; j++) {
        if ([[[items objectAtIndex:j] objectForKey:@"id"] isEqualToString:@"Auto Selection"]) {
            NSDictionary *dict = [NSDictionary dictionaryWithDictionary:[items objectAtIndex:j]];
            [items removeObjectAtIndex:j];
            [items insertObject:dict atIndex:0];
        }
    }
    for (NSUInteger j = 0; j < items.count; j++) {
        if ([[[items objectAtIndex:j] objectForKey:@"id"] isEqualToString:@"Location"]) {
            NSDictionary *dict = [NSDictionary dictionaryWithDictionary:[items objectAtIndex:j]];
            [items removeObjectAtIndex:j];
            [items insertObject:dict atIndex:0];
        }
    }
    for (NSUInteger j = 0; j < items.count; j++) {
        if ([[[items objectAtIndex:j] objectForKey:@"id"] isEqualToString:@"Enabled"]) {
            NSDictionary *dict = [NSDictionary dictionaryWithDictionary:[items objectAtIndex:j]];
            [items removeObjectAtIndex:j];
            [items insertObject:dict atIndex:0];
        }
    }
    
    NSMutableDictionary *writeDict = [NSMutableDictionary dictionary];
    [writeDict setObject:items forKey:@"items"];
    [writeDict setObject:specifiersPath forKey:@"FusionWritePath"];
    CPDistributedMessagingCenter *center = [CPDistributedMessagingCenter centerNamed:@"com.homeschooldev.fusiond"];
    [center sendMessageName:@"writeContentsToFile" userInfo:writeDict];
    
    [specifiers release]; 
    [items release];
}

- (void)dealloc {
    [_table release];
	[_plugins release];
	[super dealloc];
}

@end
