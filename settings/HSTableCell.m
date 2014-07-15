#import "HSTableCell.h"

@implementation HSTableCell
@synthesize path;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        path = [[NSString alloc] init];
    }
    return self;
}

-(void)dealloc {
    [path release];
    [super dealloc];
}

@end