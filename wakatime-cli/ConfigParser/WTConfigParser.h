//
//  WTConfigParser.h
//  wakatime-cli
//
//  Created by Adithiya Venkatakrishnan on 2/4/2026.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString* WTConfigKey NS_TYPED_ENUM;

// [settings]
extern WTConfigKey const WTConfigKeyDebug;
extern WTConfigKey const WTConfigKeyApiKey;
extern WTConfigKey const WTConfigKeyApiKeyVaultCmd;
extern WTConfigKey const WTConfigKeyApiUrl;
extern WTConfigKey const WTConfigKeyHeartbeatRateLimitSeconds;
extern WTConfigKey const WTConfigKeyHideFileNames;
extern WTConfigKey const WTConfigKeyHideProjectNames;
extern WTConfigKey const WTConfigKeyHideBranchNames;
extern WTConfigKey const WTConfigKeyHideDependencies;
extern WTConfigKey const WTConfigKeyHideProjectFolder;
extern WTConfigKey const WTConfigKeyExclude;
extern WTConfigKey const WTConfigKeyInclude;
extern WTConfigKey const WTConfigKeyIncludeOnlyWithProjectFile;
extern WTConfigKey const WTConfigKeyExcludeUnknownProject;
extern WTConfigKey const WTConfigKeyStatusBarEnabled;
extern WTConfigKey const WTConfigKeyStatusBarCodingActivity;
extern WTConfigKey const WTConfigKeyStatusBarHideCategories;
extern WTConfigKey const WTConfigKeyStatusBarMaxCategories;
extern WTConfigKey const WTConfigKeyOffline;
extern WTConfigKey const WTConfigKeyProxy;
extern WTConfigKey const WTConfigKeyNoSslVerify;
extern WTConfigKey const WTConfigKeySslCertsFile;
extern WTConfigKey const WTConfigKeyTimeout;
extern WTConfigKey const WTConfigKeyHostname;
extern WTConfigKey const WTConfigKeyLogFile;
extern WTConfigKey const WTConfigKeyImportCfg;
extern WTConfigKey const WTConfigKeyMetrics;
extern WTConfigKey const WTConfigKeyGuessLanguage;
extern WTConfigKey const WTConfigKeySyncAiDisabled;

// [git]
extern WTConfigKey const WTConfigKeyGitSubmodulesDisabled;
extern WTConfigKey const WTConfigKeyGitProjectFromGitRemote;

typedef NSString* WTConfigSection NS_TYPED_ENUM;

extern WTConfigSection const WTConfigSectionSettings;
extern WTConfigSection const WTConfigSectionProjectMap;
extern WTConfigSection const WTConfigSectionProjectApiKey;
extern WTConfigSection const WTConfigSectionApiUrls;
extern WTConfigSection const WTConfigSectionGit;
extern WTConfigSection const WTConfigSectionGitSubmoduleProjectMap;

@interface WTConfigParser : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithPath:(NSString *)path withError:(NSError **)error;
- (instancetype)initWithString:(NSString *)str;

/// Read a scalar string value from [settings] or [git].
- (nullable NSString *)readStringWithKey:(WTConfigKey)key;

/// Read a bool value (accepts "true"/"false"/"1"/"0").
- (BOOL)readBoolWithKey:(WTConfigKey)key defaultValue:(BOOL)defaultValue;

/// Read an integer value.
- (NSInteger)readIntegerWithKey:(WTConfigKey)key defaultValue:(NSInteger)defaultValue;

/// Read a multiline list value (e.g. exclude, include).
- (NSArray<NSString *> *)readArrayWithKey:(WTConfigKey)key;

/// Read all key/value pairs from a map section (projectmap, project_api_key, etc.)
- (NSDictionary<NSString *, NSString *> *)readMapSection:(WTConfigSection)section;

@end

NS_ASSUME_NONNULL_END
