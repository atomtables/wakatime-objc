//
//  WTUtils.m
//  wakatime-cli
//
//  Created by Adithiya Venkatakrishnan on 2/4/2026.
//

#import "WTUtils.h"
#include <sys/time.h>

NS_ASSUME_NONNULL_BEGIN

@implementation WTUtils

+ (NSString *)wakatimeHomeDirectory {
    NSString* env = [NSProcessInfo processInfo].environment[@"WAKATIME_HOME"];
    if (env.length > 1) return env;
    return NSHomeDirectory();
}

+ (double)currentTimestamp {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (double)tv.tv_sec + (double)tv.tv_usec / 1000000.0;
}

+ (NSString*)wakatimeResourcesDirectory {
    NSString* directory = [NSString stringWithFormat:@"%@/.wakatime", [WTUtils wakatimeHomeDirectory]];
    NSFileManager* man = [[NSFileManager alloc] init];
    BOOL isDirectory;
    bool exists = [man fileExistsAtPath:directory isDirectory:&isDirectory];
    if (isDirectory) return nil;
    if (!exists) {
        if (![man createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil])
            return nil;
    }
    return directory;
}

+ (bool)runWithArgv:(NSArray<NSString*>*)argv
          andOutput:(NSString*_Nonnull*_Nonnull)output
           andError:(NSError**)error {
    if (argv.count == 0) {
        if (error) {
            *error = [NSError errorWithDomain:NSPOSIXErrorDomain
                                         code:EINVAL
                                     userInfo:@{NSLocalizedDescriptionKey: @"argv must not be empty"}];
        }
        return NO;
    }

    NSTask *task = [[NSTask alloc] init];
    task.launchPath = argv[0];
    if (argv.count > 1) {
        task.arguments = [argv subarrayWithRange:NSMakeRange(1, argv.count - 1)];
    }

    NSPipe *stdoutPipe = [NSPipe pipe];
    NSPipe *stderrPipe = [NSPipe pipe];
    task.standardOutput = stdoutPipe;
    task.standardError = stderrPipe;

    @try {
        [task launch];
    } @catch (NSException *exception) {
        if (error) {
            *error = [NSError errorWithDomain:NSPOSIXErrorDomain
                                         code:ENOENT
                                     userInfo:@{NSLocalizedDescriptionKey: exception.reason ?:
                                                @"Failed to launch task"}];
        }
        *output = @"";
        return NO;
    }

    NSData *stdoutData = [stdoutPipe.fileHandleForReading readDataToEndOfFile];
    NSData *stderrData = [stderrPipe.fileHandleForReading readDataToEndOfFile];
    [task waitUntilExit];

    *output = [[NSString alloc] initWithData:stdoutData encoding:NSUTF8StringEncoding] ?: @"";

    int status = task.terminationStatus;
    if (status != 0) {
        if (error) {
            NSString *stderrString = [[NSString alloc] initWithData:stderrData
                                                           encoding:NSUTF8StringEncoding] ?: @"";
            *error = [NSError errorWithDomain:NSPOSIXErrorDomain
                                         code:status
                                     userInfo:@{NSLocalizedDescriptionKey: stderrString}];
        }
        return NO;
    }

    return YES;
}

@end

NS_ASSUME_NONNULL_END

