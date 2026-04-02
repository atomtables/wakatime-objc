//
//  WTConfigParser.m
//  wakatime-cli
//
//  Created by Adithiya Venkatakrishnan on 2/4/2026.
//

#import "WTLogger.h"
#import "WTConfigParser.h"

NS_ASSUME_NONNULL_BEGIN

// Maps a WTConfigKey to its section and ini key name.
@interface WTConfigKeyInfo : NSObject
@property (nonatomic, copy) WTConfigSection section;
@property (nonatomic, copy) NSString *iniKey;
- (instancetype)initWithSection:(WTConfigSection)section iniKey:(NSString *)iniKey;
@end

@interface WTConfigParser ()

/// Parsed data: section name -> (key -> raw string value or newline-joined list).
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSString *> *> *parsedSections;

- (void)parseString:(NSString *)str;
- (nullable NSString *)rawValueForKey:(WTConfigKey)key;
+ (WTConfigKeyInfo *)keyInfoForKey:(WTConfigKey)key;

@end

// MARK: - Key constants

WTConfigKey const WTConfigKeyDebug                       = @"debug";
WTConfigKey const WTConfigKeyApiKey                      = @"api_key";
WTConfigKey const WTConfigKeyApiKeyVaultCmd              = @"api_key_vault_cmd";
WTConfigKey const WTConfigKeyApiUrl                      = @"api_url";
WTConfigKey const WTConfigKeyHeartbeatRateLimitSeconds   = @"heartbeat_rate_limit_seconds";
WTConfigKey const WTConfigKeyHideFileNames               = @"hide_file_names";
WTConfigKey const WTConfigKeyHideProjectNames            = @"hide_project_names";
WTConfigKey const WTConfigKeyHideBranchNames             = @"hide_branch_names";
WTConfigKey const WTConfigKeyHideDependencies            = @"hide_dependencies";
WTConfigKey const WTConfigKeyHideProjectFolder           = @"hide_project_folder";
WTConfigKey const WTConfigKeyExclude                     = @"exclude";
WTConfigKey const WTConfigKeyInclude                     = @"include";
WTConfigKey const WTConfigKeyIncludeOnlyWithProjectFile  = @"include_only_with_project_file";
WTConfigKey const WTConfigKeyExcludeUnknownProject       = @"exclude_unknown_project";
WTConfigKey const WTConfigKeyStatusBarEnabled            = @"status_bar_enabled";
WTConfigKey const WTConfigKeyStatusBarCodingActivity     = @"status_bar_coding_activity";
WTConfigKey const WTConfigKeyStatusBarHideCategories     = @"status_bar_hide_categories";
WTConfigKey const WTConfigKeyStatusBarMaxCategories      = @"status_bar_max_categories";
WTConfigKey const WTConfigKeyOffline                     = @"offline";
WTConfigKey const WTConfigKeyProxy                       = @"proxy";
WTConfigKey const WTConfigKeyNoSslVerify                 = @"no_ssl_verify";
WTConfigKey const WTConfigKeySslCertsFile                = @"ssl_certs_file";
WTConfigKey const WTConfigKeyTimeout                     = @"timeout";
WTConfigKey const WTConfigKeyHostname                    = @"hostname";
WTConfigKey const WTConfigKeyLogFile                     = @"log_file";
WTConfigKey const WTConfigKeyImportCfg                   = @"import_cfg";
WTConfigKey const WTConfigKeyMetrics                     = @"metrics";
WTConfigKey const WTConfigKeyGuessLanguage               = @"guess_language";
WTConfigKey const WTConfigKeySyncAiDisabled              = @"sync_ai_disabled";

WTConfigKey const WTConfigKeyGitSubmodulesDisabled       = @"submodules_disabled";
WTConfigKey const WTConfigKeyGitProjectFromGitRemote     = @"project_from_git_remote";

WTConfigSection const WTConfigSectionSettings              = @"settings";
WTConfigSection const WTConfigSectionProjectMap            = @"projectmap";
WTConfigSection const WTConfigSectionProjectApiKey         = @"project_api_key";
WTConfigSection const WTConfigSectionApiUrls               = @"api_urls";
WTConfigSection const WTConfigSectionGit                   = @"git";
WTConfigSection const WTConfigSectionGitSubmoduleProjectMap = @"git_submodule_projectmap";

// MARK: - WTConfigKeyInfo

@implementation WTConfigKeyInfo
- (instancetype)initWithSection:(WTConfigSection)section iniKey:(NSString *)iniKey {
    if (self = [super init]) {
        _section = [section copy];
        _iniKey = [iniKey copy];
    }
    return self;
}
@end

// MARK: - WTConfigParser

@implementation WTConfigParser

static inline WTConfigKeyInfo *KI(WTConfigSection section, NSString *iniKey) {
    return [[WTConfigKeyInfo alloc] initWithSection:section iniKey:iniKey];
}

// Maps each WTConfigKey to its section and ini key name.
// Keys that live in [settings] use WTConfigSectionSettings;
// git keys use WTConfigSectionGit.
+ (WTConfigKeyInfo *)keyInfoForKey:(WTConfigKey)key {
    static NSDictionary<WTConfigKey, WTConfigKeyInfo *> *map = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = @{
            WTConfigKeyDebug:                      KI(WTConfigSectionSettings, @"debug"),
            WTConfigKeyApiKey:                     KI(WTConfigSectionSettings, @"api_key"),
            WTConfigKeyApiKeyVaultCmd:             KI(WTConfigSectionSettings, @"api_key_vault_cmd"),
            WTConfigKeyApiUrl:                     KI(WTConfigSectionSettings, @"api_url"),
            WTConfigKeyHeartbeatRateLimitSeconds:  KI(WTConfigSectionSettings, @"heartbeat_rate_limit_seconds"),
            WTConfigKeyHideFileNames:              KI(WTConfigSectionSettings, @"hide_file_names"),
            WTConfigKeyHideProjectNames:           KI(WTConfigSectionSettings, @"hide_project_names"),
            WTConfigKeyHideBranchNames:            KI(WTConfigSectionSettings, @"hide_branch_names"),
            WTConfigKeyHideDependencies:           KI(WTConfigSectionSettings, @"hide_dependencies"),
            WTConfigKeyHideProjectFolder:          KI(WTConfigSectionSettings, @"hide_project_folder"),
            WTConfigKeyExclude:                    KI(WTConfigSectionSettings, @"exclude"),
            WTConfigKeyInclude:                    KI(WTConfigSectionSettings, @"include"),
            WTConfigKeyIncludeOnlyWithProjectFile: KI(WTConfigSectionSettings, @"include_only_with_project_file"),
            WTConfigKeyExcludeUnknownProject:      KI(WTConfigSectionSettings, @"exclude_unknown_project"),
            WTConfigKeyStatusBarEnabled:           KI(WTConfigSectionSettings, @"status_bar_enabled"),
            WTConfigKeyStatusBarCodingActivity:    KI(WTConfigSectionSettings, @"status_bar_coding_activity"),
            WTConfigKeyStatusBarHideCategories:    KI(WTConfigSectionSettings, @"status_bar_hide_categories"),
            WTConfigKeyStatusBarMaxCategories:     KI(WTConfigSectionSettings, @"status_bar_max_categories"),
            WTConfigKeyOffline:                    KI(WTConfigSectionSettings, @"offline"),
            WTConfigKeyProxy:                      KI(WTConfigSectionSettings, @"proxy"),
            WTConfigKeyNoSslVerify:                KI(WTConfigSectionSettings, @"no_ssl_verify"),
            WTConfigKeySslCertsFile:               KI(WTConfigSectionSettings, @"ssl_certs_file"),
            WTConfigKeyTimeout:                    KI(WTConfigSectionSettings, @"timeout"),
            WTConfigKeyHostname:                   KI(WTConfigSectionSettings, @"hostname"),
            WTConfigKeyLogFile:                    KI(WTConfigSectionSettings, @"log_file"),
            WTConfigKeyImportCfg:                  KI(WTConfigSectionSettings, @"import_cfg"),
            WTConfigKeyMetrics:                    KI(WTConfigSectionSettings, @"metrics"),
            WTConfigKeyGuessLanguage:              KI(WTConfigSectionSettings, @"guess_language"),
            WTConfigKeySyncAiDisabled:             KI(WTConfigSectionSettings, @"sync_ai_disabled"),
            WTConfigKeyGitSubmodulesDisabled:      KI(WTConfigSectionGit, @"submodules_disabled"),
            WTConfigKeyGitProjectFromGitRemote:    KI(WTConfigSectionGit, @"project_from_git_remote"),
        };

    });
    return map[key];
}

- (nullable instancetype)initWithPath:(NSString *)path withError:(NSError **)error {
    NSString *expanded = [path stringByExpandingTildeInPath];
    WTDebug(@"WTConfigParser initWithPath: expanded=%@", expanded);
    NSString *str = [NSString stringWithContentsOfFile:expanded
                                              encoding:NSUTF8StringEncoding
                                                 error:error];
    if (!str) {
        WTDebug(@"WTConfigParser initWithPath: failed to read file at %@, error=%@", expanded, (error && *error) ? *error : nil);
        return nil;
    }
    WTDebug(@"WTConfigParser initWithPath: read %lu characters", (unsigned long)str.length);
    return [self initWithString:str];
}

- (instancetype)initWithString:(NSString *)str {
    if (self = [super init]) {
        WTDebug(@"WTConfigParser initWithString: called length=%lu", (unsigned long)str.length);
        _parsedSections = [NSMutableDictionary dictionary];
        [self parseString:str];
        WTDebug(@"WTConfigParser initWithString: parsed sections=%lu", (unsigned long)self.parsedSections.count);
    }
    return self;
}

// MARK: - Parsing

- (void)parseString:(NSString *)str {
    WTDebug(@"WTConfigParser parseString: called");
    NSArray<NSString *> *lines = [str componentsSeparatedByCharactersInSet:
                                  [NSCharacterSet newlineCharacterSet]];

    __block NSString *currentSection = nil;
    __block NSString *currentKey = nil;
    // Accumulates continuation lines for multiline values.
    __block NSMutableArray<NSString *> *currentValueLines = nil;

    void (^flushCurrent)(void) = ^{
        if (!currentSection || !currentKey || !currentValueLines) return;
        WTDebug(@"WTConfigParser parseString: flushing section=%@ key=%@ lines=%lu", currentSection, currentKey, (unsigned long)currentValueLines.count);
        NSString *joined = [currentValueLines componentsJoinedByString:@"\n"];
        self.parsedSections[currentSection][currentKey] = joined;
    };

    for (NSString *rawLine in lines) {
        // Strip trailing whitespace; preserve leading (used to detect continuations).
        NSString *rstripped = [rawLine stringByReplacingOccurrencesOfString:@"\\s+$"
                                                                 withString:@""
                                                                    options:NSRegularExpressionSearch
                                                                      range:NSMakeRange(0, rawLine.length)];

        // Skip comments and blank lines (but not continuation lines).
        NSString *trimmed = [rstripped stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceCharacterSet]];

        if (trimmed.length == 0 || [trimmed hasPrefix:@";"] || [trimmed hasPrefix:@"#"]) {
            // A blank/comment line ends any ongoing multiline value.
            flushCurrent();
            currentKey = nil;
            currentValueLines = nil;
            continue;
        }

        // Section header: [section]
        if ([trimmed hasPrefix:@"["] && [trimmed hasSuffix:@"]"]) {
            flushCurrent();
            currentKey = nil;
            currentValueLines = nil;
            currentSection = [[trimmed substringWithRange:NSMakeRange(1, trimmed.length - 2)]
                              lowercaseString];
            WTDebug(@"WTConfigParser parseString: in section [%@]", currentSection);
            if (!self.parsedSections[currentSection]) {
                self.parsedSections[currentSection] = [NSMutableDictionary dictionary];
            }
            continue;
        }

        if (!currentSection) continue;

        // Continuation line: starts with whitespace and we have an active key.
        if (currentKey && [rstripped length] > 0 &&
            [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[rstripped characterAtIndex:0]]) {
            if (trimmed.length > 0) {
                [currentValueLines addObject:trimmed];
            }
            continue;
        }

        // Key = value line.
        NSRange eqRange = [trimmed rangeOfString:@"="];
        if (eqRange.location == NSNotFound) continue;

        flushCurrent();

        NSString *key = [[trimmed substringToIndex:eqRange.location]
                         stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *value = [[trimmed substringFromIndex:eqRange.location + 1]
                           stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        currentKey = [key lowercaseString];
        currentValueLines = [NSMutableArray array];
        WTDebug(@"WTConfigParser parseString: found new item key=%@ initialValue=%@", currentKey, value.length > 0 ? value : @"<empty>");
        if (value.length > 0) {
            [currentValueLines addObject:value];
        }
    }

    flushCurrent();
    WTDebug(@"WTConfigParser parseString: found %lu sections", (unsigned long)self.parsedSections.count);
    WTLog(@"Found %lu sections in config", (unsigned long)self.parsedSections.count);
}

// MARK: - Private read

- (nullable NSString *)rawValueForKey:(WTConfigKey)key {
    WTConfigKeyInfo *info = [WTConfigParser keyInfoForKey:key];
    if (!info) return nil;
    return self.parsedSections[info.section][info.iniKey];
}

// MARK: - Public read

- (nullable NSString *)readStringWithKey:(WTConfigKey)key {
    NSString *raw = [self rawValueForKey:key];
    if (!raw) {
        WTDebug(@"WTConfigParser readStringWithKey:%@: not found", key);
        return nil;
    }
    NSString *first = [raw componentsSeparatedByString:@"\n"].firstObject;
    WTDebug(@"WTConfigParser readStringWithKey:%@: value=%@", key, first);
    return first;
}

- (BOOL)readBoolWithKey:(WTConfigKey)key defaultValue:(BOOL)defaultValue {
    NSString *raw = [[self readStringWithKey:key] lowercaseString];
    if (!raw) {
        WTDebug(@"WTConfigParser readBoolWithKey:%@: using default=%@ (missing)", key, defaultValue ? @"YES" : @"NO");
        return defaultValue;
    }
    if ([raw isEqualToString:@"true"] || [raw isEqualToString:@"1"]) {
        WTDebug(@"WTConfigParser readBoolWithKey:%@: parsed YES from %@", key, raw);
        return YES;
    }
    if ([raw isEqualToString:@"false"] || [raw isEqualToString:@"0"]) {
        WTDebug(@"WTConfigParser readBoolWithKey:%@: parsed NO from %@", key, raw);
        return NO;
    }
    WTDebug(@"WTConfigParser readBoolWithKey:%@: unrecognized '%@', using default=%@", key, raw, defaultValue ? @"YES" : @"NO");
    return defaultValue;
}

- (NSInteger)readIntegerWithKey:(WTConfigKey)key defaultValue:(NSInteger)defaultValue {
    NSString *raw = [self readStringWithKey:key];
    if (!raw) {
        WTDebug(@"WTConfigParser readIntegerWithKey:%@: using default=%ld (missing)", key, (long)defaultValue);
        return defaultValue;
    }
    NSInteger val = [raw integerValue];
    if (val == 0 && ![raw isEqualToString:@"0"]) {
        WTDebug(@"WTConfigParser readIntegerWithKey:%@: unrecognized '%@', using default=%ld", key, raw, (long)defaultValue);
        return defaultValue;
    }
    WTDebug(@"WTConfigParser readIntegerWithKey:%@: value=%ld (from '%@')", key, (long)val, raw);
    return val;
}

- (NSArray<NSString *> *)readArrayWithKey:(WTConfigKey)key {
    NSString *raw = [self rawValueForKey:key];
    if (!raw || raw.length == 0) {
        WTDebug(@"WTConfigParser readArrayWithKey:%@: empty", key);
        return @[];
    }
    NSArray<NSString *> *lines = [raw componentsSeparatedByString:@"\n"];
    NSMutableArray<NSString *> *result = [NSMutableArray array];
    for (NSString *line in lines) {
        NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (trimmed.length > 0) [result addObject:trimmed];
    }
    WTDebug(@"WTConfigParser readArrayWithKey:%@: count=%lu", key, (unsigned long)result.count);
    return [result copy];
}

- (NSDictionary<NSString *, NSString *> *)readMapSection:(WTConfigSection)section {
    NSDictionary<NSString *, NSString *> *raw = self.parsedSections[[section lowercaseString]];
    NSDictionary<NSString *, NSString *> *copy = raw ? [raw copy] : @{};
    WTDebug(@"WTConfigParser readMapSection:[%@]: keys=%lu", [section lowercaseString], (unsigned long)copy.count);
    return copy;
}

@end

NS_ASSUME_NONNULL_END

