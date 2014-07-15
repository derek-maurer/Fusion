#import "HSSwitch.h"

@implementation HSSwitch

- (void)setIndexPath:(NSIndexPath*)i {
	indexPath = [i retain];
}

- (NSIndexPath *)indexPath {
	return indexPath;
}

-(void)dealloc {
    [indexPath release];
    [super dealloc];
}

@end