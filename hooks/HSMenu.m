#import "HSMenu.h"

#define ICON_SIZE 53
#define PluginViewTag 134783240
static BOOL pluginViewsStarted = NO;
static HSPluginView *pluginView = nil;
NSString *PLUGIN_ORDER = @"/User/Library/Preferences/com.homeschooldev.FusionPluginOrder.plist";
NSString *ROOT_PATH = @"/Library/Application Support/Fusion";
NSString *Location_Path = @"/Library/Application Support/Fusion/Writeable/Location.plist";

@implementation HSMenu
@synthesize path, superFrame, sendButton,
            pluginWindowOpen, tweakDelegate, pluginViews,
            pluginSuperView;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		plugins = [[NSMutableArray alloc] init];
        buttons = [[NSMutableArray alloc] init];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.clipsToBounds = YES;
	}
	return self;
}

- (void)reload {
    if (!buttons && buttons.count) return;
    
    int cCount = 0;
    int counter = 0;
    int pages = 1;
    int iconsPerPage = 4;
    double generalGap = (self.frame.size.width - (ICON_SIZE * iconsPerPage))/(iconsPerPage + 1);
	for (HSButton *button in buttons) {
        double gap = generalGap;
        if (counter == iconsPerPage) {
            gap += generalGap;
            counter = 0;
            pages++;
        }
        [button setFrame:CGRectMake(((cCount == 0 ? 0 : (cCount* ICON_SIZE) + (generalGap * cCount))+gap), self.frame.size.height / 2 - (ICON_SIZE / 2), ICON_SIZE, ICON_SIZE)];
        
        cCount++;
        counter++;
	}
	[self setContentSize:CGSizeMake(pages * self.frame.size.width, self.frame.size.height)];
	
	if (pluginWindowOpen) {
		if (pluginView) {
        
            if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)
                //Landscape
                [self pluginViewFrameUpdated:CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.height-40,[[UIScreen mainScreen] bounds].size.width-40)];
            else
                //Portrait
                [self pluginViewFrameUpdated:CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width-40,[[UIScreen mainScreen] bounds].size.height-40)];
        
			if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)
                //Landscape
                pluginView.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.height,[[UIScreen mainScreen] bounds].size.width);
            else
                //Portrait
                pluginView.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height);
			[(HSPluginView*)pluginView reload];
		}
	}
}

- (void)load {

	pluginWindowOpen = NO;
	if (!path) path = ROOT_PATH;
	NSError *e = NULL;
    NSArray *pluginsPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&e];
    pluginsPaths = [self organizeArray:pluginsPaths];

    int cCount = 0;
    int counter = 0;
    int pages = 1;
    int iconsPerPage = 4;
    double generalGap = (self.frame.size.width - (ICON_SIZE * iconsPerPage))/(iconsPerPage + 1);
    
	for (NSString *p in pluginsPaths) {
        //Insert specifiers...
        NSDictionary *returnDict = [self insertSpecifiersInPlugin:p];
        NSArray *objects = [NSArray arrayWithObjects:[returnDict objectForKey:@"path1"],[returnDict objectForKey:@"path2"],nil];
        NSArray *keys = [NSArray arrayWithObjects:@"fromPath",@"toPath",nil];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        CPDistributedMessagingCenter *center = [CPDistributedMessagingCenter centerNamed:@"com.homeschooldev.fusiond"];
        NSDictionary *returnData = [center sendMessageAndReceiveReplyName:@"moveFile" userInfo:dict];   
        if ([returnData objectForKey:@"error"]) NSLog(@"Error: %@",[returnData objectForKey:@"error"]);
        
        //Testing to see if the tweak is enabled...
        if ([self pluginEnabledWithPath:p]) {
            double gap = generalGap;
            if (counter == iconsPerPage) {
                gap += generalGap;
                counter = 0;
                pages++;
            }
    
            HSButton *button = [[HSButton alloc] initWithPath:[NSString stringWithFormat:@"/Library/Application Support/Fusion/Plugins/%@/",p] andFrame:CGRectMake(((cCount == 0 ? 0 : (cCount* ICON_SIZE) + (generalGap * cCount))+gap), self.frame.size.height / 2 - (ICON_SIZE / 2), ICON_SIZE, ICON_SIZE)];
            button.indexOnPage = counter;
            button.page = pages;
            [button performSetup];
            [button addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(showViewForPlugin:) forControlEvents:UIControlEventTouchDownRepeat];
            [buttons addObject:button];
            [self addSubview:button];
            [button release];
            
            if (counter == 0) button.xCor = [[buttons objectAtIndex:0] frame].origin.x;
            else if (counter == 1) button.xCor = [[buttons objectAtIndex:1] frame].origin.x;
            else if (counter == 2) button.xCor = [[buttons objectAtIndex:2] frame].origin.x;
            else if (counter == 3) button.xCor = [[buttons objectAtIndex:3] frame].origin.x;
        
            cCount++;
            counter++;
        }
        [self setContentSize:CGSizeMake(pages * self.frame.size.width, self.frame.size.height)];
    }
}

- (void)showViewForPlugin:(HSButton *)button {

    if (!pluginSuperView) return;
    
    pluginWindowOpen = YES;
	NSMutableDictionary *data = [tweakDelegate performSelector:@selector(getData) withObject:nil];
	data = [self parseAttachments:data];
    HSPlugin *plugin = [[HSPlugin alloc] initWithPath:button.pluginPath andData:data];
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)
        //Landscape
        pluginView = [[HSPluginView alloc] initWithPlugin:plugin andButton:button andFrame:
                CGRectMake(0,-[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height,[[UIScreen mainScreen] bounds].size.width)];
    else
        //portrait
        pluginView = [[HSPluginView alloc] initWithPlugin:plugin andButton:button andFrame:
                CGRectMake(0,-[[UIScreen mainScreen] bounds].size.height,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height)];
    pluginView.menu = self;
    [self pluginViewWillAppear];
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)
        //Landscape
        [self pluginViewFrameUpdated:CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.height-40,[[UIScreen mainScreen] bounds].size.width-40)];
    else
        //Portrait
        [self pluginViewFrameUpdated:CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width-40,[[UIScreen mainScreen] bounds].size.height-40)];
    [pluginView setTag:PluginViewTag];
    pluginView.alpha = 0.0;
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.subviews.count > 0) {
        //search for TWTweetSheetCardView. Once found, add the plugin view to it.
        int index;
        for (NSInteger i = 0; i < window.subviews.count; i++)
            for (NSInteger j = 0; j < [[window.subviews objectAtIndex:i] subviews].count; j++)
                if ([[[(UIView*)[window.subviews objectAtIndex:i] subviews] objectAtIndex:j] isKindOfClass:objc_getClass("TWTweetSheetCardView")])
                    index = i;
        
        [[[[UIApplication sharedApplication] keyWindow].subviews objectAtIndex:index] addSubview:pluginView];
    }
    else {
        [[[UIApplication sharedApplication] keyWindow] addSubview:pluginView];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
   		pluginView.alpha = 1.0;
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)
            //Landscape
            pluginView.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.height,[[UIScreen mainScreen] bounds].size.width);
        else
            //Portrait
            pluginView.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height);
   	}
   	completion:^(BOOL finished){ 
   		if (button) button.enabled = YES;
   		[self pluginViewDidAppear];
   	}];
    
    [plugin release];
    [pluginView release];
}

- (NSMutableDictionary*)parseAttachments:(NSMutableDictionary*)data {
    
    NSMutableArray *pics = [[[NSMutableArray alloc] initWithArray:[data objectForKey:@"Pics"]] autorelease];
    NSMutableArray *actualImages = [[[NSMutableArray alloc] init] autorelease];
   
    if (pics.count != 0) {
        for (NSString *p in pics) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:p]) {
                UIImage *image = [UIImage imageWithContentsOfFile:p];
                [actualImages addObject:image];
            }
        }
        [data removeObjectForKey:@"Pics"];
        [data setObject:actualImages forKey:@"Pics"];
    }
    
    //Get location...
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:Location_Path]) {
        if ([[data objectForKey:@"Location"] isEqualToString:@"ON"]) {
            NSDictionary *location = [[NSDictionary alloc] initWithContentsOfFile:Location_Path];
        
            if ([location objectForKey:@"Longitude"]) [data setObject:[location objectForKey:@"Longitude"] forKey:@"Longitude"];
            if ([location objectForKey:@"Latitude"]) [data setObject:[location objectForKey:@"Latitude"] forKey:@"Latitude"];
            if ([location objectForKey:@"Altitude"]) [data setObject:[location objectForKey:@"Altitude"] forKey:@"Altitude"];
            if ([location objectForKey:@"HorizontalAccuracy"]) [data setObject:[location objectForKey:@"HorizontalAccuracy"] forKey:@"HorizontalAccuracy"];
            if ([location objectForKey:@"VerticalAccuracy"]) [data setObject:[location objectForKey:@"VerticalAccuracy"] forKey:@"VerticalAccuracy"];
            if ([location objectForKey:@"Timestamp"]) [data setObject:[location objectForKey:@"Timestamp"] forKey:@"Timestamp"];

            [location release];
        }
    }
    
    return data;
}

- (NSArray *)pluginsRequireUIAttention {
	NSMutableArray *plugs = [[[NSMutableArray alloc] init] autorelease];
	NSMutableDictionary *data = [tweakDelegate performSelector:@selector(getData) withObject:nil];
	data = [self parseAttachments:data];
	for (NSString *p in [self bundles]) {
		HSPlugin *plugin = [[HSPlugin alloc] initWithPath:p andData:data];
		if ([plugin requiresUI]) [plugs addObject:plugin];
		[plugin release];
	}
	
	if (plugs.count == 0) return nil;
	
	return plugs;
}

- (void)showPluginUIs:(NSArray*)plugs {
	NSArray *selectedButtons = [self selectedButtons];
	NSMutableArray *pluginsWithUI = [[[NSMutableArray alloc] init] autorelease];
	for (HSButton *button in selectedButtons) {
		for (HSPlugin *plugin in plugs)
			if ([button.pluginPath isEqualToString:plugin.plugin])
				[pluginsWithUI addObject:button];
	}
	
	if (pluginsWithUI.count != 0) {
		HSButton *button = [pluginsWithUI objectAtIndex:0];
		[self showViewForPlugin:button];
		self.pluginViews = pluginsWithUI;
	}
}

- (void)closeWindow:(id)sender {
    sendButton.enabled = YES;
    
	[self pluginViewWillDisappear];
	self.pluginWindowOpen = NO;
    if (pluginView) {
    	[UIView animateWithDuration:0.3 animations:^{
    		pluginView.frame = CGRectMake(0,-pluginView.frame.size.height,pluginView.frame.size.width,pluginView.frame.size.height);
    		pluginView.alpha = 0.3;
    	}
    	completion:^(BOOL finished){  
    		[self pluginViewDidDisappear];
    		[pluginView removeFromSuperview];
    		[self showNextPluginView];
    		//If the entire plugin window was closed...
    		if (!sender) [tweakDelegate performSelector:@selector(closeMenu) withObject:nil];
    	}];
    }
    self.scrollEnabled = YES;
}

- (void)showNextPluginView {
	//Show plugin views...
    if (pluginViews) {
    	if (pluginViews.count > 0) {
    		[pluginViews removeObjectAtIndex:0];
    		pluginViewsStarted = YES;
    		if (pluginViews.count > 0)
    			[self showViewForPlugin:[pluginViews objectAtIndex:0]];
    		else
    			//Only one plugin and it's done showing.
    			[tweakDelegate performSelector:@selector(sendButtonTapped:) withObject:@"done"];
    	}
    	else {
    		//Done showing plugin views...
    		[tweakDelegate performSelector:@selector(sendButtonTapped:) withObject:@"done"];
    	}
    }
}

- (NSDictionary *)insertSpecifiersInPlugin:(NSString *)p {
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
    
    NSString *writePath = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist",p];
    [specifiers setObject:items forKey:@"items"];
    [specifiers writeToFile:writePath atomically:YES];
    NSDictionary *returnDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:writePath,specifiersPath,nil] forKeys:[NSArray arrayWithObjects:@"path1",@"path2",nil]];
    
    [items release];
    [specifiers release];
    
    return returnDict;
}

- (BOOL)pluginEnabledWithPath:(NSString *)p {
    NSDictionary *pluginInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Plugins/%@/Info.plist",ROOT_PATH,p]];
    NSDictionary *prefsInfo = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Plugins/%@/%@.bundle/Info.plist",ROOT_PATH,p,[pluginInfo objectForKey:@"PreferenceBundleName"]]];
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/User/Library/Preferences/%@.plist",[prefsInfo objectForKey:@"CFBundleIdentifier"]]];
    if ([data objectForKey:@"Enabled"] == nil || data == nil || prefsInfo == nil || pluginInfo == nil 
        || pluginInfo.count == 0 || prefsInfo.count == 0 || data.count == 0) return YES;
    return [[data objectForKey:@"Enabled"] boolValue];
}

- (void)buttonPushed:(HSButton *)btn {
	[btn setUserSelected:!btn.userSelected];
}

- (NSArray *)bundles {
    NSArray *selectedButtons = [self selectedButtons];
    if (!selectedButtons || selectedButtons.count == 0) return nil;
    
    NSMutableArray *bundles = [[[NSMutableArray alloc] init] autorelease];
    for (HSButton *button in selectedButtons) {
        [bundles addObject:button.pluginPath];
    }
    
    return bundles;
}

- (NSArray *)selectedButtons {
    if (!buttons || buttons.count == 0) return nil;
    NSMutableArray *selectedButtons = [[[NSMutableArray alloc] init] autorelease];
    
    for (HSButton *button in buttons) {
        if (button.userSelected) {
            [selectedButtons addObject:button];
        }
    }
    
    return selectedButtons;
}

- (void)locationButtonTappedOn:(BOOL)on {
	if (pluginView && pluginWindowOpen) {
		HSPlugin *plugin = pluginView.plugin;
		if (plugin)
			[plugin locationButtonTapped:on];
	}
}

- (BOOL)twitterSelected {
    NSArray *selectedButtons = [self selectedButtons];
  
    if (!selectedButtons || selectedButtons.count == 0) return NO;
    
    for (HSButton *b in selectedButtons) {
        if ([b.pluginPath hasSuffix:@"TwitterPlugin.bundle/"]) {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)organizeArray:(NSArray *)array {
    NSDictionary *order = [NSDictionary dictionaryWithContentsOfFile:PLUGIN_ORDER];
    NSArray *orderArray = [order objectForKey:@"Order"];
    NSMutableArray *pluginsArray = [[[NSMutableArray alloc] initWithArray:array] autorelease];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:PLUGIN_ORDER] || orderArray.count == 0) return array;
    
    if (pluginsArray.count == orderArray.count) {
        //The same paths are in both arrays and just need to be rearranged. :)
        for (NSUInteger i=0; i<orderArray.count; i++) {
            for (NSUInteger j=0; j<pluginsArray.count; j++) {
                NSString *actualPath = [NSString stringWithFormat:@"/Library/Application Support/Fusion/Plugins/%@",[[pluginsArray objectAtIndex:j] lastPathComponent]];
                if ([actualPath isEqualToString:[orderArray objectAtIndex:i]]) {
                    NSString *temp = [pluginsArray objectAtIndex:j];
                    [pluginsArray removeObjectAtIndex:j];
                    [pluginsArray insertObject:temp atIndex:i];
                }
            }
        }
    }
    else {
        //Hmm, the arrays are different. We must find which paths are new.
        NSMutableArray *newPaths = [[[NSMutableArray alloc] init] autorelease];
        for (NSUInteger i=0; i < pluginsArray.count; i++) {
            NSString *actualPath = [NSString stringWithFormat:@"/Library/Application Support/Fusion/Plugins/%@",[[pluginsArray objectAtIndex:i] lastPathComponent]];
            if (![orderArray containsObject:actualPath]) {
                [newPaths addObject:[pluginsArray objectAtIndex:i]];
                [pluginsArray removeObjectAtIndex:i];
            }
        }
        
        for (NSUInteger i=0; i<orderArray.count; i++) {
            for (NSUInteger j=0; j<pluginsArray.count; j++) {
                NSString *actualPath = [NSString stringWithFormat:@"/Library/Application Support/Fusion/Plugins/%@",[[pluginsArray objectAtIndex:j] lastPathComponent]];
                if ([actualPath isEqualToString:[orderArray objectAtIndex:i]]) {
                    NSString *temp = [pluginsArray objectAtIndex:j];
                    [pluginsArray removeObjectAtIndex:j];
                    [pluginsArray insertObject:temp atIndex:i];
                }
            }
        }
        
        [pluginsArray addObjectsFromArray:newPaths];
    }
    
    return pluginsArray;
}

- (void)rotateToOrientation:(int)orientation withDuration:(double)duration {
	if (pluginWindowOpen && pluginView) {
		id controller = pluginView.pluginViewController;
		Class controllerClass = [controller class];
		if ([controllerClass instancesRespondToSelector:@selector(willAnimateRotationToInterfaceOrientation:withDuration:)]) {
			NSInvocation *inv = [NSInvocation invocationWithMethodSignature:
				[controller methodSignatureForSelector:@selector(willAnimateRotationToInterfaceOrientation:withDuration:)]];
			[inv setSelector:@selector(willAnimateRotationToInterfaceOrientation:withDuration:)];
			[inv setTarget:controller];
			[inv setArgument:&orientation atIndex:2];
			[inv setArgument:&duration atIndex:3];
			[inv invoke];
		}
	}
}

- (void)pluginViewDidAppear {
	if (pluginWindowOpen && pluginView) {
		id controller = pluginView.pluginViewController;
		Class controllerClass = [controller class];
		if ([controllerClass instancesRespondToSelector:@selector(viewDidAppear)]) {
			[controller performSelector:@selector(viewDidAppear) withObject:nil];
		}
	}
}

- (void)pluginViewWillAppear {
	if (pluginWindowOpen && pluginView) {
		id controller = pluginView.pluginViewController;
		Class controllerClass = [controller class];
		if ([controllerClass instancesRespondToSelector:@selector(viewWillAppear)]) {
			[controller performSelector:@selector(viewWillAppear) withObject:nil];
		}
	}
}

- (void)pluginViewDidDisappear {
	if (pluginView) {
		id controller = pluginView.pluginViewController;
		Class controllerClass = [controller class];
		if ([controllerClass instancesRespondToSelector:@selector(viewDidDisappear)]) {
			[controller performSelector:@selector(viewDidDisappear) withObject:nil];
		}
	}
}

- (void)pluginViewWillDisappear {
	if (pluginWindowOpen && pluginView) {
		id controller = pluginView.pluginViewController;
		Class controllerClass = [controller class];
		if ([controllerClass instancesRespondToSelector:@selector(viewWillDisappear)]) {
			[controller performSelector:@selector(viewWillDisappear) withObject:nil];
		}
	}
}

- (void)pluginViewFrameUpdated:(CGRect)frame {
	if (pluginWindowOpen && pluginView) {
		id controller = pluginView.pluginViewController;
		Class controllerClass = [controller class];
		if ([controllerClass instancesRespondToSelector:@selector(viewUpdatedWithFrame:)]) {
			//[controller performSelector:@selector(viewUpdatedWithFrame:) withObject:[NSValue valueWithCGRect:frame]];
			NSInvocation *inv = [NSInvocation invocationWithMethodSignature:
				[controller methodSignatureForSelector:@selector(viewUpdatedWithFrame:)]];
			[inv setSelector:@selector(viewUpdatedWithFrame:)];
			[inv setTarget:controller];
			[inv setArgument:&frame atIndex:2];
			[inv invoke];
		}
	}
}

- (void)dealloc {
    
    if (pluginViews) [pluginViews release];
	[path release];
	[plugins release];
    [buttons release];
    [tweakDelegate release];
    [sendButton release];
    if (target) [target release];
    
    self.pluginViews = nil;
    self.tweakDelegate = nil;
    self.path = nil;
    self.sendButton = nil;
    
	[super dealloc];
}

@end
