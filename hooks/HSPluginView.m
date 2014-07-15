#import "HSPluginView.h"

@implementation HSPluginView 
@synthesize button, pluginViewController, plugin, menu;

- (id)initWithPlugin:(HSPlugin *)p andButton:(HSButton *)b andFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.button = b;
		self.plugin = p;
		self.pluginViewController = [p pluginViewController];
        
        CGRect pluginFrame = CGRectMake(20,20,frame.size.width-40,frame.size.height-60);
		
		if (pluginViewController && [[pluginViewController class] instancesRespondToSelector:@selector(view)]) {
			if ([pluginViewController view]) {
				pluginView = [[pluginViewController view] retain];
				[(UIView*)pluginView setFrame:pluginFrame];
				[(UIView*)pluginView setClipsToBounds:YES];
				[[(UIView*)pluginView layer] setCornerRadius:5];
				[[(UIView*)pluginView layer] setBorderWidth:1];
				[[(UIView*)pluginView layer] setBorderColor:[[UIColor colorWithWhite:0.0 alpha:0.3] CGColor]];
				[[(UIView*)pluginView layer] setShadowColor:[[UIColor colorWithWhite:0.0 alpha:0.3] CGColor]];
				
				[self addSubview:pluginView];
				[pluginView release];
			}
			else {
				textLabel = [[UILabel alloc] initWithFrame:pluginFrame];
                textLabel.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
                textLabel.textColor = [UIColor whiteColor];
                textLabel.lineBreakMode = UILineBreakModeWordWrap;
                textLabel.numberOfLines = 0;
                textLabel.textAlignment = UITextAlignmentCenter;
                textLabel.text = @"This social network doesn't not have a view...";
                [self addSubview:textLabel];
                [textLabel release];
			}
		}
		else {
            textLabel = [[UILabel alloc] initWithFrame:pluginFrame];
            textLabel.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
            textLabel.lineBreakMode = UILineBreakModeWordWrap;
            textLabel.numberOfLines = 0;
            textLabel.textColor = [UIColor whiteColor];
            textLabel.textAlignment = UITextAlignmentCenter;
            textLabel.text = @"This social network doesn't not have a view...";
            [self addSubview:textLabel];
            [textLabel release];
		}
	
        closeButton = [[UIButton alloc] initWithFrame:CGRectMake(10,10,30,30)];
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00)
            [closeButton setImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Fusion/Resources/close@2x.png"] forState:UIControlStateNormal];
        else
            [closeButton setImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Fusion/Resources/close.png"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        [closeButton release];
    
    }
    
    return self;
}

- (void)closeButtonPushed:(id)sender {
    [menu performSelector:@selector(closeWindow:) withObject:sender];
}

- (void)reload {
	if (textLabel) {
		textLabel.frame = CGRectMake(20,20,self.frame.size.width-40,self.frame.size.height-60);
	}
	else {
		if (pluginView) 
			[(UIView*)pluginView setFrame:CGRectMake(20,20,self.frame.size.width-40,self.frame.size.height-60)];
	}
}

- (void)dealloc {

	if (button) [button release];
	if (pluginViewController) [pluginViewController release];
	if (plugin) [plugin release];
	
	[super dealloc];
}

@end