//
//  Singleton.h
//  TestBezier
//
//  Created by KirbyGee on 3/5/13.
//
//

#import <Foundation/Foundation.h>

@interface Singleton : NSObject{
   bool _defenderFollowBool;
   bool _playersHaveReturned;

}
+ (Singleton *) sharedSingleron;

@property (readwrite) bool defenderFollowBool;
@property (readwrite) bool playersHaveReturned;

@end
