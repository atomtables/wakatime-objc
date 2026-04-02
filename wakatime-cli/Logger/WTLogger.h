//
//  WTLogger.h
//  wakatime-cli
//
//  Created by Adithiya Venkatakrishnan on 1/4/2026.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define WTDebug(message, ...) [[WTLogger shared] log:[NSString stringWithFormat:message, ##__VA_ARGS__] withLogLevel:WTLoggerLogLevelSmurfme]
#define WTLog(message, ...) [[WTLogger shared] log:[NSString stringWithFormat:message, ##__VA_ARGS__] withLogLevel:WTLoggerLogLevelDebug]
#define WTWarn(message, ...) [[WTLogger shared] log:[NSString stringWithFormat:message, ##__VA_ARGS__] withLogLevel:WTLoggerLogLevelWarn]
#define WTError(message, ...) [[WTLogger shared] log:[NSString stringWithFormat:message, ##__VA_ARGS__] withLogLevel:WTLoggerLogLevelError]

typedef NS_ENUM(NSInteger, WTLoggerLogLevel) {
    WTLoggerLogLevelDebug,
    WTLoggerLogLevelWarn,
    WTLoggerLogLevelError,
    WTLoggerLogLevelSmurfme
};

@interface WTLogger : NSObject

+(instancetype)shared;
-(instancetype)init NS_UNAVAILABLE;
+(instancetype)new NS_UNAVAILABLE;

-(void)configureLoggerWithFilePath:(NSString*)filePath withStdout:(bool)useStdout withDebug:(bool)debug;

-(void)log:(NSString*)message withLogLevel:(WTLoggerLogLevel)logLevel;

@end

NS_ASSUME_NONNULL_END
