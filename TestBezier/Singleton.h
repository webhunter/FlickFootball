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
   bool _ballToPlayer;
   bool _runParametric;

   //for bezier purposes
   CGPoint _b1, _b2, _b3;

}
+ (Singleton *) sharedSingleron;

@property (readwrite) bool defenderFollowBool;
@property (readwrite) bool playersHaveReturned;
@property (readwrite) bool ballToPlayer;
@property (readwrite) bool runParametric;

@property (readwrite) CGPoint b1;
@property (readwrite) CGPoint b2;
@property (readwrite) CGPoint b3;

@end
