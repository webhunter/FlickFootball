//
//  WideReceivers.h
//  TestBezier
//
//  Created by KirbyGee on 2/22/13.
//
//

#import "CCSprite.h"
#import "cocos2d.h"

@interface WideReceivers : CCSprite{
   bool playerBottomtoTop;
   bool playerLefttoRight;
   bool playerMoving;
   float playerSlope;
   CGPoint holdPoint;
   CGPoint playerStartPos;
   NSMutableArray *playerMovementArray;
   
   NSMutableArray *playerBeziers;
   
   CCMotionStreak *ballStreak;
   
   float theta;
   float deltaT;
   
   CGPoint point1;
   CGPoint point2;
   CGPoint point3;
   float velo;
   
   NSMutableDictionary *dataDict;
   
   int pointCount;
   int functionIndex;
   
   float xDt;
   float xConst;
   float yDt;
   float yConst;

   
   bool stopParametric;
}

-(id) initWithFile:(NSString *)filename;
-(id) playerStreak: (NSMutableArray*) playBook;
-(id) setHoldPosition:(CGPoint) holder;
-(id) movePlayerBack;
-(id) setStartingPosition:(CGPoint) startPos;

@property (nonatomic, readwrite) bool playerBottomtoTop;
@property (nonatomic, readwrite) bool playerLefttoRight;
@property (nonatomic, readwrite) bool playerMoving;
@property (nonatomic, readwrite) float playerSlope;
@property (nonatomic, readwrite) float velo;

@property (nonatomic, readwrite) float xDt;
@property (nonatomic, readwrite) float xConst;
@property (nonatomic, readwrite) float yDt;
@property (nonatomic, readwrite) float yConst;
@property (nonatomic, readwrite) float theta;
@property (nonatomic, readwrite) float deltaT;

@property (nonatomic, readwrite) int functionIndex;
@property (nonatomic, readwrite) int pointCount;
@property (nonatomic, readwrite) bool stopParametric;

@property (nonatomic, readwrite) CGPoint holdPoint;
@property (nonatomic, readwrite) CGPoint playerStartPos;
@property (nonatomic, retain)NSMutableArray *playerMovementArray;
@property (nonatomic, retain)NSMutableArray *playerBeziers;
@property (nonatomic, retain)NSMutableDictionary *dataDict;

@end
