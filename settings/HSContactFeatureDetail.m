#import "HSContactFeatureDetail.h"

@implementation HSContactFeatureDetail
@synthesize addingNew, feature;

- (id)init {
    if ((self = [super init])) {
        self.addingNew = NO;
    }
    return self;
}

- (void)setNavigationTitle:(NSString *)navigationTitle {
	if ([self respondsToSelector:@selector(navigationItem)]) { 
		[[self navigationItem] setTitle:navigationTitle]; 
	}
}

- (id)view {
	return view;
}

- (void)viewWillAppear:(BOOL)animated {
	[self setNavigationTitle:@"Feature"];
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
    
    scrollView = [[UIScrollView alloc] initWithFrame:view.frame];
    [scrollView setContentSize: CGSizeMake(view.frame.size.width, view.frame.size.height*1.5)];
    [view addSubview:scrollView];
    [scrollView release];
    
    closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(0,0,scrollView.contentSize.width, scrollView.contentSize.height);
    [closeButton addTarget:self action:@selector(textViewDone:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:closeButton];
    
    shortLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, self.view.frame.size.width - 20, 40)];
    [shortLabel setText:@"Short Description:"];
    [shortLabel setTextColor:[UIColor blackColor]];
    [shortLabel setFont:[UIFont systemFontOfSize:14]];
    [shortLabel setBackgroundColor:[UIColor clearColor]];
    [shortLabel setTextAlignment:UITextAlignmentLeft];
    [scrollView addSubview:shortLabel];
    [shortLabel release];
    
	shortDes = [[UITextField alloc] initWithFrame:CGRectMake(10,shortLabel.frame.size.height + shortLabel.frame.origin.y,view.frame.size.width - 20,31)];
    if (!addingNew)
        shortDes.enabled = NO;
    shortDes.adjustsFontSizeToFitWidth = YES;
    if (!addingNew)
        shortDes.text = [[feature objectForKey:@"ShortDescription"] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    [shortDes setFont:[UIFont systemFontOfSize:14]];
    shortDes.clearButtonMode = UITextFieldViewModeWhileEditing;
    shortDes.returnKeyType = UIReturnKeyDone;
    [shortDes addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
    shortDes.borderStyle = UITextBorderStyleRoundedRect;
    [scrollView addSubview:shortDes];
    [shortDes release];
    
    longLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, (shortDes.frame.size.height + shortDes.frame.origin.y + 5), self.view.frame.size.width - 20, 40)];
    longLabel.textAlignment = UITextAlignmentLeft;
    [longLabel setText:@"Long Description:"];
    [longLabel setTextColor:[UIColor blackColor]];
    [longLabel setFont:[UIFont systemFontOfSize:14]];
    [longLabel setBackgroundColor:[UIColor clearColor]];
    [longLabel setTextAlignment:UITextAlignmentLeft];
    [scrollView addSubview:longLabel];
    [longLabel release];
    
    longDes = [[UITextView alloc] initWithFrame:CGRectMake(10,(longLabel.frame.size.height + longLabel.frame.origin.y),view.frame.size.width - 20,view.frame.size.height - 90 - (longLabel.frame.size.height + longLabel.frame.origin.y))];
    [longDes setFont:[UIFont systemFontOfSize:14]];
    [[longDes layer] setCornerRadius:6];
    [[longDes layer] setBorderWidth:1];
    [[longDes layer] setBorderColor:[[UIColor colorWithWhite:0.0 alpha:0.3] CGColor]];
    [[longDes layer] setShadowColor:[[UIColor colorWithWhite:0.0 alpha:0.3] CGColor]];
    longDes.clipsToBounds = YES;
    if (!addingNew)
        longDes.text = [[feature objectForKey:@"LongDescription"] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    if (!addingNew)
        longDes.editable = NO;
    [scrollView addSubview:longDes];
    [longDes release];
    
    UIImage *image = [[UIImage imageWithContentsOfFile:@"/Library/Application Support/Fusion/Resources/Button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f,15.0f,0.0f,15.0f)];
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10, self.view.frame.size.height - 44, self.view.frame.size.width - 20, 40);
    if (addingNew)
        [button setTitle:@"Request" forState:UIControlStateNormal];
    else
        [button setTitle:@"I want this feature too!" forState:UIControlStateNormal];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [[button layer] setCornerRadius:8];
    [[button layer] setBorderWidth:1];
    [[button layer] setBorderColor:[[UIColor colorWithWhite:0.0 alpha:0.3] CGColor]];
    [[button layer] setShadowColor:[[UIColor colorWithWhite:0.0 alpha:0.3] CGColor]];
    [button setClipsToBounds:YES];
    [scrollView addSubview:button];
    
    [super viewWillAppear:animated];
}

- (void)buttonPressed:(id)sender {
    if (addingNew) {
        if (shortDes.text.length > 0 && longDes.text.length > 0) {
            self.feature = [NSMutableDictionary dictionary];
            [feature setObject:shortDes.text forKey:@"ShortDescription"];
            [feature setObject:longDes.text forKey:@"LongDescription"];
            NSString *ID = [NSString stringWithFormat:@"%@%@%@",[[UIDevice currentDevice] uniqueIdentifier],shortDes.text,[[NSDate date] description]];
            [feature setObject:[self SHA1:ID] forKey:@"ID"];
            [feature setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"UDIDOfReporter"];
            [feature setObject:[NSArray arrayWithObject:[[UIDevice currentDevice] uniqueIdentifier]] forKey:@"Reporters"];
            
            NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist"];
            [prefs setObject:feature forKey:@"NewFeature"];
            [prefs writeToFile:@"/User/Library/Preferences/com.homeschooldev.fusionsettings.plist" atomically:YES];
            
            CPDistributedMessagingCenter *center = [CPDistributedMessagingCenter centerNamed:@"com.homeschooldev.fusiond"];
            [center sendMessageName:@"ReportNewFeature" userInfo:feature];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Feature" message:@"Thank you for requesting this feature. The developer has been notified and he will look into it as soon as he can!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            button.enabled = NO;
            longDes.editable = NO;
            shortDes.enabled = NO;
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a short and long description of the feature" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
    else {
        //This person suffers from the feature.
        CPDistributedMessagingCenter *center = [CPDistributedMessagingCenter centerNamed:@"com.homeschooldev.fusiond"];
        [center sendMessageName:@"IWantThisFeatureToo" userInfo:feature];
        
        button.hidden = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Feature" message:@"Thank you for supporting the future of Fusion! The developer has been notified that you want this feature too." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (NSString *)SHA1:(NSString*)input {
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
 
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
 
    CC_SHA1(data.bytes, data.length, digest);
 
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
 
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
 
    return output;
}

- (void)textFieldDone:(UITextField *)tField {
    [tField resignFirstResponder];
}

- (void)textViewDone:(id)tView {
    [longDes resignFirstResponder];
    [shortDes resignFirstResponder];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		if (toInterfaceOrientation == UIInterfaceOrientationPortrait || 
			toInterfaceOrientation == UIDeviceOrientationPortraitUpsideDown) 
			view.frame = CGRectMake(0,0,467,960);
		else
			view.frame = CGRectMake(0,0,723,704);
	}
    
    shortLabel.frame = CGRectMake(10, 5, self.view.frame.size.width - 20, 40);
    shortDes.frame = CGRectMake(10,shortLabel.frame.size.height + shortLabel.frame.origin.y,view.frame.size.width - 20,31);
    longLabel.frame = CGRectMake(10, (shortDes.frame.size.height + shortDes.frame.origin.y + 5), self.view.frame.size.width - 20, 40);
    longDes.frame = CGRectMake(10,(longLabel.frame.size.height + longLabel.frame.origin.y),view.frame.size.width - 20,view.frame.size.height - 90 - (longLabel.frame.size.height + longLabel.frame.origin.y));
}

-(void)dealloc {
    [view release];
	[super dealloc];
}

@end
