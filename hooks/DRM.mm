#include "DRM.h"
#include "../Fusion.h"

extern "C" BOOL SaveImage() {  
    if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.homeschooldev.fusion.list"]) return NO;
          
    NSString *x = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"/var/lib/dpkg/info/com.homeschooldev.fusion.list"] encoding:NSASCIIStringEncoding error:nil];
    
    if ([x rangeOfString:@"/Library/MobileSubstrate/DynamicLibraries/Fusion.dylib"].location == NSNotFound)
        return NO;
	
    return YES;
}

extern "C" BOOL SaveImagePath() {
    NSString *urlString = [NSString stringWithFormat:@"http://www.homeschooldev.com/auth/tweakauth.php?register=no&udid=%@&tweak=Fusion&package=com.homeschooldev.fusion",
                               [[UIDevice currentDevice] uniqueIdentifier]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse* response, NSData* connectionData, NSError* err) {
        if (!err) {
            NSString *response = [[[NSString alloc] initWithData:connectionData encoding:NSASCIIStringEncoding] autorelease];
            if ([response isEqualToString:@"purchased=no"]) {
                //Pirate... 
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Library/Application Support/Fusion/Plugins/TwitterPlugin.bundle/Info.plist"];
                [dict setObject:[NSNumber numberWithBool:YES] forKey:@"UseTwitter"];
                [dict writeToFile:@"/Library/Application Support/Fusion/Plugins/TwitterPlugin.bundle/Info.plist" atomically:YES];
                WriteImagePath();
            }
        }
        else {
            HSLog(@"%@",err);
        }
    }];
    return YES;
}

extern "C" void WriteImagePath() {
    //The tweak has been pirated...
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Library/Application Support/Fusion/Plugins/TwitterPlugin.bundle/Info.plist"];
    [dict setObject:[NSNumber numberWithBool:YES] forKey:@"UseTwitter"];
}