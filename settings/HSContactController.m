#import "HSContactController.h"

@implementation HSContactController

- (void)setNavigationTitle:(NSString *)navigationTitle {
	if ([self respondsToSelector:@selector(navigationItem)]) { 
		[[self navigationItem] setTitle:navigationTitle]; 
	}
}

- (void)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (id)view {
    return _table;
}

- (void)viewWillAppear:(BOOL)animated {
    [self setNavigationTitle:@"Contact"];
    
	_table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height - 65.0f) style:UITableViewStyleGrouped];
	[_table setDelegate:self];
	[_table setDataSource:self];
	[_table setAllowsSelectionDuringEditing:YES];

	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
	[[self navigationItem] setLeftBarButtonItem:cancelButton];
	[cancelButton release];
	
    controllers = [[NSMutableArray alloc] initWithObjects:@"Report a bug",@"Request a feature",@"Other",nil];

	[_table reloadData];
    
    [super viewWillAppear:animated];
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
	return controllers.count;
}

- (id)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section {
	return @"";
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!c) {
		c = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
	}
    
	c.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	c.textLabel.text = [controllers objectAtIndex:indexPath.section];
    
	return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([[controllers objectAtIndex:indexPath.section] isEqualToString:@"Report a bug"]) {
        HSContactBugsController *bugs = [[HSContactBugsController alloc] init];
        [[self navigationController] pushViewController:bugs animated:YES];
        [bugs release];
    }
    else if ([[controllers objectAtIndex:indexPath.section] isEqualToString:@"Request a feature"]) {
        HSContactFeatureController *bugs = [[HSContactFeatureController alloc] init];
        [[self navigationController] pushViewController:bugs animated:YES];
        [bugs release];
    }
    else if ([[controllers objectAtIndex:indexPath.section] isEqualToString:@"Other"]) {
        MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
        composer.mailComposeDelegate = self;
        
        [composer setToRecipients:[NSArray arrayWithObject:@"derek@homeschooldev.com"]];
        [composer setSubject:[NSString stringWithFormat:@"Fusion - Other question %@",[[UIDevice currentDevice] uniqueIdentifier]]];
        [composer setMessageBody:[NSString stringWithFormat:@"\n\n\n\n\n (DO NOT REMOVE THIS! If you remove it I will just ask for it before I answer your question.) %@", [[UIDevice currentDevice] uniqueIdentifier]] isHTML:NO];
        [self presentModalViewController:composer animated:YES];
        [composer release];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [controller dismissModalViewControllerAnimated:YES];
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(int)section {
	return 1;
}

- (void)dealloc {
    [_table release];
	[controllers release];
	[super dealloc];
}

@end
