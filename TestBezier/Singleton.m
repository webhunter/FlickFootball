//
//  Singleton.m
//  TestBezier
//
//  Created by KirbyGee on 3/5/13.
//
//

#import "Singleton.h"

@implementation Singleton

@synthesize defenderFollowBool = _defenderFollowBool;
@synthesize playersHaveReturned = _playersHaveReturned;
@synthesize ballToPlayer = _ballToPlayer;
@synthesize b1 = _b1;
@synthesize b2 = _b2;
@synthesize b3 = _b3;

static Singleton* _sharedSingleton = nil;

+(Singleton *) sharedSingleron{
   @synchronized([Singleton class])
   {
      if (!_sharedSingleton)
         [[self alloc] init];
      
      return _sharedSingleton;
   }
   
   return nil;
}
+(id)alloc
{
   @synchronized([Singleton class])
   {
      NSAssert(_sharedSingleton == nil, @"Attempted to allocate a second instance of a singleton.");
      _sharedSingleton = [super alloc];
      return _sharedSingleton;
   }
   
   return nil;
}

-(id)init {
   self = [super init];
   if (self != nil) {
      
   }
   
   return self;
}
@end