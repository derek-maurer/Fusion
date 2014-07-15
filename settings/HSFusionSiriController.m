#import "HSFusionSiriController.h"


@implementation HSFusionSiriController

- (void)setNavigationTitle:(NSString *)navigationTitle {
	if ([self respondsToSelector:@selector(navigationItem)]) {
		[[self navigationItem] setTitle:navigationTitle];
	}
}

- (id)view {
	return wrapperView;
}

- (void)setSpecifier:(PSSpecifier *)specifier {
	[self loadFromSpecifier:specifier];
	[super setSpecifier:specifier];
}

- (void)loadFromSpecifier:(PSSpecifier *)specifier {
	[self setNavigationTitle:@"Siri"];
    
    phrases = [[NSMutableArray alloc] initWithObjects:@"Update status",@"Update status <your status>",@"Update status saying <your status>",@"Update status with latest photo <status>",@"Upload latest photo",@"Upload latest photo to <networks>",@"Upload loatest photo <caption>",@"Upload latest photo with caption <caption>",@"Upload latest photo with caption <caption> to <networks>",@"Post status",@"Post status <your status>",@"Post status saying <your status>",@"Post status to <network>",@"Post status to <network> saying <status>",@"Post status with latest photo <status>",@"Post status with latest photo <status> to <networks>",@"Post latest photo",@"Post latest photo to <network>",@"Post latest photo with caption <caption>",@"Post latest photo <caption>",nil];
    
    wrapperView = [[UIView alloc] initWithFrame:CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height - 65.0f)];
    wrapperView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	_table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height - 65.0f) style:UITableViewStyleGrouped];
	[_table setDelegate:self];
	[_table setDataSource:self];
	[_table setAllowsSelectionDuringEditing:YES];
    [wrapperView addSubview:_table];
    [_table release];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/AssistantExtensions.dylib"]) {
        _table.hidden = YES;
        
        UILabel *installLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, wrapperView.frame.size.height/2 - 40, wrapperView.frame.size.width - 20, 40)];
        installLabel.lineBreakMode = UILineBreakModeWordWrap;
        installLabel.numberOfLines = 0;
        [installLabel setText:@"You must install AssistantExtensions in order to use Siri with Fusion"];
        [installLabel setTextColor:[UIColor blackColor]];
        [installLabel setFont:[UIFont systemFontOfSize:16]];
        [installLabel setBackgroundColor:[UIColor clearColor]];
        [installLabel setTextAlignment:UITextAlignmentCenter];
        [wrapperView addSubview:installLabel];
        [installLabel release];
        
        UIImage *image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Fusion/Resources/Button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f,15.0f,0.0f,15.0f)];
        UIButton *installButton = [UIButton buttonWithType:UIButtonTypeCustom];
        installButton.frame = CGRectMake(10, wrapperView.frame.size.height - 44, wrapperView.frame.size.width - 20, 40);
        [installButton setTitle:@"Install AssistantExtensions" forState:UIControlStateNormal];
        [installButton setBackgroundImage:image forState:UIControlStateNormal];
        [installButton addTarget:self action:@selector(installAssistantExtensions) forControlEvents:UIControlEventTouchUpInside];
        [[installButton layer] setCornerRadius:8];
        [[installButton layer] setBorderWidth:1];
        [[installButton layer] setBorderColor:[[UIColor colorWithWhite:0.0 alpha:0.3] CGColor]];
        [[installButton layer] setShadowColor:[[UIColor colorWithWhite:0.0 alpha:0.3] CGColor]];
        [installButton setClipsToBounds:YES];
        [wrapperView addSubview:installButton];
    }
}

- (void)installAssistantExtensions {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/me.k3a.ae"]];
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (id)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section {
	return @"You can use this feature by opening Siri and saying any one of the phrases below to post a status";
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *c = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!c) {
		c = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
	}
	
	c.textLabel.text = [phrases objectAtIndex:indexPath.row];

	return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[phrases objectAtIndex:indexPath.row] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(int)section {
	return [phrases count];
}

- (void)dealloc {
    [wrapperView release];
	[phrases release];
	[super dealloc];
}

@end
