#import "Fusion.h"
#import "HSPluginController.h"

@interface FusionServer: NSObject {
	CPDistributedMessagingCenter *center;
	NSFileManager *fileManager;
}
- (void)post:(NSString *)name info:(NSDictionary *)info;
- (NSDictionary *)contentsOfFile:(NSString *)name info:(NSDictionary *)info;
- (NSDictionary *)contentsOfPath:(NSString *)name info:(NSDictionary *)inf;
- (void)writeContentsToFile:(NSString *)name info:(NSDictionary *)info;
- (NSDictionary *)copyFile:(NSString *)name info:(NSDictionary *)info;
- (void)setUpFileSystem:(NSString *)name info:(NSDictionary *)info;
- (void)startServer;
- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message andCancelButtonTitle:(NSString*)cancel;
@end

void setup(void);
BOOL SaveImage(void);
BOOL SaveImagePath(void);
void WriteImagePath(void);

