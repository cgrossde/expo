// Copyright 2015-present 650 Industries. All rights reserved.

#import "EXEnvironment.h"
#import "EXFileSystemManager.h"

// Returns if the experience id is the standalone experience.
BOOL EXIsStandaloneExperience(NSString *experienceId) {
  return [[EXEnvironment sharedEnvironment].standaloneManifestUrl containsString:experienceId];
}

@implementation EXFileSystemManager

- (NSString *)bundleDirectoryForExperienceId:(NSString *)experienceId
{
  if (!EXIsStandaloneExperience(experienceId)) {
    return nil;
  }
  return [NSBundle mainBundle].bundlePath;
}

- (NSArray<NSString *> *)bundledAssetsForExperienceId:(NSString *)experienceId
{
  if (!EXIsStandaloneExperience(experienceId)) {
    return nil;
  }
  
  static NSArray<NSString *> *bundledAssets = nil;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    NSString *manifestBundlePath = [[NSBundle mainBundle] pathForResource:kEXEmbeddedManifestResourceName ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:manifestBundlePath];
    if (data.length == 0) {
      return;
    }
    __block NSError *error;
    id manifest = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
      NSLog(@"Error parsing bundled manifest: %@", error);
      return;
    }
    bundledAssets = manifest[@"bundledAssets"];
  });
  return bundledAssets;
}

@end

