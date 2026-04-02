//
//  WTLogger.m
//  wakatime-cli
//
//  Created by Adithiya Venkatakrishnan on 1/4/2026.
//

#import "WTLogger.h"

NS_ASSUME_NONNULL_BEGIN

@interface WTLogger ()
    
@property (nonatomic) NSString* filePathForLogging;

@end

@implementation WTLogger

- (instancetype)init {
    self = [super init];
    if (self) {
        self.filePathForLogging = [@"~/.wakatime/log.txt" stringByExpandingTildeInPath];
        // Expand the tilde (~) to the full home directory path
        NSFileManager *fileManager = [NSFileManager defaultManager];
        // 1. Create the file if it doesn't exist
        if (![fileManager fileExistsAtPath:self.filePathForLogging]) {
            [fileManager createFileAtPath:self.filePathForLogging contents:nil attributes:nil];
        }
    }
    return self;
}
    
+ (instancetype)shared {
    static WTLogger *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)log:(NSString*)message {
    if (DEBUG) {
        NSLog(@"[DEBUG] %@", message);
        NSFileHandle* handle = [NSFileHandle fileHandleForWritingAtPath:self.filePathForLogging];
        if (handle) {
            [handle seekToEndOfFile];
            [handle writeData:[
                [NSString stringWithFormat:@"[DEBUG] %@", message] dataUsingEncoding:NSUTF8StringEncoding
            ]];
        } else {
            NSLog(@"[CRITICAL] failed to open log, aborting process. Goodbye");
            abort();
        }
    }
}

- (void)warn:(NSString*)message {
    NSLog(@"[WARN] %@", message);
    NSFileHandle* handle = [NSFileHandle fileHandleForWritingAtPath:self.filePathForLogging];
    if (handle) {
        [handle seekToEndOfFile];
        [handle writeData:[
            [NSString stringWithFormat:@"[WARN] %@", message] dataUsingEncoding:NSUTF8StringEncoding
        ]];
    } else {
        NSLog(@"[CRITICAL] failed to open log, aborting process. Goodbye");
        abort();
    }
}

- (void)error:(NSString*)message {
    NSLog(@"[ERROR] %@", message);
    NSFileHandle* handle = [NSFileHandle fileHandleForWritingAtPath:self.filePathForLogging];
    if (handle) {
        [handle seekToEndOfFile];
        [handle writeData:[
            [NSString stringWithFormat:@"[ERROR] %@", message] dataUsingEncoding:NSUTF8StringEncoding
        ]];
    } else {
        NSLog(@"[CRITICAL] failed to open log, aborting process. Goodbye");
        abort();
    }
}

@end

NS_ASSUME_NONNULL_END
