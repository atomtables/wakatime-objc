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
@property (nonatomic) bool useStdout;
@property (nonatomic) bool debug;

@end

@implementation WTLogger

+ (instancetype)shared {
    static WTLogger *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        self.filePathForLogging = [@"~/.wakatime/log.txt" stringByExpandingTildeInPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:self.filePathForLogging]) {
            [fileManager createFileAtPath:self.filePathForLogging contents:nil attributes:nil];
        }
    }
    return self;
}
    
- (void)configureLoggerWithFilePath:(NSString *)filePath
                         withStdout:(bool)useStdout
                          withDebug:(bool)debug {
    if (filePath) {
        self.filePathForLogging = [filePath stringByExpandingTildeInPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *directory = [self.filePathForLogging stringByDeletingLastPathComponent];
        NSError *error = nil;
        [fileManager createDirectoryAtPath:directory
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
        
        if (![fileManager fileExistsAtPath:self.filePathForLogging])
            [fileManager createFileAtPath:self.filePathForLogging
                                 contents:nil
                               attributes:nil];
    }
    self.useStdout = useStdout;
    self.debug = debug;
}

// C function because this is so unnecessary for it to be a message pass
NSString* stringForLogLevel(WTLoggerLogLevel logLevel) {
    switch (logLevel) {
        case WTLoggerLogLevelDebug:
            return @"DEBUG";
        case WTLoggerLogLevelWarn:
            return @"WARN";
        case WTLoggerLogLevelError:
            return @"ERROR";
        case WTLoggerLogLevelSmurfme:
            return @"DEV";
        default:
            return @"CRITICAL";
    }
}

- (void)log:(NSString*)message withLogLevel:(WTLoggerLogLevel)logLevel {
    if (!DEBUG && logLevel == WTLoggerLogLevelSmurfme) return;
    if (!self.debug && logLevel == WTLoggerLogLevelDebug && !DEBUG) return;
    if (self.useStdout || logLevel == WTLoggerLogLevelError) {
        NSLog(@"[%@] %@", stringForLogLevel(logLevel), message);
    }
    NSFileHandle* handle = [NSFileHandle fileHandleForWritingAtPath:self.filePathForLogging];
    if (handle) {
        [handle seekToEndOfFile];
        [handle writeData:[
            [NSString stringWithFormat:@"[%@] %@",
                stringForLogLevel(logLevel), message] dataUsingEncoding:NSUTF8StringEncoding]
        ];
    } else {
        NSLog(@"[CRITICAL] failed to open log, aborting process. Goodbye");
        abort();
    }
}

@end

NS_ASSUME_NONNULL_END
