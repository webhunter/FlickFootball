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
@property (nonatomic, readwrite) CGPoint holdPoint;
@property (nonatomic, readwrite) CGPoint playerStartPos;
@property (nonatomic, retain)NSMutableArray *playerMovementArray;
@property (nonatomic, retain)NSMutableArray *playerBeziers;

@end
