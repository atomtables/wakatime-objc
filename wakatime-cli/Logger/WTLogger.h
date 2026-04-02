//
//  WTLogger.h
//  wakatime-cli
//
//  Created by Adithiya Venkatakrishnan on 1/4/2026.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define WTLog(message) [[WTLogger shared] log:message withLogLevel:WTLoggerLogLevelDebug]
#define WTWarn(message) [[WTLogger shared] log:message withLogLevel:WTLoggerLogLevelWarn]
#define WTError(message) [[WTLogger shared] log:message withLogLevel:WTLoggerLogLevelError]

typedef NS_ENUM(NSInteger, WTLoggerLogLevel) {
    WTLoggerLogLevelDebug,
    WTLoggerLogLevelWarn,
    WTLoggerLogLevelError
};

@interface WTLogger : NSObject

+(instancetype)shared;
-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

-(void)configureLoggerWithFilePath:(NSString*)filePath withStdout:(bool)useStdout withDebug:(bool)debug;

-(void)log:(NSString*)message withLogLevel:(WTLoggerLogLevel)logLevel;

@end

NS_ASSUME_NONNULL_END
