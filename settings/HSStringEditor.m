#import "HSStringEditor.h"

@implementation HSStringEditor

- (id) initForContentSize:(CGSize)size {
	return [self init];
}

- (id)initWithPath:(NSString *)p key:(NSString *)k andValue:(NSString *)v {
	if ((self = [super init])) {
        
        NSDictionary *dict = [NSDictionary dictionaryWithObject:p forKey:@"path"];
        CPDistributedMessagingCenter *center = [CPDistributedMessagingCenter centerNamed:@"com.homeschooldev.fusiond"];
        NSDictionary *info = [[center sendMessageAndReceiveReplyName:@"contentsOfFile" userInfo:dict] retain];
        value = [[NSString alloc] initWithString:[info objectForKey:k]];
        
        path = [p retain];
        key = [k retain];
    }
    return self;
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
	return @"Editor";
}

- (id)view {
	return view;
}

- (void)setSpecifier:(PSSpecifier *)specifier {
	[self loadFromSpecifier:specifier];
	[super setSpecifier:specifier];
}

- (void)loadFromSpecifier:(PSSpecifier *)specifier {
    
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
    textField.placeholder = @"Please enter a string value.";
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
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:path forKey:@"path"];
    CPDistributedMessagingCenter *center = [CPDistributedMessagingCenter centerNamed:@"com.homeschooldev.fusiond"];
    NSDictionary *returnData = [center sendMessageAndReceiveReplyName:@"contentsOfFile" userInfo:dict];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObjects:[returnData allValues] forKeys:[returnData allKeys]];
    [info setObject:path forKey:@"FusionWritePath"];
    [info setObject:textField.text forKey:key];
    [center sendMessageName:@"writeContentsToFile" userInfo:info];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
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
    [path release];
	[key release];
    [value release];
	[super dealloc];
}

@end
