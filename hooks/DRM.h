#import "Fusion.h"
#include "ifaddrs.h"
#import <CommonCrypto/CommonHMAC.h>

extern "C" {    
    BOOL SaveImage(void);
    BOOL SaveImagePath(void);
    void WriteImagePath(void);
}