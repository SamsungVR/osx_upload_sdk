

#import "SharedPrefs.h"

@implementation SharedPrefs {
   NSString *mPath;
   NSMutableDictionary *mDict;
}

- (id)initWithName:(NSString *)name {
   NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
   mPath = [NSString stringWithFormat:@"%@/%@.prefs", bundlePath, name];
   mDict = [[NSMutableDictionary alloc] initWithContentsOfFile:mPath];
   return [super init];
}

- (void)set:(NSString *)attr value:(NSString *)value {
   mDict[attr] = value;
}

- (NSString *)get:(NSString *)attr def:(NSString*)def {
   NSString *result = mDict[attr];
   if (!result) {
      result = def;
   }
   return result;
}

- (void)save {
   [mDict writeToFile:mPath atomically:NO];
}

@end
