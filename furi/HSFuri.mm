#import "HSFuri.h"
#import "HSFuriCommands.h"

@implementation HSFuri

// required initialization
-(id)initWithSystem:(id<SESystem>)system
{
	if ( (self = [super init]) )
	{
		// register all extension classes provided
		[system registerCommand:[HSFuriCommands class]];
	}
	return self;
}

// optional info about extension
-(NSString*)author
{
	return @"Home School Dev";
}
-(NSString*)name
{
	return @"Furi";
}
-(NSString*)description
{
	return @"A siri extension that is used with Fusion. Say a phrase like post to Facebook and it shows twitter to allow you to post to the services with Fusion.";
}
-(NSString*)website
{
	return @"homeschooldev.com";
}
-(NSString*)versionRequirement
{
	return @"1.0.1";
}

@end
// vim:ft=objc
