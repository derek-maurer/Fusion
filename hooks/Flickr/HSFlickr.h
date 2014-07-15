#import "ObjectiveFlickr.h"

@interface HSFlickr : NSObject <OFFlickrAPIRequestDelegate> {
    OFFlickrAPIRequest *flickrRequest;
    OFFlickrAPIContext *flickrContext;
    id finishedDelegate;
    NSMutableArray *links;
    NSMutableArray *images;
    NSString *message;
}
- (id)initWithDelegate:(id)del andMessage:(NSString *)mes;
- (void)postImages:(NSArray*)_images;
- (OFFlickrAPIRequest *)flickrRequest;
- (OFFlickrAPIContext *)flickrContext;
- (NSString *)base58EncodedValue:(long long)num;
@end