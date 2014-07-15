#import "HSNowPlayingEditor.h"

@implementation HSNowPlayingEditor

- (id) initForContentSize:(CGSize)size {
	return [self init];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self textFieldDone:nil];
    [super viewWillDisappear:animated];
}

- (void)setNavigationTitle:(NSString *)navigationTitle {
	if ([self respondsToSelector:@selector(navigationItem)]) { 
		[[self navigationItem] setTitle:navigationTitle]; 
	}
}

- (NSString *)navigationTitle {
	return @"Now Playing";
}

- (id)view {
	return view;
}

- (void)setSpecifier:(PSSpecifier *)specifier {
	[self loadFromSpecifier:specifier];
	[super setSpecifier:specifier];
}

- (void)loadFromSpecifier:(PSSpecifier *)specifier {

	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
	NSString *value;
	if (![dict objectForKey:@"NowPlaying"] || [[dict objectForKey:@"NowPlaying"] isEqualToString:@""])
		value = @"I'm listening to";
	else	
		value = [dict objectForKey:@"NowPlaying"];
    
	[self setNavigationTitle:[self navigationTitle]];
	
	view = [[UIView alloc] init];
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
		view.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height - 65.0f);
	else {
		//ipad
		if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait ||
			[UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown)
			view.frame = CGRectMake(0,0,467,960);
		else
			view.frame = CGRectMake(0,0,723,704);
	}
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	textField = [[UITextField alloc] initWithFrame:CGRectMake(10,(view.frame.size.height/2)-80,view.frame.size.width - 20,31)];
    textField.placeholder = @"Now playing message...";
    textField.adjustsFontSizeToFitWidth = YES;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.returnKeyType = UIReturnKeyDone;
    textField.text = value;
    [textField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    [view addSubview:textField];
    [textField release];
}

- (void)textFieldDone:(UITextField *)tField {
    [textField resignFirstResponder];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
    NSLog(@"Text: %@",textField.text);
    if (textField.text && ![textField.text isEqualToString:@""]) 
    	[dict setObject:textField.text forKey:@"NowPlaying"];
    else 
    	[dict setObject:@"I'm listening to" forKey:@"NowPlaying"];
    [dict writeToFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist" atomically:YES];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		if (toInterfaceOrientation == UIInterfaceOrientationPortrait || 
			toInterfaceOrientation == UIDeviceOrientationPortraitUpsideDown) 
			view.frame = CGRectMake(0,0,467,960);
		else
			view.frame = CGRectMake(0,0,723,704);
	}
	textField.frame = CGRectMake(10,(view.frame.size.height/2)-80,view.frame.size.width - 20,31);
	//phones can't rotate in settings so no need to change the size of the view...
}

-(void)dealloc {
    [view release];
	[super dealloc];
}

@end
